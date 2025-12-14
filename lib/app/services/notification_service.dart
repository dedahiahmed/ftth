import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ftth/app/services/auth_service.dart';

class NotificationService extends GetxService {
  final _supabase = Supabase.instance.client;

  final enCoursCount = 0.obs;
  final demandes = <Map<String, dynamic>>[].obs;

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initRealtimeSubscription();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _initRealtimeSubscription() {
    final authService = Get.find<AuthService>();

    // Listen to auth changes to setup/teardown subscription
    ever(authService.currentUser, (user) {
      if (user != null) {
        _setupRealtimeListener(user.id);
        fetchEnCoursCount();
      } else {
        _subscription?.cancel();
        enCoursCount.value = 0;
        demandes.clear();
      }
    });

    // Initial fetch if already logged in
    if (authService.isLoggedIn) {
      _setupRealtimeListener(authService.user!.id);
      fetchEnCoursCount();
    }
  }

  void _setupRealtimeListener(String userId) {
    _subscription?.cancel();

    _subscription = _supabase
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
          demandes.value = List<Map<String, dynamic>>.from(data);
          enCoursCount.value = data
              .where((d) => d['status'] == 'en_cours_de_traitement')
              .length;
        });
  }

  Future<void> fetchEnCoursCount() async {
    try {
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn) return;

      final response = await _supabase
          .from('subscriptions')
          .select('id')
          .eq('user_id', authService.user!.id)
          .eq('status', 'en_cours_de_traitement');

      enCoursCount.value = (response as List).length;
    } catch (e) {
      print('Error fetching en cours count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllDemandes() async {
    try {
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn) return [];

      final response = await _supabase
          .from('subscriptions')
          .select('*')
          .eq('user_id', authService.user!.id)
          .order('created_at', ascending: false);

      demandes.value = List<Map<String, dynamic>>.from(response);
      enCoursCount.value = demandes
          .where((d) => d['status'] == 'en_cours_de_traitement')
          .length;

      return demandes;
    } catch (e) {
      print('Error fetching demandes: $e');
      return [];
    }
  }
}
