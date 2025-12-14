import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ftth/app/services/auth_service.dart';

class ServiceRequestController extends GetxController {
  final _supabase = Supabase.instance.client;

  final activeSubscriptions = <Map<String, dynamic>>[].obs;
  final selectedSubscription = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isGettingLocation = false.obs;

  // Location for transfert ligne
  final newAddress = TextEditingController();
  final gpsCoordinates = Rxn<String>();

  // Request type passed from navigation
  late String requestType;

  // Pricing
  static const int ipPubliqueFee = 700; // MRU/month
  static const int voipFee = 300; // MRU/month

  String get requestTypeLabel {
    switch (requestType) {
      case 'achat_modem':
        return 'Achat Modem';
      case 'transfert_ligne':
        return 'Transfert Ligne';
      case 'ip_publique':
        return 'IP Publique';
      case 'voip':
        return 'Service VoIP';
      default:
        return requestType;
    }
  }

  bool get isTransfertLigne => requestType == 'transfert_ligne';
  bool get isIpPublique => requestType == 'ip_publique';
  bool get isVoip => requestType == 'voip';

  IconData get requestTypeIcon {
    switch (requestType) {
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

  String get requestDescription {
    switch (requestType) {
      case 'achat_modem':
        return 'Demandez un nouveau modem pour votre connexion FTTH';
      case 'transfert_ligne':
        return 'Transférez votre ligne vers une nouvelle adresse';
      case 'ip_publique':
        return 'Obtenez une adresse IP publique fixe pour votre connexion';
      case 'voip':
        return 'Obtenez un numéro de téléphone fixe avec le service VoIP';
      default:
        return '';
    }
  }

  int get monthlyFee {
    if (isIpPublique) return ipPubliqueFee;
    if (isVoip) return voipFee;
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    requestType = Get.arguments?['type'] ?? 'achat_modem';
    fetchActiveSubscriptions();
  }

  @override
  void onClose() {
    newAddress.dispose();
    super.onClose();
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

  Future<void> getCurrentLocation() async {
    isGettingLocation.value = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Erreur',
          'Veuillez activer la localisation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Erreur',
            'Permission de localisation refusée',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Erreur',
          'Permission de localisation refusée définitivement',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      gpsCoordinates.value = '${position.latitude}, ${position.longitude}';

      Get.snackbar(
        'Succès',
        'Position récupérée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer la position: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGettingLocation.value = false;
    }
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

    // For transfert ligne, location is required
    if (isTransfertLigne && gpsCoordinates.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez récupérer votre nouvelle position',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final authService = Get.find<AuthService>();

      final data = <String, dynamic>{
        'user_id': authService.user!.id,
        'subscription_id': selectedSubscription.value!['id'],
        'request_type': requestType,
      };

      // Add location data for transfert ligne
      if (isTransfertLigne) {
        data['new_address'] = newAddress.text.isNotEmpty ? newAddress.text : null;
        data['new_gps_coordinates'] = gpsCoordinates.value;
      }

      // Add monthly fee for IP Publique and VoIP
      if (isIpPublique || isVoip) {
        data['monthly_fee'] = monthlyFee;
      }

      await _supabase.from('service_requests').insert(data);

      Get.back();

      String successMessage = 'Votre demande de $requestTypeLabel a été envoyée avec succès. Nous vous contacterons bientôt.';
      if (isIpPublique) {
        successMessage = 'Votre demande d\'IP Publique a été envoyée. Une fois activée, $ipPubliqueFee MRU/mois seront ajoutés à votre facture.';
      } else if (isVoip) {
        successMessage = 'Votre demande de Service VoIP a été envoyée. Nous vous attribuerons un numéro fixe. $voipFee MRU/mois seront ajoutés à votre facture.';
      }

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
          content: Text(successMessage),
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

  String getSubscriptionLabel(Map<String, dynamic> subscription) {
    final codeClient = subscription['code_client'] ?? '';
    final package = subscription['package'] ?? '';
    return '$codeClient - $package';
  }
}
