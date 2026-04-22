"""
message_parser.py — Parser rapide de messages utilisateur
=========================================================
Extrait les critères de recherche à partir du texte brut.
Pas de LLM, pas de dépendance externe.
Regex + dictionnaires + règles simples.

Objectif: < 10ms par message.

Output:
{
    "is_food": True,
    "lang": "fr",
    "budget_max_fcfa": 5000,
    "dietary": ["halal"],
    "cuisine_keywords": ["senegalais"],
    "text_query": "thieboudienne",
    "zone": "Plateau",
    "mode": "budget",
}
"""

import re
import unicodedata


# ══════════════════════════════════════════════
# 1. NORMALISATION
# ══════════════════════════════════════════════

def _norm(text: str) -> str:
    """Minuscules + supprime accents."""
    nfkd = unicodedata.normalize("NFKD", text.lower())
    return "".join(c for c in nfkd if not unicodedata.combining(c))


# ══════════════════════════════════════════════
# 2. DÉTECTION DE LANGUE (scoring)
# ══════════════════════════════════════════════

_LANG_MARKERS = {
    "en": ["i need", "i want", "please", "near me", "looking for", "hungry",
           "find me", "where can", "recommend", "suggest", "any good",
           "vegetarian", "cheap", "breakfast", "lunch", "dinner", "seafood"],
    "es": ["quiero", "necesito", "cerca", "comida", "busco", "donde",
           "restaurante", "hambre", "almuerzo", "cena", "barato", "mariscos"],
    "ar": ["أريد", "مطعم", "أكل", "قريب", "أبحث", "حلال", "طعام", "جائع"],
    "wo": ["lekk", "bëgg", "ceeb", "yapp", "jën", "ndogou"],
}


def detect_language(text: str) -> str:
    t = text.lower()
    scores = {}
    for lang, markers in _LANG_MARKERS.items():
        scores[lang] = sum(1 for m in markers if m in t)
    best = max(scores, key=scores.get)
    if scores[best] == 0 or best == "wo":
        return "fr"
    return best


# ══════════════════════════════════════════════
# 3. DÉTECTION FOOD INTENT
# ══════════════════════════════════════════════

_FOOD_WORDS = {
    # FR
    "manger", "restaurant", "resto", "nourriture", "cuisine", "plat",
    "menu", "faim", "dejeuner", "diner", "snack", "halal", "vegetarien",
    "vegan", "budget", "fcfa", "cfa", "thieboudienne", "yassa", "mafe",
    "dibi", "poulet", "poisson", "viande", "grillades", "brochettes",
    "fruits de mer", "pas cher", "bon resto",
    # EN
    "eat", "food", "hungry", "meal", "lunch", "dinner", "dish",
    "cheap", "vegetarian", "seafood", "chicken", "fish", "meat",
    "recommend", "restaurant",
    # ES
    "comer", "comida", "restaurante", "hambre", "mariscos", "pollo",
    "pescado", "carne", "barato", "vegetariano", "busco", "quiero",
    # AR
    "اكل", "مطعم", "طعام", "جائع", "حلال", "دجاج", "سمك", "لحم",
    # Wolof
    "lekk", "ceeb", "yapp", "jen",
}


def is_food_related(text: str) -> bool:
    t = _norm(text)
    return any(w in t for w in _FOOD_WORDS)


# ══════════════════════════════════════════════
# 4. EXTRACTION BUDGET
# ══════════════════════════════════════════════

# Regex pour capter les montants numériques
_BUDGET_PATTERNS = [
    # "5000 FCFA", "5000 CFA", "5000 fcfa", "5 000 cfa"
    r"(\d[\d\s]*\d)\s*(?:f?cfa|francs?)",
    # "budget 5000", "max 5000"
    r"(?:budget|max|moins de|under|below|menos de)\s*(\d[\d\s]*\d)",
    # "5000" tout seul (si > 500, probablement un montant FCFA)
    r"\b(\d{3,6})\b",
    # Euros: "10 euros", "10€", "15 eur"
    r"(\d+)\s*(?:euros?|€|eur)\b",
    # Dollars: "10 dollars", "10$", "10 usd"
    r"(\d+)\s*(?:dollars?|\$|usd)\b",
]

_BUDGET_WORDS = {
    "pas cher": 4000, "cheap": 4000, "barato": 4000, "economique": 4000,
    "petit budget": 3000, "etudiant": 5000, "student": 5000,
    "on a budget": 4000, "backpacker": 3000,
}


