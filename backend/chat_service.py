"""
chat_service.py — Orchestration Chatbot v4 (FAST PATH)
=======================================================

Architecture: code-first, LLM-optional.

FAST PATH (par défaut, 90% des cas):
  User → message_parser → search_restaurants → response_builder → réponse
  Latence: < 200ms. ZERO appel LLM.

SMART PATH (optionnel, si activé):
  User → message_parser → search_restaurants → LLM enrichit la réponse
  Latence: 1-2s. UN SEUL appel LLM (pas deux).

Le LLM ne décide plus des filtres, ne fait plus de tool calling,
ne choisit plus les restaurants. Tout ça est fait par le code.
"""

import json
import os
import time
import hashlib
from typing import Optional
from groq import Groq
from message_parser import parse_message, is_food_related, detect_language
from search_service import search_restaurants
from response_builder import build_response, build_not_food_response
from data_store import get_restaurant_by_id



# 1. CONFIG


MODEL = "llama-3.1-8b-instant"
DEBUG = os.environ.get("DEBUG", "true").lower() == "true"

# Mode global: "fast" (pas de LLM) ou "smart" (LLM pour la réponse finale)
# Changer en "smart" si la latence Groq est < 1s (connexion rapide)
PIPELINE_MODE = os.environ.get("PIPELINE_MODE", "fast")

_client = None


def _get_groq_client() -> Groq:
    global _client
    if _client is None:
        api_key = os.environ.get("GROQ_API_KEY")
        if not api_key:
            raise RuntimeError("GROQ_API_KEY non définie.")
        _client = Groq(api_key=api_key)
    return _client


def _log(label: str, data):
    if DEBUG:
        ts = time.strftime("%H:%M:%S")
        if isinstance(data, (dict, list)):
            data = json.dumps(data, ensure_ascii=False)[:300]
        print(f"  [{ts}] 🔧 {label}: {data}")



# 2. CACHE EN MÉMOIRE

# Clé = hash du message + coordonnées. Valeur = résultats.
# Taille max = 100 entrées (LRU simple).

_cache: dict[str, dict] = {}
_CACHE_MAX = 100


def _cache_key(message: str, lat: float = None, lng: float = None) -> str:
    """Génère une clé de cache basée sur le message et la position."""
    raw = f"{message.lower().strip()}|{lat}|{lng}"
    return hashlib.md5(raw.encode()).hexdigest()


def _cache_get(key: str) -> dict | None:
    return _cache.get(key)


def _cache_set(key: str, value: dict):
    if len(_cache) >= _CACHE_MAX:
        # Supprimer la plus ancienne entrée (FIFO simple)
        oldest = next(iter(_cache))
        del _cache[oldest]
    _cache[key] = value



# 3. PIPELINE PRINCIPAL


async def process_chat(
    message: str,
    user_lat: Optional[float] = None,
    user_lng: Optional[float] = None,
    conversation_history: list[dict] = None,
    pipeline: str = None,
) -> dict:
    """
    Point d'entrée principal.

    Args:
        pipeline: "fast" (défaut) ou "smart" (utilise le LLM pour la réponse)
                  Override la variable d'env PIPELINE_MODE.
    """
    start = time.time()
    mode = pipeline or PIPELINE_MODE

    if conversation_history is None:
        conversation_history = []

    # ── Étape 1: Cache check ──
    ck = _cache_key(message, user_lat, user_lng)
    cached = _cache_get(ck)
    if cached:
        elapsed = time.time() - start
        _log("⚡ CACHE HIT", f"{elapsed*1000:.1f}ms")
        cached["debug"]["from_cache"] = True
        cached["debug"]["total_time_s"] = round(elapsed, 3)
        return cached

    # ── Étape 2: Parser rapide ──
    t0 = time.time()
    parsed = parse_message(message, user_lat, user_lng, conversation_history)
    parse_time = time.time() - t0

    _log("PARSED", {
        "lang": parsed["lang"], "food": parsed["is_food"],
        "budget": parsed["budget_max_fcfa"], "dietary": parsed["dietary"],
        "cuisine": parsed["cuisine_keywords"], "text": parsed["text_query"],
        "zone": parsed["zone"], "mode": parsed["mode"],
    })
    _log("PARSE TIME", f"{parse_time*1000:.2f}ms")

    # ── Étape 3: Pas food? → réponse directe ──
    if not parsed["is_food"]:
        reply = build_not_food_response(parsed["lang"])
        result = {
            "reply": reply,
            "restaurants": [],
            "detected_language": parsed["lang"],
            "debug": {
                "pipeline": "fast",
                "total_time_s": round(time.time() - start, 3),
                "food_related": False,
                "parse_time_ms": round(parse_time * 1000, 2),
                "results_count": 0,
                "from_cache": False,
            }
        }
        return result

    # ── Étape 4: Recherche ──
    t1 = time.time()
    search_args = _build_search_args(parsed)
    _log("SEARCH ARGS", search_args)

    results = search_restaurants(**search_args)

    # Fallback 1: retirer cuisine + text si 0 résultats
    if len(results) == 0 and (search_args.get("cuisine_keywords") or search_args.get("text_query")):
        _log("FALLBACK 1", "Retrait cuisine + text_query")
        fallback_args = {k: v for k, v in search_args.items()
                         if k not in ("cuisine_keywords", "text_query")}
        results = search_restaurants(**fallback_args)

    # Fallback 2: retirer aussi la zone
    if len(results) == 0 and search_args.get("zone"):
        _log("FALLBACK 2", "Retrait zone")
        fallback_args = {k: v for k, v in search_args.items()
                         if k not in ("cuisine_keywords", "text_query", "zone")}
        results = search_restaurants(**fallback_args)

    search_time = time.time() - t1
    _log("SEARCH", f"{len(results)} résultats en {search_time*1000:.1f}ms")

    # ── Étape 5: Construire la réponse ──
    restaurants_clean = _clean_for_api(results)

    if mode == "smart" and results:
        # SMART PATH: LLM enrichit la réponse
        reply = await _smart_response(message, results, parsed)
    else:
        # FAST PATH: réponse template
        reply = build_response(results, parsed["lang"], parsed)

    total = time.time() - start
    _log("⏱️ TOTAL", f"{total*1000:.0f}ms | pipeline={mode} | restos={len(results)}")

    result = {
        "reply": reply,
        "restaurants": restaurants_clean,
        "detected_language": parsed["lang"],
        "debug": {
            "pipeline": mode,
            "total_time_s": round(total, 3),
            "food_related": True,
            "parse_time_ms": round(parse_time * 1000, 2),
            "search_time_ms": round(search_time * 1000, 2),
            "results_count": len(results),
            "parsed": parsed,
            "from_cache": False,
        }
    }

    #Étape 6: Mettre en cache
    _cache_set(ck, result)

    return result



