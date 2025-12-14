import 'dart:io';
import 'package:get/get.dart';

/// Service to persist form data when user needs to login
class FormPersistenceService extends GetxService {
  // Subscription form data
  Map<String, dynamic>? _subscriptionFormData;

  /// Save subscription form data
  void saveSubscriptionForm({
    required String fullName,
    required String phone1,
    String? phone2,
    String? email,
    required String nni,
    String? identityType,
    String? billType,
    String? package,
    String? address,
    String? gpsCoordinates,
    File? idPhotoFile,
    File? billPhotoFile,
  }) {
    _subscriptionFormData = {
      'fullName': fullName,
      'phone1': phone1,
      'phone2': phone2,
      'email': email,
      'nni': nni,
      'identityType': identityType,
      'billType': billType,
      'package': package,
      'address': address,
      'gpsCoordinates': gpsCoordinates,
      'idPhotoPath': idPhotoFile?.path,
      'billPhotoPath': billPhotoFile?.path,
    };
  }

  /// Get saved subscription form data
  Map<String, dynamic>? getSubscriptionForm() {
    return _subscriptionFormData;
  }

  /// Clear subscription form data
  void clearSubscriptionForm() {
    _subscriptionFormData = null;
  }

  /// Check if there's saved subscription data
  bool hasSubscriptionFormData() {
    return _subscriptionFormData != null;
  }
}