def extract_budget(text: str) -> int | None:
    t = _norm(text)

    # Mots-clés budget implicite
    for word, amount in _BUDGET_WORDS.items():
        if word in t:
            return amount

    # Patterns regex
    for i, pattern in enumerate(_BUDGET_PATTERNS):
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            raw = match.group(1).replace(" ", "")
            try:
                amount = int(raw)
            except ValueError:
                continue

            # Conversion devises
            if i == 3:  # euros
                return amount * 655
            if i == 4:  # dollars
                return amount * 600

            # FCFA direct (filtrer les petits nombres qui ne sont pas des prix)
            if amount >= 500:
                return amount

    return None


# ══════════════════════════════════════════════
# 5. EXTRACTION DIETARY
# ══════════════════════════════════════════════

_DIETARY_MAP = {
    "halal": "halal",
    "végétarien": "vegetarien", "vegetarien": "vegetarien",
    "vegetarian": "vegetarien", "vegetariano": "vegetarien",
    "vegan": "vegan", "végane": "vegan", "vegano": "vegan",
    "sans gluten": "sans_gluten", "gluten free": "sans_gluten",
    "gluten-free": "sans_gluten", "sin gluten": "sans_gluten",
    "حلال": "halal",
}


def extract_dietary(text: str) -> list[str]:
    t = text.lower()
    found = set()
    for keyword, value in _DIETARY_MAP.items():
        if keyword in t:
            found.add(value)
    return list(found)


# ══════════════════════════════════════════════
# 6. EXTRACTION CUISINE + TEXT QUERY
# ══════════════════════════════════════════════

# Traduction multilingue → tags de la base
_CUISINE_MAP = {
    # Plats / cuisine → tags
    "thieboudienne": ("text", "thieboudienne"),
    "thiéboudienne": ("text", "thieboudienne"),
    "ceeb": ("text", "thieboudienne"),
    "ceebu jen": ("text", "thieboudienne"),
    "yassa": ("text", "yassa"),
    "mafe": ("text", "mafe"),
    "mafé": ("text", "mafe"),
    "dibi": ("text", "dibi"),
    "shawarma": ("text", "shawarma"),
    "falafel": ("text", "falafel"),
    "poulet braise": ("text", "poulet"),
    "poulet": ("text", "poulet"),
    "chicken": ("text", "poulet"),
    "pollo": ("text", "poulet"),
    "دجاج": ("text", "poulet"),
    "poisson": ("text", "poisson"),
    "fish": ("text", "poisson"),
    "pescado": ("text", "poisson"),
    "jën": ("text", "poisson"),
    "سمك": ("text", "poisson"),
    "viande": ("cuisine", "grillades"),
    "meat": ("cuisine", "grillades"),
    "carne": ("cuisine", "grillades"),
    "yapp": ("cuisine", "grillades"),
    "لحم": ("cuisine", "grillades"),
    "grillades": ("cuisine", "grillades"),
    "grill": ("cuisine", "grillades"),
    "brochettes": ("cuisine", "grillades"),
    "seafood": ("cuisine", "seafood"),
    "mariscos": ("cuisine", "seafood"),
    "fruits de mer": ("cuisine", "seafood"),
    "libanais": ("cuisine", "libanais"),
    "lebanese": ("cuisine", "libanais"),
    "senegalais": ("cuisine", "senegalais"),
    "sénégalais": ("cuisine", "senegalais"),
    "senegalese": ("cuisine", "senegalais"),
    "local": ("cuisine", "local"),
    "italien": ("cuisine", "italien"),
    "italian": ("cuisine", "italien"),
    "asiatique": ("cuisine", "asiatique"),
    "asian": ("cuisine", "asiatique"),
    "fast food": ("cuisine", "fast_food"),
    "fast-food": ("cuisine", "fast_food"),
    "street food": ("cuisine", "street_food"),
}


