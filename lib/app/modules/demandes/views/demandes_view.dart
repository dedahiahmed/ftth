import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ftth/main.dart';
import 'package:ftth/app/widgets/app_layout.dart';
import 'package:ftth/app/widgets/notification_badge.dart';

import '../controllers/demandes_controller.dart';

class DemandesView extends GetView<DemandesController> {
  const DemandesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: -1,
      showBottomNav: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'FTTH',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Mes Demandes',
              style: TextStyle(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.secondaryColor),
            onPressed: controller.fetchDemandes,
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.fetchDemandes,
                  child: Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (controller.demandes.isEmpty && controller.serviceRequests.isEmpty && controller.speedChangeRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Aucune demande',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Vous n\'avez pas encore de demandes',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/subscription'),
                  icon: Icon(Icons.add),
                  label: Text('Nouvelle demande'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.secondaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDemandes,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              // Subscriptions section
              if (controller.demandes.isNotEmpty) ...[
                _buildSectionTitle('Abonnements FTTH', Icons.wifi),
                SizedBox(height: 12.h),
                ...controller.demandes.map((demande) => _buildDemandeCard(demande)),
              ],

              // Service requests section
              if (controller.serviceRequests.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildSectionTitle('Demandes de services', Icons.build),
                SizedBox(height: 12.h),
                ...controller.serviceRequests.map((request) => _buildServiceRequestCard(request)),
              ],

              // Speed change requests section
              if (controller.speedChangeRequests.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildSectionTitle('Changements de débit', Icons.speed),
                SizedBox(height: 12.h),
                ...controller.speedChangeRequests.map((request) => _buildSpeedChangeCard(request)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 22.sp),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandeCard(Map<String, dynamic> demande) {
    final status = demande['status'] ?? '';
    final statusColor = controller.getStatusColor(status);
    final statusLabel = controller.getStatusLabel(status);
    final codeClient = demande['code_client'] ?? '';
    final isEnCours = status == 'en_cours_de_traitement';
    final isEquipeEnRoute = status == 'equipe_en_route';
    final isActive = status == 'active';
    final subscriptionId = demande['id'];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.wifi, color: AppColors.primaryColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      demande['type'] ?? 'FTTH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Client Section
          if (codeClient.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code Client',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          codeClient,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.copyCodeClient(codeClient),
                    icon: Icon(
                      Icons.copy,
                      color: AppColors.primaryColor,
                      size: 22.sp,
                    ),
                    tooltip: 'Copier',
                  ),
                ],
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
            child: Column(
              children: [
                _buildInfoRow(Icons.person, 'Nom', demande['full_name'] ?? '-'),
                SizedBox(height: 8.h),
                _buildInfoRow(Icons.phone, 'Téléphone', demande['phone1'] ?? '-'),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date',
                  controller.formatDate(demande['created_at'] ?? ''),
                ),
              ],
            ),
          ),

          // Pricing Section - Show for ALL statuses
          _buildPricingSection(demande['package'], isEnCours),

          // Payment Info for "En cours" status
          if (isEnCours && codeClient.isNotEmpty)
            _buildPaymentCodeSection(codeClient),

          // Team Visit Section - ONLY for "equipe_en_route" status
          if (isEquipeEnRoute)
            _buildTeamVisitSection(demande, subscriptionId),

          // Active status - show completion info
          if (isActive)
            _buildActiveSection(demande, subscriptionId),

          // Feedback Section (after installation completed)
          if (controller.isInstallationCompleted(demande))
            _buildFeedbackSection(demande, subscriptionId),

          // Support call button
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
            child: _buildSupportCallButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSection(Map<String, dynamic> demande, String subscriptionId) {
    final isInstallationDone = controller.isInstallationCompleted(demande);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          top: BorderSide(color: Colors.green.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abonnement actif',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isInstallationDone
                          ? 'Installation terminée avec succès'
                          : 'Votre abonnement FTTH est maintenant actif',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isInstallationDone) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.markInstallationCompleted(subscriptionId),
                icon: Icon(Icons.done_all, size: 18.sp),
                label: Text('Confirmer installation terminée'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSection(String? package, bool showInstallationFee) {
    final pricing = controller.getPricingInfo(package);
    final monthlyPrice = pricing['monthlyPrice'] as int;
    final installationFee = pricing['installationFee'] as int;
    final speed = pricing['speed'] as String;
    final totalFirstPayment = monthlyPrice + installationFee;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Forfait header
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speed, color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'Forfait $speed',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Monthly price
          _buildPriceRow(
            'Abonnement mensuel',
            '$monthlyPrice MRU',
            Icons.calendar_month,
          ),

          // Installation fee - only show for en_cours_de_traitement
          if (showInstallationFee) ...[
            Divider(height: 16.h, color: Colors.grey.shade300),
            _buildPriceRow(
              'Frais d\'installation',
              '$installationFee MRU',
              Icons.build,
            ),
            Divider(height: 16.h, color: Colors.grey.shade300),
            // Total
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total 1er paiement',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '$totalFirstPayment MRU',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCodeSection(String codeClient) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          top: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement requis',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Payez via wallet avec le code client:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Code client
          GestureDetector(
            onTap: () => controller.copyCodeClient(codeClient),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    'Code client pour paiement',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        codeClient,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.copy, size: 20.sp, color: Colors.orange.shade600),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Payez via wallet avec le code client. Après paiement, notre équipe vous contactera pour l\'installation.',
                    style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: Colors.grey[600]),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamVisitSection(Map<String, dynamic> demande, String subscriptionId) {
    final hasReportedNotArrived = controller.hasReportedTeamNotArrived(demande);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border(
          top: BorderSide(color: Colors.purple.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.engineering, color: Colors.purple, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Équipe en route',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Notre équipe sera chez vous dans les 24h',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Team not arrived button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasReportedNotArrived
                  ? null
                  : () => _showTeamNotArrivedDialog(subscriptionId),
              icon: Icon(Icons.report_problem, size: 18.sp),
              label: Text(
                hasReportedNotArrived ? 'Signalement envoyé' : 'L\'équipe n\'est pas venue',
                style: TextStyle(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasReportedNotArrived ? Colors.grey : Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),

          if (hasReportedNotArrived)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Signalement envoyé. Notre équipe vous recontactera bientôt.',
                        style: TextStyle(fontSize: 11.sp, color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(Map<String, dynamic> demande, String subscriptionId) {
    final hasFeedback = controller.hasFeedbackSubmitted(demande);
    final rating = demande['service_rating'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        border: Border(
          top: BorderSide(color: Colors.teal.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.teal, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Votre avis compte!',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (hasFeedback) ...[
            // Show submitted rating
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Merci pour votre avis!',
                    style: TextStyle(fontSize: 13.sp, color: Colors.green.shade700),
                  ),
                  Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (rating ?? 0) ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20.sp,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Show feedback button
            Text(
              'Comment s\'est passée l\'installation?',
              style: TextStyle(fontSize: 12.sp, color: Colors.teal.shade700),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showFeedbackDialog(subscriptionId),
                icon: Icon(Icons.rate_review, size: 20.sp),
                label: Text('Donner mon avis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTeamNotArrivedDialog(String subscriptionId) {
    final messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.report_problem, color: Colors.orange, size: 28.sp),
            SizedBox(width: 12.w),
            Text('Signaler un problème', style: TextStyle(fontSize: 18.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'L\'équipe n\'est pas encore arrivée?',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Message optionnel...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.reportTeamNotArrived(
                subscriptionId,
                message: messageController.text.isNotEmpty ? messageController.text : null,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Signaler'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(String subscriptionId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 28.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Évaluez notre service',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Overall rating
                Text(
                  'Note globale *',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Obx(() => _buildRatingStars(
                      controller.feedbackRating.value,
                      (rating) => controller.feedbackRating.value = rating,
                    )),
                SizedBox(height: 16.h),

                // Team professionalism
                Text(
                  'Professionnalisme de l\'équipe',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 8.h),
                Obx(() => _buildRatingStars(
                      controller.teamProfessionalismRating.value,
                      (rating) => controller.teamProfessionalismRating.value = rating,
                      size: 28,
                    )),
                SizedBox(height: 12.h),

                // Installation quality
                Text(
                  'Qualité de l\'installation',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 8.h),
                Obx(() => _buildRatingStars(
                      controller.installationQualityRating.value,
                      (rating) => controller.installationQualityRating.value = rating,
                      size: 28,
                    )),
                SizedBox(height: 12.h),

                // Response time
                Text(
                  'Rapidité du service',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 8.h),
                Obx(() => _buildRatingStars(
                      controller.responseTimeRating.value,
                      (rating) => controller.responseTimeRating.value = rating,
                      size: 28,
                    )),
                SizedBox(height: 16.h),

                // Would recommend
                Obx(() => CheckboxListTile(
                      value: controller.wouldRecommend.value,
                      onChanged: (value) => controller.wouldRecommend.value = value ?? true,
                      title: Text('Je recommande ce service', style: TextStyle(fontSize: 13.sp)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    )),
                SizedBox(height: 12.h),

                // Comments
                Text(
                  'Commentaires (optionnel)',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: controller.feedbackCommentsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Partagez votre expérience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text('Annuler'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.submitFeedback(subscriptionId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: Text('Envoyer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(int currentRating, Function(int) onRating, {double size = 36}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRating(index + 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(
              index < currentRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: size.sp,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSupportCallButton() {
    return GestureDetector(
      onTap: () => _callSupport(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone,
              color: Colors.green.shade700,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'Assistance: 48 77 77 44',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '48777744');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir l\'application téléphone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceRequestCard(Map<String, dynamic> request) {
    final requestType = request['request_type'] ?? '';
    final status = request['status'] ?? '';
    final codeRequest = request['code_request'] ?? '';
    final subscription = request['subscriptions'] as Map<String, dynamic>?;
    final codeClient = subscription?['code_client'] ?? '';
    final package = subscription?['package'] ?? '';
    final fullName = subscription?['full_name'] ?? '';
    final newAddress = request['new_address'];
    final newGpsCoordinates = request['new_gps_coordinates'];
    final monthlyFee = request['monthly_fee'] ?? 0;
    final voipNumber = request['voip_number'];
    final ipAddress = request['ip_address'];
    final isTransfert = requestType == 'transfert_ligne';
    final isIpPublique = requestType == 'ip_publique';
    final isVoip = requestType == 'voip';

    final statusColor = controller.getServiceRequestStatusColor(status);
    final statusLabel = controller.getServiceRequestStatusLabel(status);
    final typeLabel = controller.getServiceRequestTypeLabel(requestType);
    final typeIcon = controller.getServiceRequestIcon(requestType);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with type and status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(typeIcon, color: statusColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Request Section
          if (codeRequest.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.confirmation_number,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'N° Demande',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          codeRequest,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.copyCodeClient(codeRequest),
                    icon: Icon(
                      Icons.copy,
                      color: statusColor,
                      size: 22.sp,
                    ),
                    tooltip: 'Copier',
                  ),
                ],
              ),
            ),

          // Linked subscription info
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
            child: Column(
              children: [
                _buildInfoRow(Icons.qr_code, 'Code Client', codeClient),
                SizedBox(height: 8.h),
                _buildInfoRow(Icons.person, 'Nom', fullName),
                SizedBox(height: 8.h),
                _buildInfoRow(Icons.speed, 'Forfait', package),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date',
                  controller.formatDate(request['created_at'] ?? ''),
                ),
                // Show new location for transfert ligne
                if (isTransfert && newGpsCoordinates != null) ...[
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.location_on, 'Nouvelle position', newGpsCoordinates),
                ],
                if (isTransfert && newAddress != null && newAddress.toString().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.home, 'Nouvelle adresse', newAddress),
                ],
                // Show VoIP number if available
                if (isVoip && voipNumber != null && voipNumber.toString().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.phone, 'N° Fixe', voipNumber),
                ],
                // Show IP address if available
                if (isIpPublique && ipAddress != null && ipAddress.toString().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _buildInfoRow(Icons.language, 'IP Publique', ipAddress),
                ],
              ],
            ),
          ),

          // Monthly fee info for IP Publique and VoIP
          if ((isIpPublique || isVoip) && monthlyFee > 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 12.r),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on, color: Colors.orange, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '+$monthlyFee MRU/mois ajouté à votre facture',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // Status info box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _getServiceRequestStatusMessage(status, requestType),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Support call button
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
            child: _buildSupportCallButton(),
          ),
        ],
      ),
    );
  }

  String _getServiceRequestStatusMessage(String status, String type) {
    String typeLabel;
    switch (type) {
      case 'achat_modem':
        typeLabel = 'modem';
        break;
      case 'transfert_ligne':
        typeLabel = 'transfert de ligne';
        break;
      case 'ip_publique':
        typeLabel = 'IP Publique';
        break;
      case 'voip':
        typeLabel = 'Service VoIP';
        break;
      default:
        typeLabel = type;
    }

    switch (status) {
      case 'en_attente':
        if (type == 'ip_publique') {
          return 'Votre demande d\'IP Publique est en attente. Une fois activée, 700 MRU/mois seront ajoutés à votre facture.';
        } else if (type == 'voip') {
          return 'Votre demande de Service VoIP est en attente. Un numéro fixe vous sera attribué depuis notre back-office.';
        }
        return 'Votre demande de $typeLabel est en attente de traitement. Nous vous contacterons bientôt.';
      case 'en_cours':
        if (type == 'ip_publique') {
          return 'Votre IP Publique est en cours d\'activation.';
        } else if (type == 'voip') {
          return 'Votre Service VoIP est en cours d\'activation. Un numéro vous sera attribué.';
        }
        return 'Votre demande de $typeLabel est en cours de traitement.';
      case 'termine':
        if (type == 'ip_publique') {
          return 'Votre IP Publique a été activée. 700 MRU/mois sont ajoutés à votre facture.';
        } else if (type == 'voip') {
          return 'Votre Service VoIP est actif. 300 MRU/mois sont ajoutés à votre facture.';
        }
        return 'Votre demande de $typeLabel a été traitée avec succès.';
      case 'annule':
        return 'Votre demande de $typeLabel a été annulée.';
      default:
        return 'Statut inconnu.';
    }
  }

  Widget _buildSpeedChangeCard(Map<String, dynamic> request) {
    final changeType = request['change_type'] ?? '';
    final status = request['status'] ?? '';
    final codeRequest = request['code_request'] ?? '';
    final currentPackage = request['current_package'] ?? '';
    final newPackage = request['new_package'] ?? '';
    final currentPrice = request['current_monthly_price'] ?? 0;
    final newPrice = request['new_monthly_price'] ?? 0;
    final penaltyFee = request['penalty_fee'] ?? 0;
    final subscription = request['subscriptions'] as Map<String, dynamic>?;
    final codeClient = subscription?['code_client'] ?? '';
    final fullName = subscription?['full_name'] ?? '';
    final isDowngrade = changeType == 'downgrade';

    final typeColor = controller.getSpeedChangeTypeColor(changeType);
    final typeLabel = controller.getSpeedChangeTypeLabel(changeType);
    final typeIcon = controller.getSpeedChangeIcon(changeType);
    final statusColor = controller.getServiceRequestStatusColor(status);
    final statusLabel = controller.getServiceRequestStatusLabel(status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with type and status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(typeIcon, color: typeColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Changement de débit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Request Section
          if (codeRequest.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: typeColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.confirmation_number,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'N° Demande',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          codeRequest,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.copyCodeClient(codeRequest),
                    icon: Icon(Icons.copy, color: typeColor, size: 22.sp),
                    tooltip: 'Copier',
                  ),
                ],
              ),
            ),

          // Subscription info
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
            child: Column(
              children: [
                _buildInfoRow(Icons.qr_code, 'Code Client', codeClient),
                SizedBox(height: 8.h),
                _buildInfoRow(Icons.person, 'Nom', fullName),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date',
                  controller.formatDate(request['created_at'] ?? ''),
                ),
              ],
            ),
          ),

          // Speed change details
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Current vs New package
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Actuel',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            currentPackage,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$currentPrice MRU/mois',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDowngrade ? Icons.arrow_downward : Icons.arrow_upward,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Nouveau',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            newPackage,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                          Text(
                            '$newPrice MRU/mois',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Penalty fee for downgrade
                if (isDowngrade && penaltyFee > 0) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Pénalité: $penaltyFee MRU',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // No fee for upgrade
                if (!isDowngrade) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Aucun frais supplémentaire',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Support call button
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
            child: _buildSupportCallButton(),
          ),
        ],
      ),
    );
  }
}
