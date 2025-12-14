import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ftth/app/services/auth_service.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final errorMessage = ''.obs;

  // Store redirect path after login
  String? redirectPath;
  Map<String, dynamic>? redirectArguments;

  @override
  void onInit() {
    super.onInit();
    // Get redirect info from arguments
    if (Get.arguments != null) {
      redirectPath = Get.arguments['redirectPath'];
      redirectArguments = Get.arguments['redirectArguments'];
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Validate Mauritanian phone number
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }

    final cleanPhone = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanPhone.length != 8) {
      return 'Le numéro doit contenir 8 chiffres';
    }

    if (!RegExp(r'^[234]').hasMatch(cleanPhone)) {
      return 'Le numéro doit commencer par 2, 3 ou 4';
    }

    if (!AuthService.isValidMauritanianPhone(cleanPhone)) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  /// Validate OTP
  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Code OTP requis';
    }

    if (value.length != 6) {
      return 'Le code doit contenir 6 chiffres';
    }

    return null;
  }

  /// Send OTP
  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authService = Get.find<AuthService>();
      await authService.signInWithPhone(phoneController.text);

      isOtpSent.value = true;

      Get.snackbar(
        'Succès',
        'Code OTP envoyé au +222${phoneController.text}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'envoi du code: $e';
      Get.snackbar(
        'Erreur',
        'Impossible d\'envoyer le code OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP and login
  Future<void> verifyOtp() async {
    if (otpController.text.length != 6) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer un code à 6 chiffres',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authService = Get.find<AuthService>();
      await authService.verifyOTP(phoneController.text, otpController.text);

      Get.snackbar(
        'Succès',
        'Connexion réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Redirect to original path or home
      if (redirectPath != null) {
        Get.offAllNamed(redirectPath!, arguments: redirectArguments);
      } else {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      errorMessage.value = 'Code OTP invalide';
      Get.snackbar(
        'Erreur',
        'Code OTP invalide ou expiré',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    await sendOtp();
  }

  /// Go back to phone input
  void backToPhone() {
    isOtpSent.value = false;
    otpController.clear();
    errorMessage.value = '';
  }
}
