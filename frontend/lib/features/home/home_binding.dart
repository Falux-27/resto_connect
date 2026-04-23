import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Le controller est déjà enregistré dans main.dart (permanent: true)
    // Cette ligne est une sécurité: si pour une raison quelconque il n'est
    // pas en mémoire, on le recrée.
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(), permanent: true);
    }
  }
}