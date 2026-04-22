"""
search_service.py — Moteur de recherche & scoring v3
=====================================================
Optimisations:
- _search_blob pré-calculé au chargement (1 seule fois)
- Distance normalisée dynamiquement (basée sur max_distance_km, pas 5km fixe)
- Score garanti [0, 1] avec clamp
- Popularité calculée avec formule configurable
- Text matching sans boucles inutiles (set intersection)
- Modes de recherche avec pondérations explicites
"""

import math
import unicodedata
from typing import Optional
from data_store import get_all_restaurants


# ══════════════════════════════════════════════
# 1. UTILITAIRES
# ══════════════════════════════════════════════

def normalize_text(text: str) -> str:
    """Supprime accents + minuscules. 'Thiéboudienne' → 'thieboudienne'"""
    nfkd = unicodedata.normalize("NFKD", text.lower())
    return "".join(c for c in nfkd if not unicodedata.combining(c))


def haversine_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Distance en km entre deux points GPS."""
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)
    a = (math.sin(dlat / 2) ** 2
         + math.cos(math.radians(lat1))
         * math.cos(math.radians(lat2))
         * math.sin(dlng / 2) ** 2)
    return round(R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)), 2)


def clamp(value: float, lo: float = 0.0, hi: float = 1.0) -> float:
    """Garantit que la valeur reste dans [lo, hi]."""
    return max(lo, min(hi, value))


# ══════════════════════════════════════════════
# 2. SEARCH BLOB — Pré-calculé au chargement
# ══════════════════════════════════════════════
# Au lieu de recalculer les "sacs de mots" à chaque recherche,
# on les pré-calcule UNE FOIS et on les stocke sur le resto.

_blobs_built = False


def _ensure_blobs():
    """Construit les search blobs si pas encore fait."""
    global _blobs_built
    if _blobs_built:
        return
    for resto in get_all_restaurants():
        if "_search_blob" not in resto:
            _build_search_blob(resto)
    _blobs_built = True


def _build_search_blob(resto: dict):
    """
    Pré-calcule 4 sets de mots normalisés pour chaque restaurant.
    Stockés directement sur le dict resto (pas de copie).

    Zones (par poids décroissant):
      dish_names  (1.0) — noms des plats
      resto_name  (0.7) — nom du restaurant
      dish_descs  (0.4) — descriptions des plats
      resto_desc  (0.2) — description du restaurant + tags
    """
    dish_names = set()
    dish_descs = set()
    resto_name_words = set()
    resto_desc_words = set()

    # Nom du restaurant
    for w in normalize_text(resto.get("name", "")).split():
        if len(w) > 2:
            resto_name_words.add(w)

    # Description du restaurant + tags + cuisine_type
    desc_blob = normalize_text(resto.get("description", ""))
    for w in desc_blob.split():
        if len(w) > 2:
            resto_desc_words.add(w)
    for tag in resto.get("tags", []):
        resto_desc_words.add(normalize_text(tag))
    for ct in resto.get("cuisine_type", []):
        resto_desc_words.add(normalize_text(ct))
    # Ajouter les menu tags pré-calculés
    for t in resto.get("_all_menu_tags", []):
        resto_desc_words.add(normalize_text(t))

    # Plats
    for plat in resto.get("menu", []):
        for w in normalize_text(plat.get("name", "")).split():
            if len(w) > 2:
                dish_names.add(w)
        for w in normalize_text(plat.get("description", "")).split():
            if len(w) > 2:
                dish_descs.add(w)

    resto["_search_blob"] = {
        "dish_names": dish_names,
        "resto_name": resto_name_words,
        "dish_descs": dish_descs,
        "resto_desc": resto_desc_words,
    }


# ══════════════════════════════════════════════
# 3. MODES DE RECHERCHE
# ══════════════════════════════════════════════

# Pondérations: (rating, distance, budget, menu, text_match, popularity)
MODES = {
    "balanced": (0.35, 0.25, 0.15, 0.10, 0.10, 0.05),
    "budget":   (0.20, 0.15, 0.40, 0.05, 0.10, 0.10),
    "foodie":   (0.30, 0.10, 0.05, 0.25, 0.25, 0.05),
    "fast":     (0.15, 0.50, 0.10, 0.05, 0.10, 0.10),
}

MODES_NO_GEO = {
    "balanced": (0.45, 0.00, 0.25, 0.10, 0.15, 0.05),
    "budget":   (0.20, 0.00, 0.50, 0.05, 0.15, 0.10),
    "foodie":   (0.35, 0.00, 0.05, 0.30, 0.25, 0.05),
    "fast":     (0.40, 0.00, 0.20, 0.15, 0.15, 0.10),
}


# ══════════════════════════════════════════════
# 4. RECHERCHE PRINCIPALE
# ══════════════════════════════════════════════

def search_restaurants(
    user_lat: Optional[float] = None,
    user_lng: Optional[float] = None,
    max_distance_km: float = 5.0,
    budget_max_fcfa: Optional[int] = None,
    dietary: Optional[list[str]] = None,
    cuisine_keywords: Optional[list[str]] = None,
    text_query: Optional[str] = None,
    zone: Optional[str] = None,
    mode: str = "balanced",
    top_n: int = 3,
) -> list[dict]:
    """
    Pipeline: filtrer → scorer → trier → top N.
    """
    _ensure_blobs()

    restos = get_all_restaurants()
    results = []
    has_geo = user_lat is not None and user_lng is not None

    for resto in restos:

        # ── FILTRES (éliminatoires) ──

        # Dietary
        if dietary:
            if not all(d in resto.get("dietary", []) for d in dietary):
                continue

        # Budget
        if budget_max_fcfa is not None:
            if resto.get("_price_min", 0) > budget_max_fcfa:
                continue

        # Distance
        distance = None
        if has_geo:
            distance = haversine_km(user_lat, user_lng, resto["lat"], resto["lng"])
            if distance > max_distance_km:
                continue

        # Zone
        if zone:
            if normalize_text(zone) not in normalize_text(resto.get("zone", "")):
                continue

        # Cuisine (souple: au moins 1 match)
        if cuisine_keywords:
            all_tags = set(c.lower() for c in resto.get("cuisine_type", []))
            all_tags.update(t.lower() for t in resto.get("_all_menu_tags", []))
            if not any(kw.lower() in all_tags for kw in cuisine_keywords):
                continue

        # Text query
        text_score = 0.5  # neutre
        if text_query:
            text_score = compute_text_match(text_query, resto)
            if text_score == 0:
                continue

        # ── SCORING ──
        result = resto.copy()
        result["distance_km"] = distance

        explanation = compute_score(
            resto=result,
            text_match_score=text_score,
            has_geo=has_geo,
            budget_max=budget_max_fcfa,
            max_distance_km=max_distance_km,
            mode=mode,
        )
        result["score"] = explanation["total"]
        result["explanation"] = explanation
        results.append(result)

    results.sort(key=lambda r: r["score"], reverse=True)
    return results[:top_n]


# ══════════════════════════════════════════════
# 5. TEXT MATCHING — Optimisé avec sets pré-calculés
# ══════════════════════════════════════════════

TEXT_WEIGHTS = {
    "dish_names": 1.0,
    "resto_name": 0.7,
    "dish_descs": 0.4,
    "resto_desc": 0.2,
}


def compute_text_match(query: str, resto: dict) -> float:
    """
    Matching pondéré utilisant les search blobs pré-calculés.
    """
    _ensure_blobs()

    query_words = [normalize_text(w) for w in query.split() if len(w) > 2]
    if not query_words:
        return 1.0

    blob = resto.get("_search_blob")
    if not blob:
        return 0.0

    max_possible = len(query_words) * TEXT_WEIGHTS["dish_names"]
    total_weight = 0.0

    for qw in query_words:
        best = 0.0

        # Vérifier dans chaque zone (du plus pondéré au moins pondéré)
        # Utiliser la recherche par substring dans le set
        for zone_name, weight in TEXT_WEIGHTS.items():
            if best >= weight:
                break  # pas la peine de chercher dans une zone de poids inférieur
            word_set = blob[zone_name]
            # Match exact ou partiel (qw contenu dans un mot du set ou l'inverse)
            if any(qw in w or w in qw for w in word_set):
                best = weight
                break

        total_weight += best

    return round(total_weight / max_possible, 4) if max_possible > 0 else 0.0


# ══════════════════════════════════════════════
# 6. SCORING COMPOSITE — Explicable + Clampé
# ══════════════════════════════════════════════

def compute_score(
    resto: dict,
    text_match_score: float = 0.5,
    has_geo: bool = False,
    budget_max: Optional[int] = None,
    max_distance_km: float = 5.0,
    mode: str = "balanced",
) -> dict:
    """
    Calcule le score composite avec explicabilité.
    Tous les sous-scores sont clampés [0, 1].
    La distance est normalisée par rapport à max_distance_km (pas 5km fixe).
    """
    if mode not in MODES:
        mode = "balanced"

    weights = MODES[mode] if has_geo else MODES_NO_GEO[mode]
    w_rat, w_dist, w_bud, w_menu, w_text, w_pop = weights

    # ── Rating (1→5 ⇒ 0→1) ──
    rating = resto.get("rating", 3.0)
    rating_score = clamp((rating - 1) / 4)

    # ── Distance (normalisée par max_distance_km, pas fixe) ──
    distance = resto.get("distance_km")
    distance_score = 0.5
    proximity_boost = False

    if distance is not None:
        # Normalisation dynamique: 0km → 1.0, max_km → 0.0
        distance_score = clamp(1 - (distance / max_distance_km))

        # Boost: < 500m → bonus de +0.15 (pour favoriser le "juste à côté")
        if distance < 0.5:
            distance_score = clamp(distance_score + 0.15)
            proximity_boost = True
        # Petit boost: < 1km → bonus de +0.05
        elif distance < 1.0:
            distance_score = clamp(distance_score + 0.05)
            proximity_boost = True

    # ── Budget ──
    budget_score = 0.5
    if budget_max is not None and budget_max > 0:
        price_min = resto.get("_price_min", resto.get("avg_price", 5000))
        ratio = price_min / budget_max

        if ratio <= 0.5:
            budget_score = 1.0
        elif ratio <= 0.8:
            budget_score = 0.85
        elif ratio <= 1.0:
            budget_score = 0.65
        elif ratio <= 1.3:
            budget_score = 0.3
        else:
            budget_score = 0.1

    # ── Richesse du menu ──
    menu_count = resto.get("_menu_count", 0)
    menu_score = clamp(menu_count / 6)

    # ── Popularité ──
    # Formule: 50% rating normalisé + 30% richesse menu + 20% gamme prix
    # (proxy réaliste en l'absence de vraies données de reviews)
    popularity = resto.get("popularity")
    if popularity is None:
        price_range_bonus = {"low": 0.6, "mid": 0.5, "high": 0.4}.get(
            resto.get("price_range", "mid"), 0.5)
        popularity = clamp(0.5 * rating_score + 0.3 * menu_score + 0.2 * price_range_bonus)
    popularity_score = clamp(popularity)

    # ── Score total ──
    total = (
        w_rat  * rating_score
        + w_dist * distance_score
        + w_bud  * budget_score
        + w_menu * menu_score
        + w_text * text_match_score
        + w_pop  * popularity_score
    )
    total = clamp(total)

    return {
        "total": round(total, 4),
        "mode": mode,
        "rating": {
            "score": round(rating_score, 4),
            "weight": w_rat,
            "weighted": round(w_rat * rating_score, 4),
            "stars": rating,
        },
        "distance": {
            "score": round(distance_score, 4),
            "weight": w_dist,
            "weighted": round(w_dist * distance_score, 4),
            "km": distance,
            "boost": proximity_boost,
        },
        "budget": {
            "score": round(budget_score, 4),
            "weight": w_bud,
            "weighted": round(w_bud * budget_score, 4),
            "price_min": resto.get("_price_min"),
            "budget_max": budget_max,
        },
        "menu": {
            "score": round(menu_score, 4),
            "weight": w_menu,
            "weighted": round(w_menu * menu_score, 4),
            "count": menu_count,
        },
        "text_match": {
            "score": round(text_match_score, 4),
            "weight": w_text,
            "weighted": round(w_text * text_match_score, 4),
        },
        "popularity": {
            "score": round(popularity_score, 4),
            "weight": w_pop,
            "weighted": round(w_pop * popularity_score, 4),
        },
    }


# ══════════════════════════════════════════════
# 7. TESTS
# ══════════════════════════════════════════════

def _bar(score: float) -> str:
    n = int(score * 10)
    return "█" * n + "░" * (10 - n)


if __name__ == "__main__":
    from data_store import load_restaurants
    import time

    load_restaurants()

    print("=" * 65)
    print("TEST 1: Halal, budget 5000, Plateau — balanced")
    print("=" * 65)
    t0 = time.time()
    for r in search_restaurants(
        user_lat=14.6937, user_lng=-17.4441,
        budget_max_fcfa=5000, dietary=["halal"], mode="balanced",
    ):
        exp = r["explanation"]
        boost = " 🚀" if exp["distance"]["boost"] else ""
        print(f"  {r['name']} — score={r['score']} — {r['distance_km']}km{boost}")
        for k in ["rating", "distance", "budget", "menu", "text_match", "popularity"]:
            v = exp[k]
            print(f"    {k:12s} {_bar(v['score'])} {v['score']:.2f} × {v['weight']:.2f} = {v['weighted']:.4f}")
        print()
    print(f"  ⏱️ {(time.time()-t0)*1000:.1f}ms\n")

    print("=" * 65)
    print("TEST 2: Mode budget — même requête")
    print("=" * 65)
    for r in search_restaurants(
        user_lat=14.6937, user_lng=-17.4441,
        budget_max_fcfa=5000, dietary=["halal"], mode="budget",
    ):
        print(f"  {r['name']} — score={r['score']} — mode={r['explanation']['mode']}")

    print(f"\n{'=' * 65}")
    print("TEST 3: Text match 'thieboudienne' — foodie")
    print("=" * 65)
    for r in search_restaurants(text_query="thieboudienne", mode="foodie"):
        print(f"  {r['name']} — score={r['score']} — text={r['explanation']['text_match']['score']}")

    print(f"\n{'=' * 65}")
    print("TEST 4: Distance dynamique — rayon 15km vs 3km")
    print("=" * 65)
    r15 = search_restaurants(user_lat=14.69, user_lng=-17.46, max_distance_km=15, top_n=5)
    r3 = search_restaurants(user_lat=14.69, user_lng=-17.46, max_distance_km=3, top_n=5)
    print(f"  Rayon 15km: {len(r15)} résultats")
    for r in r15:
        print(f"    {r['name']} — {r['distance_km']}km — dist_score={r['explanation']['distance']['score']}")
    print(f"  Rayon 3km: {len(r3)} résultats")
    for r in r3:
        print(f"    {r['name']} — {r['distance_km']}km — dist_score={r['explanation']['distance']['score']}")

    print(f"\n{'=' * 65}")
    print("TEST 5: Score clamping — vérification [0, 1]")
    print("=" * 65)
    all_restos = search_restaurants(top_n=10)
    all_ok = True
    for r in all_restos:
        s = r["score"]
        if s < 0 or s > 1:
            print(f"  ❌ {r['name']} score={s} HORS LIMITES")
            all_ok = False
        exp = r["explanation"]
        for k in ["rating", "distance", "budget", "menu", "text_match", "popularity"]:
            sub = exp[k]["score"]
            if sub < 0 or sub > 1:
                print(f"  ❌ {r['name']}.{k}={sub} HORS LIMITES")
                all_ok = False
    if all_ok:
        print("   Tous les scores sont dans [0, 1]")