import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesController extends GetxController {
  final services = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  void loadServices() {
    services.value = [
      {
        'icon': 'list_alt',
        'title': 'Mes demandes',
        'color': Colors.teal,
        'route': 'demandes',
      },
      {
        'icon': 'receipt',
        'title': 'Factures',
        'color': Colors.deepOrange,
        'route': 'invoices',
      },
      {
        'icon': 'wifi',
        'title': 'Forfaits FTTH',
        'color': Colors.red,
        'route': 'packages',
      },
      {
        'icon': 'add_circle',
        'title': 'Abonnement FTTH',
        'color': Colors.green,
        'route': 'subscription',
      },

      {
        'icon': 'report_problem',
        'title': 'Signaler un problème',
        'color': Colors.red,
        'route': 'report',
      },
      {
        'icon': 'phone',
        'title': 'Service VoIP',
        'color': Colors.indigo,
        'route': 'voip',
      },
      {
        'icon': 'language',
        'title': 'IP Publique',
        'color': Colors.blue,
        'route': 'public_ip',
      },
      {
        'icon': 'speed',
        'title': 'Changement de débit',
        'color': Colors.purple,
        'route': 'speed_change',
      },
      {
        'icon': 'router',
        'title': 'Achat Modem',
        'color': Colors.green,
        'route': 'modem_purchase',
      },
      {
        'icon': 'swap_horiz',
        'title': 'Transfert de ligne',
        'color': Colors.orange,
        'route': 'line_transfer',
      },
    ];
  }

  void navigateToService(String route) {
    switch (route) {
      case 'subscription':
        Get.toNamed('/subscription');
        break;
      case 'demandes':
        Get.toNamed('/demandes');
        break;
      default:
        Get.snackbar(
          'Service',
          'Navigation vers: $route',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }
}
