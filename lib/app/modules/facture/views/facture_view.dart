import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';
import 'package:ftth/app/widgets/app_layout.dart';

import '../controllers/facture_controller.dart';

class FactureView extends GetView<FactureController> {
  const FactureView({super.key});

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
              'Mes Factures',
              style: TextStyle(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.secondaryColor),
            onPressed: controller.fetchFactures,
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
                  onPressed: controller.fetchFactures,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Summary card
            _buildSummaryCard(),

            // Tab bar
            _buildTabBar(),

            // Factures list
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchFactures,
                child: _buildFacturesList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() => Container(
          margin: EdgeInsets.all(16.r),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total à payer',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${controller.totalPendingAmount} MRU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt, color: Colors.white, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text(
                          '${controller.pendingCount} en attente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildMiniStat(
                    'Installation',
                    controller.pendingFactures
                        .where((f) => f['facture_type'] == 'installation')
                        .length,
                    Icons.build,
                  ),
                  SizedBox(width: 12.w),
                  _buildMiniStat(
                    'Mensuel',
                    controller.pendingFactures
                        .where((f) => f['facture_type'] == 'mensuel')
                        .length,
                    Icons.calendar_month,
                  ),
                  SizedBox(width: 12.w),
                  _buildMiniStat(
                    'Services',
                    controller.pendingFactures
                        .where((f) =>
                            f['facture_type'] == 'transfert_ligne' ||
                            f['facture_type'] == 'achat_modem')
                        .length,
                    Icons.miscellaneous_services,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildMiniStat(String label, int count, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(() => Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              _buildTabButton('En attente', 0, controller.pendingFactures.length),
              _buildTabButton('Payées', 1, controller.paidFactures.length),
              _buildTabButton('Toutes', 2, controller.allFactures.length),
            ],
          ),
        ));
  }

  Widget _buildTabButton(String label, int index, int count) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryColor : Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacturesList() {
    return Obx(() {
      List<Map<String, dynamic>> factures;
      switch (controller.selectedTab.value) {
        case 0:
          factures = controller.pendingFactures;
          break;
        case 1:
          factures = controller.paidFactures;
          break;
        default:
          factures = controller.allFactures;
      }

      if (factures.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                'Aucune facture',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                controller.selectedTab.value == 0
                    ? 'Vous n\'avez pas de factures en attente'
                    : controller.selectedTab.value == 1
                        ? 'Vous n\'avez pas de factures payées'
                        : 'Aucune facture trouvée',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: factures.length,
        itemBuilder: (context, index) {
          return _buildFactureCard(factures[index]);
        },
      );
    });
  }

  Widget _buildFactureCard(Map<String, dynamic> facture) {
    final type = facture['facture_type'] ?? '';
    final status = facture['status'] ?? '';
    final codeFacture = facture['code_facture'] ?? '';
    final codeClient = facture['code_client'] ?? '';
    final fullName = facture['full_name'] ?? '';
    final package = facture['package'] ?? '';
    final montantTotal = facture['montant_total'] ?? 0;
    final montantBase = facture['montant_base'] ?? 0;
    final montantIp = facture['montant_ip_publique'] ?? 0;
    final montantVoip = facture['montant_voip'] ?? 0;
    final dateEmission = facture['date_emission'];
    final dateEcheance = facture['date_echeance'];
    final datePaiement = facture['date_paiement'];
    final periodeDebut = facture['periode_debut'];
    final periodeFin = facture['periode_fin'];
    final details = facture['details'] as List?;

    final typeColor = controller.getFactureTypeColor(type);
    final typeIcon = controller.getFactureTypeIcon(type);
    final typeLabel = controller.getFactureTypeLabel(type);
    final statusColor = controller.getStatusColor(status);
    final statusLabel = controller.getStatusLabel(status);
    final isOverdue = controller.isOverdue(dateEcheance) && status == 'en_attente';
    final isPending = status == 'en_attente';
    final isMensuel = type == 'mensuel';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isOverdue ? Border.all(color: Colors.red, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(typeIcon, color: Colors.white, size: 20.sp),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              typeLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: typeColor,
                              ),
                            ),
                            Text(
                              codeFacture,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isOverdue)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'EN RETARD',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Period for monthly invoices
                if (isMensuel && periodeDebut != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.date_range, size: 16.sp, color: typeColor),
                        SizedBox(width: 8.w),
                        Text(
                          'Période: ${controller.formatPeriod(periodeDebut, periodeFin)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Client info
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          fullName,
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.copyCode(codeClient),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code, size: 14.sp, color: AppColors.primaryColor),
                        SizedBox(width: 4.w),
                        Text(
                          codeClient,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details section
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                // Line items from details
                if (details != null && details.isNotEmpty) ...[
                  ...details.map((item) {
                    final desc = item['description'] ?? '';
                    final total = item['total'] ?? 0;
                    return _buildLineItem(desc, total);
                  }),
                  Divider(height: 20.h, color: Colors.grey.shade300),
                ] else if (isMensuel) ...[
                  // Show breakdown for monthly
                  _buildLineItem('Abonnement FTTH ${controller.getPackageSpeed(package)}', montantBase),
                  if (montantIp > 0) _buildLineItem('IP Publique', montantIp),
                  if (montantVoip > 0) _buildLineItem('Service VoIP', montantVoip),
                  Divider(height: 20.h, color: Colors.grey.shade300),
                ],

                // Total
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isPending
                          ? Colors.orange.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '$montantTotal MRU',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isPending ? Colors.orange.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateInfo('Émission', controller.formatDate(dateEmission), Icons.calendar_today),
                    if (isPending)
                      _buildDateInfo(
                        'Échéance',
                        controller.formatDate(dateEcheance),
                        Icons.event,
                        isOverdue: isOverdue,
                      )
                    else
                      _buildDateInfo('Payée le', controller.formatDate(datePaiement), Icons.check_circle),
                  ],
                ),
              ],
            ),
          ),

          // Payment section for pending invoices
          if (isPending)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Payez via wallet avec votre code client',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.copyCode(codeClient),
                          icon: Icon(Icons.copy, size: 16.sp),
                          label: Text('Copier code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLineItem(String description, int amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$amount MRU',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String value, IconData icon, {bool isOverdue = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: isOverdue ? Colors.red : Colors.grey[500],
        ),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isOverdue ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