def extract_cuisine(text: str) -> tuple[list[str], str | None]:
    """
    Retourne (cuisine_keywords, text_query).
    cuisine_keywords = types de cuisine ("seafood", "senegalais")
    text_query = nom de plat ("thieboudienne", "poulet")
    """
    t = _norm(text)
    cuisines = set()
    text_query = None

    # Trier les clés par longueur décroissante (match "ceebu jen" avant "jen")
    for keyword in sorted(_CUISINE_MAP.keys(), key=len, reverse=True):
        if _norm(keyword) in t:
            match_type, value = _CUISINE_MAP[keyword]
            if match_type == "cuisine":
                cuisines.add(value)
            elif match_type == "text":
                if text_query is None:  # garder le premier (le plus long)
                    text_query = value

    return list(cuisines), text_query


# ══════════════════════════════════════════════
# 7. EXTRACTION ZONE / QUARTIER
# ══════════════════════════════════════════════

_ZONES = [
    "plateau", "almadies", "ngor", "medina", "médina",
    "mermoz", "sacre coeur", "sacré coeur", "point e",
    "fann", "ouakam", "yoff", "parcelles assainies",
    "grand dakar", "diamniadio", "pikine", "guediawaye",
    "liberté", "liberte", "hlm", "mamelles",
]

# Alias pour les sites JOJ
_ZONE_ALIASES = {
    "stade": "Diamniadio",
    "stadium": "Diamniadio",
    "estadio": "Diamniadio",
    "olympic": "Diamniadio",
    "olympique": "Diamniadio",
    "joj": "Diamniadio",
    "stade lss": "Plateau",
    "leopold sedar senghor": "Plateau",
}


def extract_zone(text: str) -> str | None:
    t = _norm(text)

    # Aliases d'abord (plus spécifiques)
    for alias, zone in _ZONE_ALIASES.items():
        if alias in t:
            return zone

    # Quartiers directs
    for zone in _ZONES:
        if _norm(zone) in t:
            # Retourner avec la casse correcte
            return zone.replace("é", "e").capitalize()

    return None


# ══════════════════════════════════════════════
# 8. EXTRACTION MODE
# ══════════════════════════════════════════════

_MODE_KEYWORDS = {
    "budget": ["pas cher", "pas trop cher", "cheap", "barato", "economique", "économique",
               "petit budget", "etudiant", "student", "on a budget",
               "moins cher", "abordable", "affordable"],
    "fast":   ["pres de moi", "près de moi", "near me", "cerca",
               "proche", "nearby", "walking", "a pied", "rapide",
               "quick", "fast", "presse", "pressé", "tout de suite",
               "maintenant", "now", "rush", "hurry"],
    "foodie": ["meilleur", "best", "gastronomique", "gourmet",
               "specialite", "spécialité", "authentique", "signature",
               "fine dining", "top", "delicieux", "délicieux"],
}


def extract_mode(text: str) -> str:
    t = _norm(text)
    for mode, keywords in _MODE_KEYWORDS.items():
        for kw in keywords:
            if _norm(kw) in t:
                return mode
    return "balanced"


# ══════════════════════════════════════════════
# 9. PARSER PRINCIPAL — Combine tout
# ══════════════════════════════════════════════

def parse_message(text: str, user_lat: float = None, user_lng: float = None,
                   conversation_history: list[dict] = None) -> dict:
    """
    Parse un message utilisateur et retourne un objet structuré.
    Aucun LLM impliqué. < 10ms.

    Returns:
        {
            "is_food": bool,
            "lang": str,
            "budget_max_fcfa": int | None,
            "dietary": list[str],
            "cuisine_keywords": list[str],
            "text_query": str | None,
            "zone": str | None,
            "mode": str,
            "user_lat": float | None,
            "user_lng": float | None,
        }
    """
    lang = detect_language(text)
    food = is_food_related(text)
    budget = extract_budget(text)
    dietary = extract_dietary(text)
    cuisines, text_query = extract_cuisine(text)
    zone = extract_zone(text)
    mode = extract_mode(text)

    # Enrichir avec le contexte implicite de l'historique
    if conversation_history:
        hist_dietary, hist_budget = _extract_from_history(conversation_history)
        if not dietary and hist_dietary:
            dietary = hist_dietary
        if not budget and hist_budget:
            budget = hist_budget

    return {
        "is_food": food,
        "lang": lang,
        "budget_max_fcfa": budget,
        "dietary": dietary,
        "cuisine_keywords": cuisines,
        "text_query": text_query,
        "zone": zone,
        "mode": mode,
        "user_lat": user_lat,
        "user_lng": user_lng,
    }


