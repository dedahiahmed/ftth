import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ftth/app/services/auth_service.dart';

class DemandesController extends GetxController {
  final _supabase = Supabase.instance.client;

  final demandes = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDemandes();
  }

  Future<void> fetchDemandes() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn) {
        errorMessage.value = 'Vous devez être connecté';
        return;
      }

      final response = await _supabase
          .from('subscriptions')
          .select('id, type, full_name, phone1, package, status, created_at')
          .eq('user_id', authService.user!.id)
          .order('created_at', ascending: false);

      demandes.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: $e';
      Get.snackbar(
        'Erreur',
        'Impossible de charger les demandes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'en_cours_de_traitement':
        return 'En cours';
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'en_cours_de_traitement':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
