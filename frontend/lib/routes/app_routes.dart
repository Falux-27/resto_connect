import 'package:get/get.dart';
import '../../features/home/home_binding.dart';
import '../../features/home/home_screen.dart';
import '../../features/results/results_binding.dart';
import '../../features/results/results_screen.dart';
import '../../features/detail/detail_binding.dart';
import '../../features/detail/detail_screen.dart';
import '../../features/favorites/favorites_binding.dart';
import '../../features/favorites/favorites_screen.dart';

abstract class AppRoutes {
  static const home      = '/';
  static const results   = '/results';
  static const detail    = '/detail';
  static const favorites = '/favorites';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.results,
      page: () => const ResultsScreen(),
      binding: ResultsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailScreen(),
      binding: DetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
      binding: FavoritesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
  ];
}