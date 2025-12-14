import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  final Rxn<User> currentUser = Rxn<User>();
  final isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      isAuthenticated.value = data.session != null;
    });

    // Check initial auth state
    currentUser.value = _supabase.auth.currentUser;
    isAuthenticated.value = _supabase.auth.currentUser != null;
  }

  /// Get current user
  User? get user => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Validate Mauritanian phone number
  /// Must start with 2, 3, or 4 and be exactly 8 digits
  static bool isValidMauritanianPhone(String phone) {
    // Remove any spaces or dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    final phoneRegex = RegExp(r'^[234]\d{7}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  /// Format phone number with country code
  static String formatPhoneWithCountryCode(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    return '+222$cleanPhone';
  }

  /// Sign in with phone (OTP)
  Future<AuthResponse?> signInWithPhone(String phone) async {
    try {
      final formattedPhone = formatPhoneWithCountryCode(phone);

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );

      return null; // OTP sent, waiting for verification
    } catch (e) {
      print('Auth error: $e');
      rethrow;
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOTP(String phone, String otp) async {
    try {
      final formattedPhone = formatPhoneWithCountryCode(phone);

      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      return response;
    } catch (e) {
      print('OTP verification error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
