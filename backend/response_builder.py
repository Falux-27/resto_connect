"""
response_builder.py — Générateur de réponses sans LLM
======================================================
Construit des réponses multilingues à partir de templates.
Le LLM n'est PAS nécessaire pour générer une bonne réponse.

Objectif: réponse naturelle, personnalisée, en < 1ms.
"""


# ══════════════════════════════════════════════
# 1. TEMPLATES DE RÉPONSES
# ══════════════════════════════════════════════

_GREETINGS = {
    "fr": [
        "Voici {n} option{s} pour toi ! 🍽️",
        "J'ai trouvé {n} restaurant{s} qui correspond{s2} ! 🍽️",
        "Voici mes {n} meilleure{s} suggestion{s} ! 🍽️",
    ],
    "en": [
        "Here {are} {n} great option{s} for you! 🍽️",
        "I found {n} restaurant{s} matching your request! 🍽️",
        "Here {are} my top {n} pick{s}! 🍽️",
    ],
    "es": [
        "¡Aquí {hay} {n} opcion{es} para ti! 🍽️",
        "¡Encontré {n} restaurante{s} que coincide{n2}! 🍽️",
    ],
    "ar": [
        "إليك {n} خيار{s} رائع{s}! 🍽️",
        "وجدت لك {n} مطعم{s}! 🍽️",
    ],
}

_RESTO_LINE = {
    "fr": "• {name} ({dist}) — {dish} ({price} FCFA), {rating}★",
    "en": "• {name} ({dist}) — Try their {dish} ({price} FCFA), {rating}★",
    "es": "• {name} ({dist}) — Prueba su {dish} ({price} FCFA), {rating}★",
    "ar": "• {name} ({dist}) — جرب {dish} ({price} FCFA), {rating}★",
}

_FOLLOWUPS = {
    "fr": "Tu veux plus de détails sur l'un d'eux ?",
    "en": "Want more details on any of these?",
    "es": "¿Quieres más detalles sobre alguno?",
    "ar": "هل تريد المزيد من التفاصيل؟",
}

_NO_RESULTS = {
    "fr": "Je n'ai pas trouvé de restaurant correspondant. Essaie avec d'autres préférences ! 🔄",
    "en": "I couldn't find matching restaurants. Try different preferences! 🔄",
    "es": "No encontré restaurantes que coincidan. ¡Prueba otras preferencias! 🔄",
    "ar": "لم أجد مطاعم مطابقة. جرب تفضيلات أخرى! 🔄",
}

_WELCOME = {
    "fr": "👋 Bienvenue ! Je suis Resto, ton guide gastronomique pour les JOJ Dakar 2026.\nDis-moi ce que tu veux manger, ton budget, et où tu es !",
    "en": "👋 Welcome! I'm Resto, your food guide for the Dakar 2026 Youth Olympics.\nTell me what you'd like to eat, your budget, and where you are!",
    "es": "👋 ¡Bienvenido! Soy Resto, tu guía de restaurantes para los JOJ Dakar 2026.\n¡Dime qué quieres comer, tu presupuesto y dónde estás!",
    "ar": "👋 مرحبا! أنا ريستو، مرشدك لمطاعم داكار في أولمبياد الشباب 2026.\nأخبرني ماذا تريد أن تأكل، وميزانيتك، وأين أنت!",
}

_NOT_FOOD = {
    "fr": "👋 Je suis Resto, l'assistant restaurant des JOJ Dakar 2026 ! Dis-moi ce que tu veux manger et je te trouve le meilleur spot. 🍽️",
    "en": "👋 I'm Resto, the restaurant assistant for Dakar 2026 YOG! Tell me what you'd like to eat and I'll find the perfect spot. 🍽️",
    "es": "👋 ¡Soy Resto, el asistente de restaurantes de los JOJ Dakar 2026! Dime qué quieres comer y te encontraré el lugar perfecto. 🍽️",
    "ar": "👋 أنا ريستو، مساعد المطاعم في أولمبياد الشباب داكار 2026! أخبرني ماذا تريد أن تأكل وسأجد لك المكان المثالي. 🍽️",
}


# ══════════════════════════════════════════════
# 2. CONSTRUCTION DE RÉPONSE
# ══════════════════════════════════════════════

