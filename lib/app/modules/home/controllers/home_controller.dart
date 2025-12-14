import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final userName = 'Utilisateur'.obs;

  final quickActions = <Map<String, dynamic>>[].obs;

  // FTTH Forfaits
  final ftthPackages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    quickActions.value = [
      {
        'icon': 'list_alt',
        'title': 'Mes demandes',
        'route': '/demandes',
      },
      {
        'icon': 'wifi',
        'title': 'Abonnement',
        'route': '/subscription',
      },
      {
        'icon': 'receipt',
        'title': 'Factures',
        'route': '/facture',
      },
      {
        'icon': 'speed',
        'title': 'Changement débit',
        'route': '/speed-change',
      },
      {
        'icon': 'phone',
        'title': 'Service VoIP',
        'route': '/service-request',
        'args': {'type': 'voip'},
      },
      {
        'icon': 'language',
        'title': 'IP Publique',
        'route': '/service-request',
        'args': {'type': 'ip_publique'},
      },
    ];

    // FTTH Packages - Real prices
    ftthPackages.value = [
      {
        'name': 'FTTH 100 Mbps',
        'speed': '100 Mbps',
        'price': 1500,
        'color': 0xFF4CAF50, // Green
        'features': [
          'Internet illimité',
          'Débit jusqu\'à 100 Mbps',
          'Support technique 24/7',
          'Frais installation: 1000 MRU',
        ],
        'popular': false,
      },
      {
        'name': 'FTTH 200 Mbps',
        'speed': '200 Mbps',
        'price': 2500,
        'color': 0xFF2196F3, // Blue - Primary
        'features': [
          'Internet illimité',
          'Débit jusqu\'à 200 Mbps',
          'Support technique prioritaire',
          'Frais installation: 1000 MRU',
          'Idéal pour streaming HD',
        ],
        'popular': true,
      },
      {
        'name': 'FTTH 500 Mbps',
        'speed': '500 Mbps',
        'price': 4000,
        'color': 0xFFFF9800, // Orange
        'features': [
          'Internet illimité',
          'Débit jusqu\'à 500 Mbps',
          'Support VIP dédié',
          'Frais installation: 1000 MRU',
          'Parfait pour gaming & 4K',
          'Multi-appareils sans lag',
        ],
        'popular': false,
      },
    ];

    isLoading.value = false;
  }

  Future<void> refreshData() async {
    await loadData();
  }

  void navigateToQuickAction(Map<String, dynamic> action) {
    final route = action['route'] as String;
    final args = action['args'] as Map<String, dynamic>?;

    if (args != null) {
      Get.toNamed(route, arguments: args);
    } else {
      Get.toNamed(route);
    }
  }

  void navigateToServices() {
    Get.toNamed('/services');
  }

  void subscribeToPackage(Map<String, dynamic> package) {
    Get.toNamed('/subscription');
  }
}
