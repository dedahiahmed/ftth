import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ftth/app/services/auth_service.dart';

class FactureController extends GetxController {
  final _supabase = Supabase.instance.client;

  // All factures
  final allFactures = <Map<String, dynamic>>[].obs;
  // Pending factures (en_attente)
  final pendingFactures = <Map<String, dynamic>>[].obs;
  // Current monthly factures (from 23rd)
  final currentMonthlyFactures = <Map<String, dynamic>>[].obs;
  // Paid factures
  final paidFactures = <Map<String, dynamic>>[].obs;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final selectedTab = 0.obs; // 0: En attente, 1: Payées, 2: Toutes

  @override
  void onInit() {
    super.onInit();
    fetchFactures();
  }

  Future<void> fetchFactures() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn) {
        errorMessage.value = 'Vous devez être connecté';
        return;
      }

      // Try to use the new RPC function
      try {
        final response = await _supabase.rpc(
          'get_user_factures_v2',
          params: {'p_user_id': authService.user!.id},
        );

        if (response != null) {
          allFactures.value = List<Map<String, dynamic>>.from(response);
          _filterFactures();
          return;
        }
      } catch (e) {
        // RPC might not exist yet, fallback to direct query
      }

      // Fallback: Direct query to factures table
      await _fetchFacturesFallback();
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchFacturesFallback() async {
    try {
      final authService = Get.find<AuthService>();

      final response = await _supabase
          .from('factures')
          .select('''
            *,
            subscriptions!inner(code_client, full_name, phone1, package, status)
          ''')
          .eq('user_id', authService.user!.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> factureList = [];

      for (final f in response) {
        final sub = f['subscriptions'] as Map<String, dynamic>?;
        factureList.add({
          'id': f['id'],
          'code_facture': f['code_facture'],
          'facture_type': f['facture_type'],
          'montant_base': f['montant_base'] ?? 0,
          'montant_ip_publique': f['montant_ip_publique'] ?? 0,
          'montant_voip': f['montant_voip'] ?? 0,
          'montant_autres': f['montant_autres'] ?? 0,
          'montant_total': f['montant_total'] ?? 0,
          'status': f['status'],
          'date_emission': f['date_emission'],
          'date_echeance': f['date_echeance'],
          'date_paiement': f['date_paiement'],
          'periode_debut': f['periode_debut'],
          'periode_fin': f['periode_fin'],
          'details': f['details'],
          'created_at': f['created_at'],
          'code_client': sub?['code_client'] ?? '',
          'full_name': sub?['full_name'] ?? '',
          'phone1': sub?['phone1'] ?? '',
          'package': sub?['package'] ?? '',
          'subscription_status': sub?['status'] ?? '',
        });
      }

      allFactures.value = factureList;
      _filterFactures();
    } catch (e) {
      // If factures table doesn't exist yet, show empty
      allFactures.value = [];
      pendingFactures.value = [];
      paidFactures.value = [];
      currentMonthlyFactures.value = [];
    }
  }

  void _filterFactures() {
    pendingFactures.value = allFactures
        .where((f) => f['status'] == 'en_attente')
        .toList();

    paidFactures.value = allFactures
        .where((f) => f['status'] == 'payee')
        .toList();

    // Current monthly: pending + mensuel + within current billing period
    final now = DateTime.now();
    DateTime periodStart;
    if (now.day >= 23) {
      periodStart = DateTime(now.year, now.month, 23);
    } else {
      periodStart = DateTime(now.year, now.month - 1, 23);
    }

    currentMonthlyFactures.value = allFactures.where((f) {
      if (f['facture_type'] != 'mensuel') return false;
      if (f['status'] != 'en_attente') return false;

      final periodeDebut = f['periode_debut'];
      if (periodeDebut == null) return true;

      try {
        final pDate = DateTime.parse(periodeDebut.toString());
        return pDate.isAfter(periodStart) || pDate.isAtSameMomentAs(periodStart);
      } catch (e) {
        return true;
      }
    }).toList();
  }

  Future<void> markAsPaid(String factureId) async {
    try {
      final authService = Get.find<AuthService>();

      // Try RPC first
      try {
        await _supabase.rpc(
          'mark_facture_paid',
          params: {
            'p_facture_id': factureId,
            'p_user_id': authService.user!.id,
          },
        );
      } catch (e) {
        // Fallback to direct update
        await _supabase.from('factures').update({
          'status': 'payee',
          'date_paiement': DateTime.now().toIso8601String(),
        }).eq('id', factureId);
      }

      Get.snackbar(
        'Succès',
        'Facture marquée comme payée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await fetchFactures();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de marquer la facture: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'Copié',
      'Code copié: $code',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String formatPeriod(String? debut, String? fin) {
    if (debut == null || fin == null) return '-';
    return '${formatDate(debut)} - ${formatDate(fin)}';
  }

  String getFactureTypeLabel(String type) {
    switch (type) {
      case 'installation':
        return 'Frais d\'installation';
      case 'transfert_ligne':
        return 'Transfert de ligne';
      case 'achat_modem':
        return 'Achat modem';
      case 'mensuel':
        return 'Facture mensuelle';
      default:
        return type;
    }
  }

  IconData getFactureTypeIcon(String type) {
    switch (type) {
      case 'installation':
        return Icons.build;
      case 'transfert_ligne':
        return Icons.swap_horiz;
      case 'achat_modem':
        return Icons.router;
      case 'mensuel':
        return Icons.calendar_month;
      default:
        return Icons.receipt;
    }
  }

  Color getFactureTypeColor(String type) {
    switch (type) {
      case 'installation':
        return Colors.blue;
      case 'transfert_ligne':
        return Colors.purple;
      case 'achat_modem':
        return Colors.teal;
      case 'mensuel':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'payee':
        return 'Payée';
      case 'annulee':
        return 'Annulée';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'en_attente':
        return Colors.orange;
      case 'payee':
        return Colors.green;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getPackageSpeed(String? package) {
    if (package == null) return '0 Mbps';
    if (package.contains('100')) return '100 Mbps';
    if (package.contains('200')) return '200 Mbps';
    if (package.contains('500')) return '500 Mbps';
    return package;
  }

  bool isOverdue(String? dateEcheance) {
    if (dateEcheance == null) return false;
    try {
      final dueDate = DateTime.parse(dateEcheance);
      return DateTime.now().isAfter(dueDate);
    } catch (e) {
      return false;
    }
  }

  int get totalPendingAmount {
    int total = 0;
    for (final f in pendingFactures) {
      total += (f['montant_total'] ?? 0) as int;
    }
    return total;
  }

  int get pendingCount => pendingFactures.length;
}