def build_response(restaurants: list[dict], lang: str = "fr",
                    parsed: dict = None) -> str:
    """
    Construit une réponse texte complète à partir des résultats.
    Aucun LLM. < 1ms.
    """
    if not restaurants:
        return _NO_RESULTS.get(lang, _NO_RESULTS["fr"])

    parts = []

    # ── Ligne d'accroche ──
    n = len(restaurants)
    greeting = _pick_greeting(lang, n)
    parts.append(greeting)

    # ── Lignes restaurant ──
    for resto in restaurants[:3]:
        line = _format_resto_line(resto, lang)
        parts.append(line)

    # ── Follow-up ──
    parts.append(_FOLLOWUPS.get(lang, _FOLLOWUPS["fr"]))

    return "\n".join(parts)


def build_not_food_response(lang: str = "fr") -> str:
    """Réponse quand le message n'est pas lié à la nourriture."""
    return _NOT_FOOD.get(lang, _NOT_FOOD["fr"])


def build_welcome(lang: str = "fr") -> str:
    """Message de bienvenue."""
    return _WELCOME.get(lang, _WELCOME["fr"])


# ══════════════════════════════════════════════
# 3. HELPERS
# ══════════════════════════════════════════════

def _pick_greeting(lang: str, n: int) -> str:
    """Choisit et formate une ligne d'accroche."""
    import random
    templates = _GREETINGS.get(lang, _GREETINGS["fr"])
    template = random.choice(templates)

    return template.format(
        n=n,
        s="s" if n > 1 else "",
        s2="ent" if n > 1 else "",
        are="are" if n > 1 else "is",
        es="es" if n > 1 else "",
        n2="n" if n > 1 else "",
        hay="hay" if n > 1 else "hay",
    )


def _format_resto_line(resto: dict, lang: str) -> str:
    """Formate une ligne de restaurant."""
    template = _RESTO_LINE.get(lang, _RESTO_LINE["fr"])

    # Distance
    dist = resto.get("distance_km")
    if dist is not None:
        if dist < 0.1:
            dist_str = "juste à côté" if lang == "fr" else "right here" if lang == "en" else f"{dist} km"
        elif dist < 1:
            dist_str = f"{int(dist * 1000)}m"
        else:
            dist_str = f"{dist} km"
    else:
        dist_str = resto.get("zone", "Dakar")

    # Plat signature
    dish_name, dish_price = _get_signature_dish(resto)

    # Prix formaté avec séparateur milliers
    price_str = f"{dish_price:,}".replace(",", " ")

    return template.format(
        name=resto["name"],
        dist=dist_str,
        dish=dish_name,
        price=price_str,
        rating=resto.get("rating", "?"),
    )


def _get_signature_dish(resto: dict) -> tuple[str, int]:
    """Trouve le plat signature (tagué 'signature', sinon le plus populaire)."""
    menu = resto.get("menu", [])
    food_items = [p for p in menu if "boisson" not in p.get("tags", [])]

    if not food_items:
        return "Menu du jour", resto.get("avg_price", 0)

    # Priorité 1: plat tagué "signature"
    for plat in food_items:
        if "signature" in plat.get("tags", []):
            return plat["name"], plat["price"]

    # Priorité 2: plat le plus cher (souvent le plus intéressant)
    best = max(food_items, key=lambda p: p["price"])
    return best["name"], best["price"]


# ══════════════════════════════════════════════
# 4. TEST
# ══════════════════════════════════════════════

if __name__ == "__main__":
    # Simuler des résultats
    mock_restos = [
        {
            "name": "La Calebasse Dorée", "zone": "Plateau", "rating": 4.5,
            "distance_km": 0.03, "avg_price": 3500,
            "menu": [
                {"name": "Thiéboudienne Royale", "price": 3500, "tags": ["signature", "halal"]},
                {"name": "Yassa Poulet", "price": 3000, "tags": ["halal"]},
            ]
        },
        {
            "name": "Dibiterie Serigne Fallou", "zone": "Médina", "rating": 4.3,
            "distance_km": 1.36, "avg_price": 2500,
            "menu": [
                {"name": "Dibi Agneau", "price": 3000, "tags": ["signature", "halal"]},
            ]
        },
    ]

    for lang in ["fr", "en", "es", "ar"]:
        print(f"\n── {lang.upper()} ──")
        print(build_response(mock_restos, lang))

    print(f"\n── NO RESULTS (fr) ──")
    print(build_response([], "fr"))

    print(f"\n── NOT FOOD (en) ──")
    print(build_not_food_response("en"))