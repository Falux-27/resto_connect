"""
main.py — API REST Resto Connect Dakar
=======================================
Point d'entrée de l'application.
Endpoints: /chat, /search, /restaurants/{id}, /stats

Lancer: uvicorn main:app --reload --port 8000
"""

# Charger le .env AVANT tout import (pour que GROQ_API_KEY soit dispo)
from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import json

from data_store import load_restaurants, get_all_restaurants, get_restaurant_by_id, get_stats
from search_service import search_restaurants
from chat_service import process_chat


# ──────────────────────────────────────────────
# 1. APP FASTAPI
# ──────────────────────────────────────────────

app = FastAPI(
    title="Resto Connect Dakar API",
    description="API de recommandation de restaurants pour les JOJ Dakar 2026",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # En prod, restreindre aux domaines Flutter
    allow_methods=["*"],
    allow_headers=["*"],
)


# Charger les données au démarrage
@app.on_event("startup")
def startup():
    load_restaurants()


# ──────────────────────────────────────────────
# 2. SCHÉMAS PYDANTIC (validation des requêtes)
# ──────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str
    user_lat: Optional[float] = None
    user_lng: Optional[float] = None
    conversation_history: Optional[list[dict]] = []
    pipeline: Optional[str] = None   # "fast" (défaut) ou "smart"

class SearchRequest(BaseModel):
    user_lat: Optional[float] = None
    user_lng: Optional[float] = None
    max_distance_km: float = 5.0
    budget_max_fcfa: Optional[int] = None
    dietary: Optional[list[str]] = None
    cuisine_keywords: Optional[list[str]] = None
    text_query: Optional[str] = None
    zone: Optional[str] = None
    mode: str = "balanced"
    top_n: int = 3


# ──────────────────────────────────────────────
# 3. ENDPOINTS
# ──────────────────────────────────────────────

@app.get("/")
def health():
    """Health check."""
    stats = get_stats()
    return {
        "status": "ok",
        "app": "Resto Connect Dakar",
        "restaurants_loaded": stats["total"],
    }


@app.post("/chat")
async def chat_endpoint(req: ChatRequest):
    """
    Endpoint principal — chatbot IA.
    Envoie le message à Llama 3.1, exécute la recherche si besoin,
    retourne la réponse + les restaurants.

    Body:
        message: "I need halal food near the stadium"
        user_lat: 14.6937   (optionnel)
        user_lng: -17.4441  (optionnel)
        conversation_history: [...]  (optionnel)

    Response:
        reply: "Here are 3 great halal restaurants..."
        restaurants: [{...}, {...}, {...}]
        detected_language: "en"
    """
    try:
        result = await process_chat(
            message=req.message,
            user_lat=req.user_lat,
            user_lng=req.user_lng,
            conversation_history=req.conversation_history or [],
            pipeline=req.pipeline,
        )
        return result
    except Exception as e:
        # En cas d'erreur Groq (quota, réseau, etc.), on fallback
        # sur une recherche directe sans IA
        print(f"⚠️ Erreur chatbot: {e}")
        return {
            "reply": "Désolé, je rencontre un problème technique. Voici des suggestions basées sur votre position. / Sorry, I'm experiencing a technical issue. Here are suggestions based on your location.",
            "restaurants": _fallback_search(req),
            "detected_language": "fr",
            "error": str(e),
        }


@app.post("/search")
def search_endpoint(req: SearchRequest):
    """
    Recherche directe sans IA — utile pour le frontend Flutter
    quand on veut chercher sans passer par le chatbot.

    Body: voir SearchRequest

    Response: liste de restaurants scorés avec explanation
    """
    results = search_restaurants(
        user_lat=req.user_lat,
        user_lng=req.user_lng,
        max_distance_km=req.max_distance_km,
        budget_max_fcfa=req.budget_max_fcfa,
        dietary=req.dietary,
        cuisine_keywords=req.cuisine_keywords,
        text_query=req.text_query,
        zone=req.zone,
        mode=req.mode,
        top_n=req.top_n,
    )
    return _clean_results(results)


@app.get("/restaurants")
def list_all_restaurants():
    """Liste tous les restaurants (sans scoring)."""
    restos = get_all_restaurants()
    return [_clean_single(r) for r in restos]


@app.get("/restaurants/{resto_id}")
def get_restaurant_detail(resto_id: str):
    """Détail complet d'un restaurant par ID."""
    resto = get_restaurant_by_id(resto_id)
    if not resto:
        raise HTTPException(status_code=404, detail=f"Restaurant '{resto_id}' non trouvé")
    return _clean_single(resto)


@app.get("/stats")
def stats_endpoint():
    """Statistiques globales (utile pour le dashboard)."""
    return get_stats()


# ──────────────────────────────────────────────
# 4. UTILITAIRES
# ──────────────────────────────────────────────

def _clean_single(r: dict) -> dict:
    """Nettoie un restaurant pour l'API (retire les champs internes _xxx)."""
    return {
        "id": r["id"],
        "name": r["name"],
        "zone": r["zone"],
        "lat": r["lat"],
        "lng": r["lng"],
        "phone": r.get("phone", ""),
        "rating": r.get("rating", 3.0),
        "popularity": r.get("popularity", 0.5),
        "price_range": r.get("price_range", "mid"),
        "avg_price": r.get("avg_price", 0),
        "cuisine_type": r.get("cuisine_type", []),
        "dietary": r.get("dietary", []),
        "tags": r.get("tags", []),
        "opening_hours": r.get("opening_hours", ""),
        "image": r.get("image", ""),
        "description": r.get("description", ""),
        "menu": r.get("menu", []),
    }


def _clean_results(results: list[dict]) -> list[dict]:
    """Nettoie les résultats de recherche pour l'API."""
    cleaned = []
    for r in results:
        item = _clean_single(r)
        item["distance_km"] = r.get("distance_km")
        item["score"] = r.get("score")
        item["explanation"] = r.get("explanation")
        cleaned.append(item)
    return cleaned


def _fallback_search(req: ChatRequest) -> list[dict]:
    """Recherche de secours quand le chatbot IA tombe."""
    results = search_restaurants(
        user_lat=req.user_lat,
        user_lng=req.user_lng,
        top_n=3,
    )
    return _clean_results(results)