def _extract_from_history(history: list[dict]) -> tuple[list[str], int | None]:
    """Extrait dietary et budget implicites des messages précédents."""
    all_text = " ".join(msg.get("content", "") for msg in history[-4:])
    dietary = extract_dietary(all_text)
    budget = extract_budget(all_text)
    return dietary, budget


# ══════════════════════════════════════════════
# 10. TESTS
# ══════════════════════════════════════════════

if __name__ == "__main__":
    import time

    tests = [
        ("Je suis au Plateau, je veux manger local, budget 5000 FCFA, halal",
         {"lang": "fr", "is_food": True, "budget": 5000, "dietary": ["halal"],
          "mode": "balanced", "zone": "Plateau"}),

        ("I need a vegetarian restaurant near me, under 8000 CFA",
         {"lang": "en", "is_food": True, "budget": 8000, "dietary": ["vegetarien"],
          "mode": "fast"}),

        ("Quiero comer mariscos, cerca de aquí",
         {"lang": "es", "is_food": True, "cuisine": ["seafood"], "mode": "fast"}),

        ("Je cherche un bon thiéboudienne pas trop cher",
         {"lang": "fr", "is_food": True, "text": "thieboudienne", "mode": "budget"}),

        ("Je suis étudiant, je veux manger halal",
         {"lang": "fr", "is_food": True, "budget": 5000, "dietary": ["halal"],
          "mode": "budget"}),

        ("Bëgg lekk ceeb boo neex",
         {"lang": "fr", "is_food": True, "text": "thieboudienne"}),

        ("Bonjour, comment ça marche ?",
         {"lang": "fr", "is_food": False}),

        ("I want grilled chicken near the stadium, 10 euros max",
         {"lang": "en", "is_food": True, "budget": 6550, "text": "poulet",
          "zone": "Diamniadio"}),

        ("Restaurant libanais halal vers Almadies",
         {"lang": "fr", "is_food": True, "dietary": ["halal"],
          "cuisine": ["libanais"], "zone": "Almadies"}),
    ]

    passed = 0
    failed = 0

    print("🧪 TEST PARSER RAPIDE")
    print("=" * 65)

    for text, expected in tests:
        t0 = time.time()
        result = parse_message(text)
        elapsed_ms = (time.time() - t0) * 1000

        errors = []
        if "lang" in expected and result["lang"] != expected["lang"]:
            errors.append(f"lang: {result['lang']} ≠ {expected['lang']}")
        if "is_food" in expected and result["is_food"] != expected["is_food"]:
            errors.append(f"food: {result['is_food']} ≠ {expected['is_food']}")
        if "budget" in expected and result["budget_max_fcfa"] != expected["budget"]:
            errors.append(f"budget: {result['budget_max_fcfa']} ≠ {expected['budget']}")
        if "dietary" in expected and sorted(result["dietary"]) != sorted(expected["dietary"]):
            errors.append(f"dietary: {result['dietary']} ≠ {expected['dietary']}")
        if "cuisine" in expected and sorted(result["cuisine_keywords"]) != sorted(expected["cuisine"]):
            errors.append(f"cuisine: {result['cuisine_keywords']} ≠ {expected['cuisine']}")
        if "text" in expected and result["text_query"] != expected["text"]:
            errors.append(f"text: {result['text_query']} ≠ {expected['text']}")
        if "zone" in expected and result["zone"] != expected["zone"]:
            errors.append(f"zone: {result['zone']} ≠ {expected['zone']}")
        if "mode" in expected and result["mode"] != expected["mode"]:
            errors.append(f"mode: {result['mode']} ≠ {expected['mode']}")

        if errors:
            failed += 1
            print(f"  ❌ \"{text[:50]}...\" ({elapsed_ms:.1f}ms)")
            for e in errors:
                print(f"       {e}")
        else:
            passed += 1
            print(f"  ✅ \"{text[:50]}...\" ({elapsed_ms:.1f}ms)")

    # Performance test
    print(f"\n⏱️ Performance test (1000 iterations):")
    t0 = time.time()
    for _ in range(1000):
        parse_message("Je veux manger du thiéboudienne halal pas cher au Plateau")
    total = (time.time() - t0) * 1000
    print(f"  1000 parses en {total:.1f}ms → {total/1000:.2f}ms/parse")

    print(f"\n{'=' * 65}")
    print(f"  {passed} ✅ / {failed} ❌")
    print(f"{'=' * 65}")