import 'package:get/get.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../routes/app_routes.dart';

class ResultsController extends GetxController {
  final ChatRepository       _chatRepo   = ChatRepository();
  final RestaurantRepository _localRepo  = RestaurantRepository();

  final RxList<RestaurantModel> results      = <RestaurantModel>[].obs;
  final RxBool                  isLoading    = true.obs;
  final RxBool                  hasError     = false.obs;
  final RxString                query        = ''.obs;
  final RxString                aiReply      = ''.obs;
  final RxList<String>          activeFilters = <String>[].obs;

  double? _userLat;
  double? _userLng;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    query.value         = args['query']          as String? ?? '';
    _userLat            = args['userLat']         as double?;
    _userLng            = args['userLng']         as double?;
    final filters       = args['activeFilters']   as List? ?? [];
    activeFilters.value = filters.cast<String>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    hasError.value  = false;

    try {
      if (query.value.isNotEmpty) {
        // ── Appel chatbot IA (backend) ──────────────────────
        final chatResult = await _chatRepo.sendMessage(
          message:  query.value,
          userLat:  _userLat,
          userLng:  _userLng,
          pipeline: 'fast',
        );
        results.value = chatResult.restaurants;
        aiReply.value = chatResult.reply;

        // Si le chatbot ne retourne rien → fallback local
        if (results.isEmpty) _localSearch();
      } else {
        // ── Filtres rapides → recherche locale ──────────────
        _localSearch();
      }
    } catch (e) {
      // ── Fallback complet local si backend KO ────────────
      _localSearch();
    }

    isLoading.value = false;
  }

  void _localSearch() {
    final tagMap = {
      'halal':      'halal',
      'vegetarien': 'vegetarien',
      'cheap':      'cheap',
      'vue mer':    'vue mer',
    };
    final mappedTags = activeFilters
        .map((f) => tagMap[f] ?? f)
        .toList();

    results.value = _localRepo.search(
      query:      query.value,
      activeTags: mappedTags,
      userLat:    _userLat,
      userLng:    _userLng,
    );
  }

  void onRestaurantTap(RestaurantModel r) {
    Get.toNamed(
      AppRoutes.detail,
      arguments: {'restaurantId': r.id, 'query': query.value},
    );
  }

  void goBack() => Get.back();

  String get resultsSummary {
    final n = results.length;
    if (n == 0) return 'Aucun restaurant trouvé.';
    // Utilise la réponse de l'IA si disponible
    if (aiReply.value.isNotEmpty) {
      // Première ligne de la réponse IA
      return aiReply.value.split('\n').first;
    }
    return '$n resto${n > 1 ? 's' : ''} trié${n > 1 ? 's' : ''} par '
        'proximité, budget et match.';
  }
}