#CONSTRUCTION DES ARGS DE RECHERCHE


def _build_search_args(parsed: dict) -> dict:
    """Convertit le résultat du parser en arguments pour search_restaurants."""
    args = {
        "mode": parsed["mode"],
        "top_n": 3,
    }

    if parsed["user_lat"] is not None:
        args["user_lat"] = parsed["user_lat"]
        args["user_lng"] = parsed["user_lng"]

    if parsed["budget_max_fcfa"]:
        args["budget_max_fcfa"] = parsed["budget_max_fcfa"]

    if parsed["dietary"]:
        args["dietary"] = parsed["dietary"]

    if parsed["cuisine_keywords"]:
        args["cuisine_keywords"] = parsed["cuisine_keywords"]

    if parsed["text_query"]:
        args["text_query"] = parsed["text_query"]

    if parsed["zone"]:
        args["zone"] = parsed["zone"]

    return args



#SMART PATH — LLM pour enrichir (optionnel)

# UN SEUL appel LLM. Pas de tool calling.
# Le LLM reçoit les résultats déjà calculés et reformule.

_SMART_PROMPT = """You are Resto, the restaurant assistant for Dakar 2026 Youth Olympic Games.
Reply in {lang}. Be warm, concise (max 4 sentences). Present the restaurants below naturally.
Mention the signature dish, price, distance, and rating for each.

RESTAURANTS FOUND:
{results}

USER MESSAGE: {message}

Reply in {lang} ONLY. Do NOT invent any restaurant or dish not listed above."""


async def _smart_response(message: str, results: list[dict], parsed: dict) -> str:
    """UN SEUL appel LLM pour reformuler la réponse. Pas de tool calling."""
    lang_names = {"fr": "French", "en": "English", "es": "Spanish", "ar": "Arabic"}
    lang = lang_names.get(parsed["lang"], "French")

    # Résumé compact des résultats pour le LLM
    summary_lines = []
    for r in results[:3]:
        dish_name = "Menu"
        menu = r.get("menu", [])
        for p in menu:
            if "signature" in p.get("tags", []):
                dish_name = f"{p['name']} ({p['price']} FCFA)"
                break
        else:
            food = [p for p in menu if "boisson" not in p.get("tags", [])]
            if food:
                best = max(food, key=lambda x: x["price"])
                dish_name = f"{best['name']} ({best['price']} FCFA)"

        dist = f"{r.get('distance_km')} km" if r.get("distance_km") is not None else "N/A"
        summary_lines.append(
            f"- {r['name']} ({r['zone']}, {dist}) | Rating: {r.get('rating')}★ | "
            f"Signature: {dish_name} | Dietary: {r.get('dietary', [])}"
        )

    prompt = _SMART_PROMPT.format(
        lang=lang,
        results="\n".join(summary_lines),
        message=message,
    )

    try:
        t0 = time.time()
        response = _get_groq_client().chat.completions.create(
            model=MODEL,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=300,
            temperature=0.5,
        )
        _log("SMART LLM", f"{(time.time()-t0):.2f}s")
        return response.choices[0].message.content or build_response(results, parsed["lang"])
    except Exception as e:
        _log("SMART LLM FAIL", str(e))
        # Fallback: réponse template
        return build_response(results, parsed["lang"])



#NETTOYAGE API


def _clean_for_api(restos: list[dict]) -> list[dict]:
    return [
        {
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
            "distance_km": r.get("distance_km"),
            "score": r.get("score"),
            "explanation": r.get("explanation"),
        }
        for r in restos
    ]