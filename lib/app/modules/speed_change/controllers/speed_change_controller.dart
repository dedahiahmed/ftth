import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ftth/app/services/auth_service.dart';

class SpeedChangeController extends GetxController {
  final _supabase = Supabase.instance.client;

  final activeSubscriptions = <Map<String, dynamic>>[].obs;
  final selectedSubscription = Rxn<Map<String, dynamic>>();
  final selectedNewPackage = Rxn<String>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // Package options with prices
  static const packages = [
    {'name': '100 Mbps', 'speed': 100, 'price': 1500},
    {'name': '200 Mbps', 'speed': 200, 'price': 2500},
    {'name': '500 Mbps', 'speed': 500, 'price': 4000},
  ];

  static const int downgradePenalty = 2500; // MRU

  // Current subscription package info
  Map<String, dynamic>? get currentPackageInfo {
    if (selectedSubscription.value == null) return null;
    final currentPkg = selectedSubscription.value!['package'] ?? '';
    return _getPackageInfo(currentPkg);
  }

  // New package info
  Map<String, dynamic>? get newPackageInfo {
    if (selectedNewPackage.value == null) return null;
    return _getPackageInfo(selectedNewPackage.value!);
  }

  // Check if it's a downgrade
  bool get isDowngrade {
    if (currentPackageInfo == null || newPackageInfo == null) return false;
    return (newPackageInfo!['speed'] as int) <
        (currentPackageInfo!['speed'] as int);
  }

  // Check if it's an upgrade
  bool get isUpgrade {
    if (currentPackageInfo == null || newPackageInfo == null) return false;
    return (newPackageInfo!['speed'] as int) >
        (currentPackageInfo!['speed'] as int);
  }

  // Available packages (exclude current)
  List<Map<String, dynamic>> get availablePackages {
    if (currentPackageInfo == null) return packages;
    return packages
        .where((pkg) => pkg['speed'] != currentPackageInfo!['speed'])
        .toList();
  }

  Map<String, dynamic> _getPackageInfo(String packageStr) {
    if (packageStr.contains('100')) {
      return {'name': '100 Mbps', 'speed': 100, 'price': 1500};
    } else if (packageStr.contains('200')) {
      return {'name': '200 Mbps', 'speed': 200, 'price': 2500};
    } else if (packageStr.contains('500')) {
      return {'name': '500 Mbps', 'speed': 500, 'price': 4000};
    }
    return {'name': 'Unknown', 'speed': 0, 'price': 0};
  }

  @override
  void onInit() {
    super.onInit();
    fetchActiveSubscriptions();
  }

  Future<void> fetchActiveSubscriptions() async {
    isLoading.value = true;

    try {
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await _supabase
          .from('subscriptions')
          .select('id, code_client, package, full_name, status')
          .eq('user_id', authService.user!.id)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      activeSubscriptions.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les abonnements: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSubscriptionChanged(Map<String, dynamic>? subscription) {
    selectedSubscription.value = subscription;
    selectedNewPackage.value =
        null; // Reset new package when subscription changes
  }

  void onNewPackageChanged(String? package) {
    selectedNewPackage.value = package;
  }

  Future<void> submitRequest() async {
    if (selectedSubscription.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner un abonnement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedNewPackage.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner un nouveau forfait',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show confirmation dialog for downgrade
    if (isDowngrade) {
      final confirmed = await _showDowngradeConfirmation();
      if (!confirmed) return;
    }

    isSubmitting.value = true;

    try {
      final authService = Get.find<AuthService>();

      await _supabase.from('speed_change_requests').insert({
        'user_id': authService.user!.id,
        'subscription_id': selectedSubscription.value!['id'],
        'current_package': currentPackageInfo!['name'],
        'new_package': newPackageInfo!['name'],
        'change_type': isDowngrade ? 'downgrade' : 'upgrade',
        'current_monthly_price': currentPackageInfo!['price'],
        'new_monthly_price': newPackageInfo!['price'],
        'penalty_fee': isDowngrade ? downgradePenalty : 0,
      });

      Get.back();

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Demande envoyée')),
            ],
          ),
          content: Text(
            isDowngrade
                ? 'Votre demande de réduction de débit a été envoyée. Une pénalité de $downgradePenalty MRU sera appliquée.'
                : 'Votre demande d\'augmentation de débit a été envoyée avec succès. Aucun frais supplémentaire.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'envoyer la demande: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> _showDowngradeConfirmation() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Attention')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous êtes sur le point de réduire votre débit.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.money_off, color: Colors.red, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pénalité de réduction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$downgradePenalty MRU',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Voulez-vous continuer?', style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
