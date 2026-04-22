import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';

/// Données locales des restaurants dakarois — seed v1.0
/// Utilisées en offline ou avant chargement API
final List<RestaurantModel> restaurantsSeed = [

  // ─── 1. Chez Loutcha ───────────────────────────────────────
  RestaurantModel(
    id:           'resto_001',
    name:         'Chez Loutcha',
    zone:         'Plateau',
    lat:          14.6701,
    lng:          -17.4372,
    priceRange:   PriceRange.cheap,
    avgPrice:     3500,
    rating:       4.6,
    tags:         ['local', 'halal', 'cheap', 'senegalais', 'terrasse'],
    description:  'Institution incontournable du Plateau, Chez Loutcha sert une cuisine sénégalaise authentique à prix imbattables. Ambiance conviviale et familiale, très apprécié des locaux.',
    openingHours: 'Lun-Sam · 08h-21h',
    phone:        '+221 77 123 45 67',
    address:      '15 Rue Félix Faure, Plateau',
    imageUrl:     'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=800&q=80',
    menu: [
      MenuItemModel(
        name:        'Thiéboudienne rouge',
        price:       3500,
        tags:        ['local', 'halal', 'poisson', 'signature'],
        description: 'Riz au poisson sénégalais, plat national — spécialité de la maison',
      ),
      MenuItemModel(
        name:        'Yassa poulet',
        price:       2800,
        tags:        ['local', 'halal', 'poulet'],
        description: 'Poulet mariné à l\'oignon et au citron, servi avec riz',
      ),
      MenuItemModel(
        name:        'Mafé bœuf',
        price:       3200,
        tags:        ['local', 'halal', 'viande'],
        description: 'Ragoût de bœuf en sauce arachide, accompagné de riz blanc',
      ),
      MenuItemModel(
        name:        'Bissap glacé',
        price:       500,
        tags:        ['boisson', 'local', 'sans alcool'],
        description: 'Jus d\'hibiscus frais, légèrement sucré',
      ),
    ],
  ),

  // ─── 2. Le Lagon 1 ─────────────────────────────────────────
  RestaurantModel(
    id:           'resto_002',
    name:         'Le Lagon 1',
    zone:         'Plateau',
    lat:          14.6785,
    lng:          -17.4441,
    priceRange:   PriceRange.expensive,
    avgPrice:     18000,
    rating:       4.8,
    tags:         ['fruits de mer', 'gastronomique', 'vue mer', 'halal', 'romantique', 'climatisé'],
    description:  'Restaurant gastronomique construit sur pilotis au-dessus de l\'océan Atlantique. Cadre exceptionnel avec vue sur le coucher de soleil. Idéal pour un dîner romantique ou un repas d\'affaires.',
    openingHours: 'Lun-Dim · 12h-23h',
    phone:        '+221 33 823 00 00',
    address:      'Route de la Corniche Ouest, Plateau',
    imageUrl:     'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80',
    menu: [
      MenuItemModel(
        name:        'Plateau de Fruits de Mer',
        price:       25000,
        tags:        ['fruits de mer', 'halal', 'fresh', 'signature'],
        description: 'Huîtres, gambas, langoustes et crevettes ultra-frais',
      ),
      MenuItemModel(
        name:        'Langouste Grillée',
        price:       22000,
        tags:        ['fruits de mer', 'halal', 'grillé'],
        description: 'Langouste entière grillée, beurre citronné et légumes de saison',
      ),
      MenuItemModel(
        name:        'Thiéboudienne Prestige',
        price:       12000,
        tags:        ['local', 'halal', 'poisson'],
        description: 'Version gastronomique du plat national, poisson du jour',
      ),
      MenuItemModel(
        name:        'Capitaine Rôti',
        price:       14000,
        tags:        ['poisson', 'halal'],
        description: 'Filet de capitaine rôti, sauce vierge tomate et herbes fraîches',
      ),
    ],
  ),

  // ─── 3. La Calebasse ───────────────────────────────────────
  RestaurantModel(
    id:           'resto_003',
    name:         'La Calebasse',
    zone:         'Almadies',
    lat:          14.7462,
    lng:          -17.5118,
    priceRange:   PriceRange.mid,
    avgPrice:     9000,
    rating:       4.5,
    tags:         ['africain', 'fusion', 'halal', 'local', 'artistique', 'terrasse'],
    description:  'Cadre chaleureux et artistique aux Almadies. Fusion entre gastronomie africaine et saveurs internationales, avec des produits locaux et épices traditionnelles.',
    openingHours: 'Lun-Dim · 11h-23h',
    phone:        '+221 77 456 78 90',
    address:      'Route des Almadies, Almadies',
    imageUrl:     'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&q=80',
    menu: [
      MenuItemModel(
        name:        'Thiéboudienne Calebasse',
        price:       8000,
        tags:        ['local', 'halal', 'poisson', 'signature'],
        description: 'Thiéboudienne signature servie dans une calebasse artisanale',
      ),
      MenuItemModel(
        name:        'Yassa Agneau',
        price:       10000,
        tags:        ['local', 'halal', 'viande'],
        description: 'Agneau mijoté à l\'oignon et au citron vert, accompagné de fonio',
      ),
      MenuItemModel(
        name:        'Thiou de Crevettes',
        price:       9500,
        tags:        ['local', 'halal', 'fruits de mer'],
        description: 'Ragoût de crevettes aux tomates et épices africaines, riz blanc',
      ),
      MenuItemModel(
        name:        'Accras de Niébé',
        price:       3500,
        tags:        ['vegetarien', 'local', 'entree'],
        description: 'Beignets croustillants de haricots niébé, sauce piment maison',
      ),
    ],
  ),

  // ─── 4. Le Ngor ────────────────────────────────────────────
  RestaurantModel(
    id:           'resto_004',
    name:         'Le Ngor',
    zone:         'Ngor',
    lat:          14.7438,
    lng:          -17.5193,
    priceRange:   PriceRange.mid,
    avgPrice:     10000,
    rating:       4.4,
    tags:         ['fruits de mer', 'poisson', 'vue mer', 'halal', 'plage', 'terrasse'],
    description:  'Face à l\'océan Atlantique et à l\'île de Ngor, restaurant emblématique proposant des grillades de poisson et fruits de mer ultra-frais dans un décor atypique.',
    openingHours: 'Lun-Dim · 10h-22h',
    phone:        '+221 33 820 00 00',
    address:      'Plage de Ngor, Ngor',
    imageUrl:     'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
    menu: [
      MenuItemModel(
        name:        'Poisson Braisé',
        price:       8000,
        tags:        ['poisson', 'halal', 'grillé', 'local', 'signature'],
        description: 'Poisson du jour braisé au charbon, citron et légumes grillés',
      ),
      MenuItemModel(
        name:        'Gambas Grillées',
        price:       12000,
        tags:        ['fruits de mer', 'halal', 'grillé'],
        description: 'Grandes gambas grillées, beurre ail-persil et frites',
      ),
      MenuItemModel(
        name:        'Thiébou Yapp',
        price:       7500,
        tags:        ['local', 'halal', 'viande'],
        description: 'Riz à la viande sénégalais, légumes du jour',
      ),
      MenuItemModel(
        name:        'Salade de Fruits de Mer',
        price:       6000,
        tags:        ['fruits de mer', 'halal', 'entree'],
        description: 'Crevettes, calamars et poulpe, vinaigrette citron-coriandre',
      ),
    ],
  ),

  // ─── 5. Bazoff ─────────────────────────────────────────────
  RestaurantModel(
    id:           'resto_005',
    name:         'Bazoff',
    zone:         'Point E',
    lat:          14.6902,
    lng:          -17.4608,
    priceRange:   PriceRange.mid,
    avgPrice:     7500,
    rating:       4.3,
    tags:         ['grillades', 'halal', 'festif', 'local', 'international', 'climatisé', 'wifi'],
    description:  'Institution des grillades à Dakar. Poulet braisé aux épices locales, ambiance festive et chaleureuse. Idéal pour les groupes.',
    openingHours: 'Lun-Dim · 12h-00h',
    phone:        '+221 77 111 22 33',
    address:      'Avenue Cheikh Anta Diop, Point E',
    imageUrl:     'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
    menu: [
      MenuItemModel(
        name:        'Poulet Braisé Bazoff',
        price:       6500,
        tags:        ['halal', 'grillé', 'poulet', 'signature'],
        description: 'Poulet entier mariné aux épices Bazoff, braisé au charbon de bois',
      ),
      MenuItemModel(
        name:        'Brochettes Mixtes',
        price:       7000,
        tags:        ['halal', 'grillé', 'viande'],
        description: 'Brochettes de bœuf et agneau, sauce oignon et frites maison',
      ),
      MenuItemModel(
        name:        'Thiéboudienne du Chef',
        price:       5500,
        tags:        ['local', 'halal', 'poisson'],
        description: 'Riz au poisson traditionnel, recette du chef Bazoff',
      ),
      MenuItemModel(
        name:        'Cocktail Bissap-Gingembre',
        price:       2000,
        tags:        ['boisson', 'local', 'sans alcool'],
        description: 'Jus d\'hibiscus frais au gingembre, spécialité maison',
      ),
    ],
  ),
];