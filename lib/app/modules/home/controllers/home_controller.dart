import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final userName = 'Utilisateur'.obs;

  final quickActions = <Map<String, dynamic>>[].obs;

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
        'route': 'requests',
      },
      {
        'icon': 'wifi',
        'title': 'Forfaits FTTH',
        'route': 'packages',
      },
      {
        'icon': 'add_circle',
        'title': 'Abonnement',
        'route': 'subscription',
      },
      {
        'icon': 'receipt',
        'title': 'Factures',
        'route': 'invoices',
      },
      {
        'icon': 'report_problem',
        'title': 'Signaler',
        'route': 'report',
      },
      {
        'icon': 'phone',
        'title': 'Service VoIP',
        'route': 'voip',
      },
    ];

    isLoading.value = false;
  }

  Future<void> refreshData() async {
    await loadData();
  }
}
