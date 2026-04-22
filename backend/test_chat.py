"""
test_chat.py — Test du chatbot v3 avec Groq API
================================================
Exécuter: python test_chat.py

Teste:
- Tool calling forcé (plus d'hallucination)
- Multilingue: FR / EN / ES / Wolof
- Contexte implicite (étudiant → budget)
- Fallback si 0 résultats
- Performance (temps de réponse)
- Debug logs
"""

import asyncio
import os
import sys
import time
from dotenv import load_dotenv
load_dotenv()

from data_store import load_restaurants
from chat_service import process_chat


SCENARIOS = [
    {
        "name": "🇫🇷 Francophone — halal, budget 5000, géoloc",
        "message": "Je suis au Plateau, je veux manger local, budget 5000 FCFA, halal",
        "user_lat": 14.6937, "user_lng": -17.4441,
        "expect_restos": True,
        "expect_lang": "fr",
    },
    {
        "name": "🇬🇧 Anglophone — vegetarian near me",
        "message": "I need a vegetarian restaurant near me, under 8000 CFA",
        "user_lat": 14.6937, "user_lng": -17.4441,
        "expect_restos": True,
        "expect_lang": "en",
    },
    {
        "name": "🇪🇸 Hispanophone — mariscos (seafood)",
        "message": "Quiero comer mariscos, cerca de aquí",
        "user_lat": 14.7000, "user_lng": -17.4700,
        "expect_restos": True,
        "expect_lang": "es",
    },
    {
        "name": "🍚 Recherche plat — thiéboudienne",
        "message": "Je cherche un bon thiéboudienne pas trop cher",
        "user_lat": None, "user_lng": None,
        "expect_restos": True,
        "expect_lang": "fr",
    },
    {
        "name": "🎓 Contexte implicite — étudiant (→ mode budget)",
        "message": "Je suis étudiant, je veux manger halal pas trop cher",
        "user_lat": 14.6937, "user_lng": -17.4441,
        "expect_restos": True,
        "expect_lang": "fr",
    },
    {
        "name": "🇸🇳 Wolof — ceeb (→ thiéboudienne)",
        "message": "Bëgg lekk ceeb boo neex",
        "user_lat": 14.6900, "user_lng": -17.4600,
        "expect_restos": True,
        "expect_lang": "fr",
    },
    {
        "name": "💬 Conversation — pas de food",
        "message": "Bonjour, comment ça marche ton appli ?",
        "user_lat": None, "user_lng": None,
        "expect_restos": False,
        "expect_lang": "fr",
    },
]


async def run_scenario(scenario: dict) -> dict:
    print(f"\n{'─' * 65}")
    print(f"  {scenario['name']}")
    print(f"  ✉️  \"{scenario['message']}\"")
    print(f"{'─' * 65}")

    t0 = time.time()
    result = await process_chat(
        message=scenario["message"],
        user_lat=scenario.get("user_lat"),
        user_lng=scenario.get("user_lng"),
    )
    elapsed = time.time() - t0

    # Réponse
    print(f"\n  🤖 [{result['detected_language']}] ({elapsed:.2f}s):")
    for line in result["reply"].split("\n"):
        print(f"     {line}")

    # Restaurants
    restos = result.get("restaurants", [])
    if restos:
        print(f"\n  📍 {len(restos)} restaurant(s):")
        for r in restos:
            dist = f"{r.get('distance_km')} km" if r.get("distance_km") is not None else "N/A"
            exp = r.get("explanation", {})
            mode = exp.get("mode", "?")
            print(f"     • {r['name']} ({r['zone']}) — {dist} — score={r.get('score')} [{mode}]")

    # Debug info
    debug = result.get("debug", {})
    if debug:
        print(f"\n  🔧 Debug: food={debug.get('food_related')} | "
              f"time={debug.get('total_time_s')}s | "
              f"implicit={debug.get('implicit_context', {})}")

    # Vérifications
    checks = {"passed": True, "issues": []}

    if scenario["expect_restos"] and len(restos) == 0:
        checks["passed"] = False
        checks["issues"].append("❌ Restaurants attendus mais non retournés")

    if not scenario["expect_restos"] and len(restos) > 0:
        checks["issues"].append("⚠️ Restaurants retournés (non attendus, mais OK)")

    if result["detected_language"] != scenario.get("expect_lang", "fr"):
        checks["issues"].append(
            f"⚠️ Langue: attendu={scenario['expect_lang']}, détecté={result['detected_language']}")

    if elapsed > 3.0:
        checks["issues"].append(f"⚠️ Lent: {elapsed:.2f}s (objectif < 1.5s)")

    # Vérifier que les noms des restos existent vraiment dans la base
    from data_store import get_restaurant_by_id
    for r in restos:
        if not get_restaurant_by_id(r["id"]):
            checks["passed"] = False
            checks["issues"].append(f"❌ HALLUCINATION: restaurant '{r['name']}' n'existe pas dans la base!")

    for issue in checks["issues"]:
        print(f"\n  {issue}")

    return {
        "name": scenario["name"],
        "passed": checks["passed"],
        "time": elapsed,
        "restos": len(restos),
    }


async def main():
    if not os.environ.get("GROQ_API_KEY"):
        print("❌ GROQ_API_KEY non définie.")
        print("   → Ajouter dans le fichier .env ou: GROQ_API_KEY=gsk_xxx python test_chat.py")
        sys.exit(1)

    load_restaurants()

    print("🧪 TEST CHATBOT v3 — Llama 3.1 8B via Groq")
    print("=" * 65)

    results = []
    for scenario in SCENARIOS:
        try:
            r = await run_scenario(scenario)
            results.append(r)
        except Exception as e:
            print(f"\n  ❌ ERREUR: {e}")
            import traceback
            traceback.print_exc()
            results.append({"name": scenario["name"], "passed": False, "time": 0, "restos": 0})

    # Résumé
    print(f"\n{'═' * 65}")
    print(f"  RÉSULTATS")
    print(f"{'═' * 65}")

    total = len(results)
    ok = sum(1 for r in results if r["passed"])
    avg_time = sum(r["time"] for r in results) / max(total, 1)

    for r in results:
        icon = "✅" if r["passed"] else "❌"
        print(f"  {icon} {r['name']} — {r['time']:.2f}s — {r['restos']} resto(s)")

    print(f"\n  {ok}/{total} passés | Temps moyen: {avg_time:.2f}s")
    print(f"{'═' * 65}")


if __name__ == "__main__":
    asyncio.run(main())