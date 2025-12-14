import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ftth/app/services/auth_service.dart';
import 'package:ftth/app/services/notification_service.dart';

class DemandesController extends GetxController {
  final _supabase = Supabase.instance.client;

  final demandes = <Map<String, dynamic>>[].obs;
  final serviceRequests = <Map<String, dynamic>>[].obs;
  final speedChangeRequests = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // Feedback form
  final feedbackRating = 0.obs;
  final teamProfessionalismRating = 0.obs;
  final installationQualityRating = 0.obs;
  final responseTimeRating = 0.obs;
  final wouldRecommend = true.obs;
  final feedbackCommentsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDemandes();
  }

  @override
  void onClose() {
    feedbackCommentsController.dispose();
    super.onClose();
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

      // Fetch subscriptions
      final response = await _supabase
          .from('subscriptions')
          .select('''
            id, type, full_name, phone1, package, status, code_client, created_at,
            team_notified_at, team_arrived_at, installation_completed_at,
            team_not_arrived_reported_at, service_rating, service_feedback, feedback_submitted_at
          ''')
          .eq('user_id', authService.user!.id)
          .order('created_at', ascending: false);

      demandes.value = List<Map<String, dynamic>>.from(response);

      // Fetch service requests with subscription info
      final serviceResponse = await _supabase
          .from('service_requests')
          .select('''
            id, request_type, status, code_request, notes, new_address, new_gps_coordinates,
            monthly_fee, voip_number, ip_address,
            created_at, updated_at, completed_at,
            subscriptions!inner(code_client, package, full_name)
          ''')
          .eq('user_id', authService.user!.id)
          .order('created_at', ascending: false);

      serviceRequests.value = List<Map<String, dynamic>>.from(serviceResponse);

      // Fetch speed change requests with subscription info
      final speedChangeResponse = await _supabase
          .from('speed_change_requests')
          .select('''
            id, code_request, current_package, new_package, change_type,
            current_monthly_price, new_monthly_price, penalty_fee,
            status, notes, created_at, updated_at, completed_at,
            subscriptions!inner(code_client, full_name)
          ''')
          .eq('user_id', authService.user!.id)
          .order('created_at', ascending: false);

      speedChangeRequests.value = List<Map<String, dynamic>>.from(speedChangeResponse);

      // Update notification service
      Get.find<NotificationService>().fetchEnCoursCount();
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

  void copyCodeClient(String codeClient) {
    Clipboard.setData(ClipboardData(text: codeClient));
    Get.snackbar(
      'Copié',
      'Code client copié: $codeClient',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Report that team has not arrived
  Future<void> reportTeamNotArrived(String subscriptionId, {String? message}) async {
    try {
      final authService = Get.find<AuthService>();

      // Insert report
      await _supabase.from('team_visit_reports').insert({
        'subscription_id': subscriptionId,
        'user_id': authService.user!.id,
        'report_type': 'team_not_arrived',
        'message': message ?? 'L\'équipe n\'est pas encore arrivée',
      });

      // Update subscription
      await _supabase.from('subscriptions').update({
        'team_not_arrived_reported_at': DateTime.now().toIso8601String(),
      }).eq('id', subscriptionId);

      Get.snackbar(
        'Signalé',
        'Nous avons bien reçu votre signalement. Notre équipe vous contactera bientôt.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await fetchDemandes();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'envoyer le signalement: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Mark that team has arrived
  Future<void> markTeamArrived(String subscriptionId) async {
    try {
      final authService = Get.find<AuthService>();

      // Insert report
      await _supabase.from('team_visit_reports').insert({
        'subscription_id': subscriptionId,
        'user_id': authService.user!.id,
        'report_type': 'team_arrived',
        'message': 'L\'équipe est arrivée',
      });

      // Update subscription
      await _supabase.from('subscriptions').update({
        'team_arrived_at': DateTime.now().toIso8601String(),
      }).eq('id', subscriptionId);

      Get.snackbar(
        'Confirmé',
        'Merci d\'avoir confirmé l\'arrivée de l\'équipe.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await fetchDemandes();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Mark installation as completed
  Future<void> markInstallationCompleted(String subscriptionId) async {
    try {
      final authService = Get.find<AuthService>();

      // Insert report
      await _supabase.from('team_visit_reports').insert({
        'subscription_id': subscriptionId,
        'user_id': authService.user!.id,
        'report_type': 'installation_done',
        'message': 'Installation terminée',
      });

      // Update subscription - mark as active and set installation completed
      await _supabase.from('subscriptions').update({
        'installation_completed_at': DateTime.now().toIso8601String(),
        'status': 'active',
      }).eq('id', subscriptionId);

      Get.snackbar(
        'Félicitations',
        'Installation terminée! N\'hésitez pas à nous donner votre avis.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await fetchDemandes();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Submit service feedback
  Future<void> submitFeedback(String subscriptionId) async {
    if (feedbackRating.value == 0) {
      Get.snackbar(
        'Erreur',
        'Veuillez donner une note globale',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final authService = Get.find<AuthService>();

      // Insert feedback
      await _supabase.from('service_feedbacks').insert({
        'subscription_id': subscriptionId,
        'user_id': authService.user!.id,
        'overall_rating': feedbackRating.value,
        'team_professionalism': teamProfessionalismRating.value > 0 ? teamProfessionalismRating.value : null,
        'installation_quality': installationQualityRating.value > 0 ? installationQualityRating.value : null,
        'response_time': responseTimeRating.value > 0 ? responseTimeRating.value : null,
        'comments': feedbackCommentsController.text.isNotEmpty ? feedbackCommentsController.text : null,
        'would_recommend': wouldRecommend.value,
      });

      // Reset form
      _resetFeedbackForm();

      Get.back(); // Close dialog

      Get.snackbar(
        'Merci!',
        'Votre avis a été enregistré. Merci pour votre retour!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await fetchDemandes();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'envoyer votre avis: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _resetFeedbackForm() {
    feedbackRating.value = 0;
    teamProfessionalismRating.value = 0;
    installationQualityRating.value = 0;
    responseTimeRating.value = 0;
    wouldRecommend.value = true;
    feedbackCommentsController.clear();
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'en_cours_de_traitement':
        return 'En attente paiement';
      case 'equipe_en_route':
        return 'Équipe en route';
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
      case 'equipe_en_route':
        return Colors.purple;
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get step number based on status (1-4)
  int getStatusStep(String status) {
    switch (status) {
      case 'en_cours_de_traitement':
        return 1;
      case 'equipe_en_route':
        return 2;
      case 'active':
        return 3;
      case 'inactive':
        return 4;
      default:
        return 0;
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

  String formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  /// Get pricing info based on package
  /// Returns: {monthlyPrice, installationFee, speed}
  Map<String, dynamic> getPricingInfo(String? package) {
    const int installationFee = 1000; // Always 1000 MRU

    if (package == null) {
      return {'monthlyPrice': 0, 'installationFee': installationFee, 'speed': '0'};
    }

    if (package.contains('100')) {
      return {'monthlyPrice': 1500, 'installationFee': installationFee, 'speed': '100 Mbps'};
    } else if (package.contains('200')) {
      return {'monthlyPrice': 2500, 'installationFee': installationFee, 'speed': '200 Mbps'};
    } else if (package.contains('500')) {
      return {'monthlyPrice': 4000, 'installationFee': installationFee, 'speed': '500 Mbps'};
    }

    return {'monthlyPrice': 0, 'installationFee': installationFee, 'speed': '0'};
  }

  /// Check if team visit is expected (for active/inactive status)
  bool isTeamVisitExpected(Map<String, dynamic> demande) {
    final status = demande['status'];
    return status == 'active' || status == 'inactive';
  }

  /// Check if user has already reported team not arrived
  bool hasReportedTeamNotArrived(Map<String, dynamic> demande) {
    return demande['team_not_arrived_reported_at'] != null;
  }

  /// Check if team has arrived
  bool hasTeamArrived(Map<String, dynamic> demande) {
    return demande['team_arrived_at'] != null;
  }

  /// Check if installation is completed
  bool isInstallationCompleted(Map<String, dynamic> demande) {
    return demande['installation_completed_at'] != null;
  }

  /// Check if feedback has been submitted
  bool hasFeedbackSubmitted(Map<String, dynamic> demande) {
    return demande['feedback_submitted_at'] != null;
  }

  // Service request helpers
  String getServiceRequestTypeLabel(String type) {
    switch (type) {
      case 'achat_modem':
        return 'Achat Modem';
      case 'transfert_ligne':
        return 'Transfert Ligne';
      case 'ip_publique':
        return 'IP Publique';
      case 'voip':
        return 'Service VoIP';
      default:
        return type;
    }
  }

  String getServiceRequestStatusLabel(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return status;
    }
  }

  Color getServiceRequestStatusColor(String status) {
    switch (status) {
      case 'en_attente':
        return Colors.orange;
      case 'en_cours':
        return Colors.blue;
      case 'termine':
        return Colors.green;
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getServiceRequestIcon(String type) {
    switch (type) {
      case 'achat_modem':
        return Icons.router;
      case 'transfert_ligne':
        return Icons.swap_horiz;
      case 'ip_publique':
        return Icons.language;
      case 'voip':
        return Icons.phone;
      default:
        return Icons.help;
    }
  }

  // Speed change helpers
  String getSpeedChangeTypeLabel(String type) {
    switch (type) {
      case 'upgrade':
        return 'Augmentation';
      case 'downgrade':
        return 'Réduction';
      default:
        return type;
    }
  }

  Color getSpeedChangeTypeColor(String type) {
    switch (type) {
      case 'upgrade':
        return Colors.green;
      case 'downgrade':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getSpeedChangeIcon(String type) {
    switch (type) {
      case 'upgrade':
        return Icons.trending_up;
      case 'downgrade':
        return Icons.trending_down;
      default:
        return Icons.speed;
    }
  }
}
