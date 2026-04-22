"""
data_store.py — Module de données Resto Connect Dakar
=====================================================
Charge les restaurants depuis un fichier JSON, valide la structure,
et enrichit avec des champs calculés (une seule fois au chargement).

Pas de base de données : on travaille en mémoire avec une liste de dicts.
"""

import json
import os
from typing import Optional



#SCHÉMA valeurs autorisées


PRICE_RANGES = ["low", "mid", "high"]
# low  = moins de 4000 FCFA/personne
# mid  = 4000 à 10000 FCFA
# high = plus de 10000 FCFA

CUISINE_TYPES = [
    "senegalais", "local", "international", "français",
    "libanais", "méditerranéen", "asiatique", "italien",
    "fast_food", "street_food", "seafood", "grillades",
    "café", "pâtisserie",
]

DIETARY_OPTIONS = ["halal", "vegetarien", "vegan", "sans_gluten"]

REQUIRED_FIELDS = ["id", "name", "zone", "lat", "lng", "price_range", "avg_price", "menu"]



#CHARGEMENT


DATA_FILE = os.path.join(os.path.dirname(__file__), "data", "restaurants.json")
_restaurants: list[dict] = []


def load_restaurants(filepath: str = None) -> list[dict]:
    """Charge, valide et enrichit les restaurants."""
    global _restaurants

    path = filepath or DATA_FILE
    with open(path, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    validated = []
    for i, resto in enumerate(raw_data):
        errors = validate_restaurant(resto)
        if errors:
            print(f"Restaurant #{i} ({resto.get('name', '???')}): {errors}")
            continue
        enriched = enrich_restaurant(resto)
        validated.append(enriched)

    _restaurants = validated
    print(f" {len(validated)} restaurants chargés depuis {path}")
    return _restaurants


def get_all_restaurants() -> list[dict]:
    if not _restaurants:
        load_restaurants()
    return _restaurants


def get_restaurant_by_id(resto_id: str) -> Optional[dict]:
    for resto in get_all_restaurants():
        if resto["id"] == resto_id:
            return resto
    return None

 

def validate_restaurant(resto: dict) -> list[str]:
    errors = []

    for field in REQUIRED_FIELDS:
        if field not in resto:
            errors.append(f"Champ manquant: {field}")

    if "lat" in resto and not isinstance(resto["lat"], (int, float)):
        errors.append("lat doit être un nombre")
    if "lng" in resto and not isinstance(resto["lng"], (int, float)):
        errors.append("lng doit être un nombre")
    if "avg_price" in resto and not isinstance(resto["avg_price"], (int, float)):
        errors.append("avg_price doit être un nombre")

    if "price_range" in resto and resto["price_range"] not in PRICE_RANGES:
        errors.append(f"price_range invalide: {resto['price_range']}")

    if "menu" in resto:
        if not isinstance(resto["menu"], list) or len(resto["menu"]) == 0:
            errors.append("menu doit être une liste non vide")
        else:
            for j, plat in enumerate(resto["menu"]):
                if "name" not in plat or "price" not in plat:
                    errors.append(f"Plat #{j}: 'name' et 'price' requis")

    if "lat" in resto and "lng" in resto:
        lat, lng = resto["lat"], resto["lng"]
        if not (14.5 <= lat <= 15.0 and -17.6 <= lng <= -17.1):
            errors.append(f"Coordonnées hors zone Dakar: ({lat}, {lng})")

    return errors


 

def enrich_restaurant(resto: dict) -> dict:
    """Enrichit un restaurant avec les champs calculés."""
    r = resto.copy()

    # Valeurs par défaut
    r.setdefault("rating", 3.0)
    r.setdefault("cuisine_type", [])
    r.setdefault("dietary", [])
    r.setdefault("tags", [])
    r.setdefault("description", "")
    r.setdefault("opening_hours", "")
    r.setdefault("phone", "")
    r.setdefault("image", "")

    menu_items = r.get("menu", [])
    food_items = [p for p in menu_items if "boisson" not in p.get("tags", [])]

    # ── _price_min / _price_max ──
    prices = [p["price"] for p in food_items]
    r["_price_min"] = min(prices) if prices else r["avg_price"]
    r["_price_max"] = max(prices) if prices else r["avg_price"]

    # ── _menu_count ──
    r["_menu_count"] = len(food_items)

    # ── _all_menu_tags ──
    all_menu_tags = set()
    for plat in menu_items:
        for tag in plat.get("tags", []):
            all_menu_tags.add(tag.lower())
    r["_all_menu_tags"] = list(all_menu_tags)

    # ── _all_menu_words ──
    all_menu_words = set()
    for plat in menu_items:
        for word in plat.get("name", "").lower().split():
            if len(word) > 2:
                all_menu_words.add(word)
    r["_all_menu_words"] = list(all_menu_words)

    # ── popularity (0.0 → 1.0) ──
    # Si pas fourni, simulé à partir du rating + richesse du menu
    if "popularity" not in r:
        rating_factor = (r["rating"] - 1) / 4
        menu_factor = min(1.0, r["_menu_count"] / 6)
        r["popularity"] = round(0.6 * rating_factor + 0.4 * menu_factor, 3)

    # ── dietary auto-détecté depuis les tags du menu ──
    if food_items:
        all_halal = all("halal" in p.get("tags", []) for p in food_items)
        if all_halal and "halal" not in r["dietary"]:
            r["dietary"].append("halal")

        has_veg = any("vegetarien" in p.get("tags", []) for p in food_items)
        if has_veg and "vegetarien" not in r["dietary"]:
            r["dietary"].append("vegetarien")

        has_vegan = any("vegan" in p.get("tags", []) for p in food_items)
        if has_vegan and "vegan" not in r["dietary"]:
            r["dietary"].append("vegan")

    return r



# 5. STATS


def get_stats() -> dict:
    restos = get_all_restaurants()
    zones, cuisines = {}, {}
    dietary_counts = {"halal": 0, "vegetarien": 0, "vegan": 0}
    price_ranges = {"low": 0, "mid": 0, "high": 0}

    for r in restos:
        zones[r.get("zone", "?")] = zones.get(r.get("zone", "?"), 0) + 1
        for c in r.get("cuisine_type", []):
            cuisines[c] = cuisines.get(c, 0) + 1
        for d in r.get("dietary", []):
            if d in dietary_counts:
                dietary_counts[d] += 1
        pr = r.get("price_range", "mid")
        if pr in price_ranges:
            price_ranges[pr] += 1

    return {
        "total": len(restos),
        "par_zone": zones,
        "par_cuisine": cuisines,
        "par_regime": dietary_counts,
        "par_prix": price_ranges,
        "rating_moyen": round(sum(r.get("rating", 3) for r in restos) / max(len(restos), 1), 2),
    }


if __name__ == "__main__":
    restos = load_restaurants()
    print(f"\n📊 Statistiques:")
    for k, v in get_stats().items():
        print(f"  {k}: {v}")
    print(f"\n🔍 Enrichissement:")
    for r in restos:
        print(f"  {r['name']}: popularity={r['popularity']} | prix={r['_price_min']}-{r['_price_max']} | plats={r['_menu_count']}")