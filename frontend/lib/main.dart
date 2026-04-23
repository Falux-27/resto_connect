import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement (ignore si .env manquant)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    print('⚠️ .env non trouvé, utilisation des valeurs par défaut');
  }

  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialiser le client HTTP
  ApiClient().init();

  // ╔════════════════════════════════════════════════════════════╗
  // ║  IMPORTANT: Enregistrer HomeController AVANT runApp        ║
  // ║  Garantit que le controller existe peu importe le timing   ║
  // ║  des bindings GetX. Évite "HomeController not found".      ║
  // ╚════════════════════════════════════════════════════════════╝
  // Get.put<HomeController>(HomeController(), permanent: true);

  runApp(const RestoConnectApp());
}

class RestoConnectApp extends StatelessWidget {
  const RestoConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Resto Connect Dakar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}