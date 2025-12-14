import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ftth/app/services/auth_service.dart';
import 'package:ftth/app/services/storage_service.dart';
import 'package:ftth/app/services/form_persistence_service.dart';

class SubscriptionController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  final _supabase = Supabase.instance.client;

  // Form fields controllers
  final fullNameController = TextEditingController();
  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final emailController = TextEditingController();
  final nniController = TextEditingController();
  final addressController = TextEditingController();
  final customSpeedController = TextEditingController();

  // Observables
  final identityType = Rxn<String>();
  final billType = Rxn<String>();
  final package = Rxn<String>();
  final gpsCoordinates = Rxn<String>();

  final isLoading = false.obs;
  final isUploadingId = false.obs;
  final isUploadingBill = false.obs;
  final idUploadProgress = 0.0.obs;
  final billUploadProgress = 0.0.obs;

  final idPhotoFile = Rxn<File>();
  final billPhotoFile = Rxn<File>();

  // Dropdown items
  final identityTypes = [
    'Carte d\'identité nationale',
    'Passeport',
    'Permis de conduire',
    'Carte de séjour',
  ];

  final billTypes = ['SOMELEC', 'SNDE'];

  final packages = [
    '100 Mbps - 1500 MRU/mois',
    '200 Mbps - 2500 MRU/mois',
    '500 Mbps - 4000 MRU/mois',
  ];

  // Installation fee is always 1000 MRU
  static const int installationFee = 1000;

  @override
  void onInit() {
    super.onInit();
    // Restore form data if available
    _restoreFormData();
  }

  /// Restore form data from persistence service
  void _restoreFormData() {
    final persistenceService = Get.find<FormPersistenceService>();
    final savedData = persistenceService.getSubscriptionForm();

    if (savedData != null) {
      fullNameController.text = savedData['fullName'] ?? '';
      phone1Controller.text = savedData['phone1'] ?? '';
      phone2Controller.text = savedData['phone2'] ?? '';
      emailController.text = savedData['email'] ?? '';
      nniController.text = savedData['nni'] ?? '';
      addressController.text = savedData['address'] ?? '';
      identityType.value = savedData['identityType'];
      billType.value = savedData['billType'];
      package.value = savedData['package'];
      gpsCoordinates.value = savedData['gpsCoordinates'];

      // Restore photo files if paths exist
      if (savedData['idPhotoPath'] != null) {
        final file = File(savedData['idPhotoPath']);
        if (file.existsSync()) {
          idPhotoFile.value = file;
        }
      }
      if (savedData['billPhotoPath'] != null) {
        final file = File(savedData['billPhotoPath']);
        if (file.existsSync()) {
          billPhotoFile.value = file;
        }
      }

      // Clear saved data after restoring
      persistenceService.clearSubscriptionForm();

      Get.snackbar(
        'Info',
        'Vos données ont été restaurées',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  /// Save form data before redirecting to login
  void _saveFormData() {
    final persistenceService = Get.find<FormPersistenceService>();
    persistenceService.saveSubscriptionForm(
      fullName: fullNameController.text,
      phone1: phone1Controller.text,
      phone2: phone2Controller.text,
      email: emailController.text,
      nni: nniController.text,
      identityType: identityType.value,
      billType: billType.value,
      package: package.value,
      address: addressController.text,
      gpsCoordinates: gpsCoordinates.value,
      idPhotoFile: idPhotoFile.value,
      billPhotoFile: billPhotoFile.value,
    );
  }

  bool get isFormValid {
    return fullNameController.text.isNotEmpty &&
        phone1Controller.text.isNotEmpty &&
        isValidPhone(phone1Controller.text) &&
        nniController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        identityType.value != null &&
        package.value != null &&
        idPhotoFile.value != null &&
        gpsCoordinates.value != null;
  }

  bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[234]\d{7}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    emailController.dispose();
    nniController.dispose();
    addressController.dispose();
    customSpeedController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    isLoading.value = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Erreur',
          'Le service de localisation est désactivé',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
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
          isLoading.value = false;
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
        isLoading.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      gpsCoordinates.value = '${position.latitude}, ${position.longitude}';
      addressController.text = 'Position: ${position.latitude}, ${position.longitude}';

      Get.snackbar(
        'Succès',
        'Position obtenue avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur de localisation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadIdPhoto(bool fromCamera) async {
    try {
      isUploadingId.value = true;
      idUploadProgress.value = 0.0;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        for (var i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          idUploadProgress.value = i / 100;
        }

        idPhotoFile.value = File(image.path);
        idUploadProgress.value = 1.0;

        Get.snackbar(
          'Succès',
          'Photo téléchargée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur de téléchargement: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingId.value = false;
    }
  }

  Future<void> uploadBillPhoto(bool fromCamera) async {
    try {
      isUploadingBill.value = true;
      billUploadProgress.value = 0.0;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        for (var i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          billUploadProgress.value = i / 100;
        }

        billPhotoFile.value = File(image.path);
        billUploadProgress.value = 1.0;

        Get.snackbar(
          'Succès',
          'Facture téléchargée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur de téléchargement: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingBill.value = false;
    }
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Clear all form inputs
  void _clearForm() {
    fullNameController.clear();
    phone1Controller.clear();
    phone2Controller.clear();
    emailController.clear();
    nniController.clear();
    addressController.clear();
    customSpeedController.clear();
    identityType.value = null;
    billType.value = null;
    package.value = null;
    gpsCoordinates.value = null;
    idPhotoFile.value = null;
    billPhotoFile.value = null;
    idUploadProgress.value = 0.0;
    billUploadProgress.value = 0.0;
  }

  /// Show success modal
  void _showSuccessModal() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Demande envoyée',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Votre demande est en cours de traitement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close modal
                    Get.offAllNamed('/demandes'); // Navigate to demandes
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Voir mes demandes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitForm() async {
    // Validate form first
    if (!(formKey.currentState?.validate() ?? false)) {
      scrollToTop();
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs obligatoires',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (idPhotoFile.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez télécharger la photo d\'identité',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if user is authenticated
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      // Save form data before redirecting
      _saveFormData();

      Get.snackbar(
        'Connexion requise',
        'Veuillez vous connecter pour envoyer votre demande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      // Redirect to login with return path
      Get.toNamed('/login', arguments: {
        'redirectPath': '/subscription',
        'redirectArguments': null,
      });
      return;
    }

    isLoading.value = true;

    try {
      // Upload identity photo to Supabase Storage
      final idPhotoUrl = await StorageService.uploadFile(
        bucketName: 'subscription-documents',
        file: idPhotoFile.value!,
        folder: 'identity',
      );

      if (idPhotoUrl == null) {
        throw Exception('Erreur lors du téléchargement de la photo d\'identité');
      }

      // Upload bill photo if provided
      String? billPhotoUrl;
      if (billPhotoFile.value != null) {
        billPhotoUrl = await StorageService.uploadFile(
          bucketName: 'subscription-documents',
          file: billPhotoFile.value!,
          folder: 'bills',
        );
      }

      // Parse GPS coordinates
      double? latitude;
      double? longitude;
      if (gpsCoordinates.value != null) {
        final coords = gpsCoordinates.value!.split(',');
        if (coords.length == 2) {
          latitude = double.tryParse(coords[0].trim());
          longitude = double.tryParse(coords[1].trim());
        }
      }

      // Insert subscription into database
      await _supabase.from('subscriptions').insert({
        'user_id': authService.user!.id,
        'type': 'FTTH',
        'full_name': fullNameController.text,
        'phone1': phone1Controller.text,
        'phone2': phone2Controller.text.isNotEmpty ? phone2Controller.text : null,
        'email': emailController.text.isNotEmpty ? emailController.text : null,
        'nni': nniController.text,
        'identity_type': identityType.value,
        'identity_photo_url': idPhotoUrl,
        'bill_type': billType.value,
        'bill_photo_url': billPhotoUrl,
        'address': addressController.text,
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'package': package.value,
        'status': 'en_cours_de_traitement',
      });

      // Clear form inputs
      _clearForm();

      // Show success modal
      _showSuccessModal();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'envoi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
