"""
test_local.py — Test complet du moteur SANS clé Groq
=====================================================
Exécuter: python test_local.py

Teste: chargement, validation, enrichissement, recherche,
scoring, modes, text matching, boost proximité, explicabilité.
"""

import json
from data_store import load_restaurants, get_all_restaurants, get_restaurant_by_id, get_stats
from search_service import search_restaurants, haversine_km, normalize_text, compute_text_match


PASSED = 0
FAILED = 0


def test(name: str, condition: bool, detail: str = ""):
    global PASSED, FAILED
    if condition:
        PASSED += 1
        print(f"  ✅ {name}")
    else:
        FAILED += 1
        print(f"  ❌ {name} — {detail}")


def run_tests():
    global PASSED, FAILED

    # ══════════════════════════════════════════
    print("\n🔹 1. CHARGEMENT & VALIDATION")
    # ══════════════════════════════════════════
    restos = load_restaurants()

    test("5 restaurants chargés", len(restos) == 5, f"got {len(restos)}")

    for r in restos:
        test(f"{r['name']} a un ID", "id" in r)
        test(f"{r['name']} a des coordonnées GPS valides",
             14.5 <= r["lat"] <= 15.0 and -17.6 <= r["lng"] <= -17.1)

    # ══════════════════════════════════════════
    print("\n🔹 2. ENRICHISSEMENT")
    # ══════════════════════════════════════════
    for r in restos:
        test(f"{r['name']} — _price_min calculé", "_price_min" in r, "champ manquant")
        test(f"{r['name']} — _price_max calculé", "_price_max" in r)
        test(f"{r['name']} — _menu_count calculé", "_menu_count" in r)
        test(f"{r['name']} — _all_menu_tags calculé", "_all_menu_tags" in r)
        test(f"{r['name']} — _all_menu_words calculé", "_all_menu_words" in r)
        test(f"{r['name']} — popularity calculé", "popularity" in r)
        test(f"{r['name']} — popularity entre 0 et 1",
             0 <= r["popularity"] <= 1, f"got {r['popularity']}")

    # Vérifier l'auto-détection dietary
    ami = get_restaurant_by_id("resto_004")
    test("Chez Ami détecté végétarien (auto)", "vegetarien" in ami["dietary"])
    test("Chez Ami détecté vegan (auto)", "vegan" in ami["dietary"])

    calebasse = get_restaurant_by_id("resto_001")
    test("La Calebasse détectée halal (auto)", "halal" in calebasse["dietary"])

    # ══════════════════════════════════════════
    print("\n🔹 3. UTILITAIRES")
    # ══════════════════════════════════════════

    # Haversine
    d = haversine_km(14.6937, -17.4441, 14.6902, -17.4608)
    test(f"Haversine Plateau→Point E ≈ 1.8 km", 1.5 < d < 2.2, f"got {d}")

    # Normalisation
    test("normalize: Thiéboudienne → thieboudienne",
         normalize_text("Thiéboudienne") == "thieboudienne")
    test("normalize: Café → cafe",
         normalize_text("Café") == "cafe")
    test("normalize: Méditerranéen → mediterraneen",
         normalize_text("Méditerranéen") == "mediterraneen")

    # ══════════════════════════════════════════
    print("\n🔹 4. TEXT MATCHING PONDÉRÉ")
    # ══════════════════════════════════════════

    # Match dans nom du plat = score élevé
    score_plat = compute_text_match("thieboudienne", calebasse)
    test(f"'thieboudienne' matche La Calebasse (plat)", score_plat > 0.8, f"got {score_plat}")

    # Match dans nom du restaurant = score moyen
    bazoff = get_restaurant_by_id("resto_005")
    score_nom = compute_text_match("bazoff", bazoff)
    test(f"'bazoff' matche Bazoff (nom resto)", score_nom > 0.5, f"got {score_nom}")

    # Match dans description = score faible
    score_desc = compute_text_match("charbon", bazoff)  # "braisé au charbon de bois"
    test(f"'charbon' matche Bazoff (description plat)", score_desc > 0, f"got {score_desc}")
    test(f"score nom > score desc", score_nom > score_desc,
         f"nom={score_nom} desc={score_desc}")

    # Pas de match = 0
    score_zero = compute_text_match("sushi pizza", calebasse)
    test(f"'sushi pizza' ne matche pas La Calebasse", score_zero == 0, f"got {score_zero}")

    # ══════════════════════════════════════════
    print("\n🔹 5. RECHERCHE — FILTRES")
    # ══════════════════════════════════════════

    # Halal filtre
    r_halal = search_restaurants(dietary=["halal"], top_n=10)
    test("Filtre halal: tous les résultats sont halal",
         all("halal" in r["dietary"] for r in r_halal))

    # Végétarien filtre
    r_veg = search_restaurants(dietary=["vegetarien"], top_n=10)
    test("Filtre végétarien: 2 résultats",
         len(r_veg) == 2, f"got {len(r_veg)}")
    test("Filtre végétarien: Lagon Bleu + Chez Ami",
         set(r["name"] for r in r_veg) == {"Le Lagon Bleu", "Chez Ami"})

    # Budget filtre
    r_cheap = search_restaurants(budget_max_fcfa=3000, top_n=10)
    test("Filtre budget 3000: tous ont prix_min <= 3000",
         all(r["_price_min"] <= 3000 for r in r_cheap),
         f"prix: {[r['_price_min'] for r in r_cheap]}")

    # Distance filtre
    r_close = search_restaurants(user_lat=14.6937, user_lng=-17.4441, max_distance_km=2, top_n=10)
    test("Filtre 2km depuis Plateau: tous < 2km",
         all(r["distance_km"] <= 2 for r in r_close),
         f"distances: {[r['distance_km'] for r in r_close]}")

    # Zone filtre
    r_zone = search_restaurants(zone="Almadies", top_n=10)
    test("Filtre zone Almadies: 1 résultat (Lagon Bleu)",
         len(r_zone) == 1 and r_zone[0]["name"] == "Le Lagon Bleu")

    # Cuisine filtre
    r_cuis = search_restaurants(cuisine_keywords=["seafood"], top_n=10)
    test("Filtre cuisine seafood: Lagon Bleu",
         any(r["name"] == "Le Lagon Bleu" for r in r_cuis))

    # Text query filtre
    r_text = search_restaurants(text_query="thieboudienne", top_n=10)
    test("Texte 'thieboudienne': trouve La Calebasse + Bazoff",
         len(r_text) >= 2,
         f"got {[r['name'] for r in r_text]}")

    # ══════════════════════════════════════════
    print("\n🔹 6. SCORING — MODES")
    # ══════════════════════════════════════════

    params = dict(user_lat=14.6937, user_lng=-17.4441, budget_max_fcfa=5000, dietary=["halal"])

    r_balanced = search_restaurants(**params, mode="balanced")
    r_budget = search_restaurants(**params, mode="budget")
    r_fast = search_restaurants(**params, mode="fast")

    test("Mode balanced: #1 = La Calebasse",
         r_balanced[0]["name"] == "La Calebasse Dorée",
         f"got {r_balanced[0]['name']}")

    test("Mode budget: #1 = Dibiterie (moins cher)",
         r_budget[0]["name"] == "Dibiterie Serigne Fallou",
         f"got {r_budget[0]['name']}")

    test("Mode fast: #1 = La Calebasse (0km)",
         r_fast[0]["name"] == "La Calebasse Dorée",
         f"got {r_fast[0]['name']}")

    # Vérifier que les pondérations changent
    test("Mode budget: poids budget = 0.40",
         r_budget[0]["explanation"]["budget"]["weight"] == 0.40,
         f"got {r_budget[0]['explanation']['budget']['weight']}")

    test("Mode fast: poids distance = 0.50",
         r_fast[0]["explanation"]["distance"]["weight"] == 0.50,
         f"got {r_fast[0]['explanation']['distance']['weight']}")

    # ══════════════════════════════════════════
    print("\n🔹 7. EXPLICABILITÉ")
    # ══════════════════════════════════════════

    r = r_balanced[0]
    exp = r["explanation"]

    test("Explanation contient 'total'", "total" in exp)
    test("Explanation contient 'mode'", "mode" in exp)

    for key in ["rating", "distance", "budget", "menu", "text_match", "popularity"]:
        test(f"Explanation contient '{key}'", key in exp, f"missing {key}")
        sub = exp[key]
        test(f"  {key} a 'score'", "score" in sub)
        test(f"  {key} a 'weight'", "weight" in sub)
        test(f"  {key} a 'weighted'", "weighted" in sub)

    test("Explanation rating contient 'stars'", "stars" in exp["rating"])
    test("Explanation distance contient 'km'", "km" in exp["distance"])
    test("Explanation distance contient 'boost'", "boost" in exp["distance"])
    test("Explanation budget contient 'price_min'", "price_min" in exp["budget"])

    # Vérifier que total ≈ somme des weighted
    total_calc = sum(exp[k]["weighted"] for k in ["rating", "distance", "budget", "menu", "text_match", "popularity"])
    test(f"Total ({exp['total']}) ≈ somme des weighted ({round(total_calc, 4)})",
         abs(exp["total"] - total_calc) < 0.001,
         f"diff={abs(exp['total'] - total_calc)}")

    # ══════════════════════════════════════════
    print("\n🔹 8. BOOST PROXIMITÉ")
    # ══════════════════════════════════════════

    # Position ultra-proche de Bazoff (20m)
    r_boost = search_restaurants(user_lat=14.6903, user_lng=-17.4609, top_n=5)
    bazoff_result = next((r for r in r_boost if r["name"] == "Bazoff"), None)

    test("Bazoff trouvé à proximité", bazoff_result is not None)
    if bazoff_result:
        test("Bazoff distance < 0.1 km",
             bazoff_result["distance_km"] < 0.1,
             f"got {bazoff_result['distance_km']}")
        test("Bazoff boost activé",
             bazoff_result["explanation"]["distance"]["boost"] is True)
        test("Bazoff distance_score boosté > 1.0 (cappé à 1.0)",
             bazoff_result["explanation"]["distance"]["score"] == 1.0)

    # ══════════════════════════════════════════
    print("\n🔹 9. STATS")
    # ══════════════════════════════════════════

    stats = get_stats()
    test("Stats: total = 5", stats["total"] == 5)
    test("Stats: 5 zones", len(stats["par_zone"]) == 5)
    test("Stats: halal >= 5", stats["par_regime"]["halal"] >= 5)

    # ══════════════════════════════════════════
    print("\n🔹 10. GET BY ID")
    # ══════════════════════════════════════════

    r_id = get_restaurant_by_id("resto_003")
    test("get_restaurant_by_id('resto_003') = Dibiterie",
         r_id is not None and r_id["name"] == "Dibiterie Serigne Fallou")

    r_none = get_restaurant_by_id("resto_999")
    test("get_restaurant_by_id('resto_999') = None", r_none is None)

    # ══════════════════════════════════════════
    print(f"\n{'=' * 50}")
    print(f"  RÉSULTATS: {PASSED}  passés / {FAILED} ❌ échoués")
    print(f"{'=' * 50}")

    return FAILED == 0


if __name__ == "__main__":
    success = run_tests()
    exit(0 if success else 1)