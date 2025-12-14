import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';

import '../controllers/speed_change_controller.dart';

class SpeedChangeView extends GetView<SpeedChangeController> {
  const SpeedChangeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Changement de débit',
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.activeSubscriptions.isEmpty) {
          return _buildNoSubscriptions();
        }

        return _buildForm();
      }),
    );
  }

  Widget _buildNoSubscriptions() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 80.sp,
              color: Colors.orange,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucun abonnement actif',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Vous devez avoir un abonnement actif pour changer de débit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/subscription'),
              icon: Icon(Icons.add),
              label: Text('Souscrire à un abonnement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.secondaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.speed,
                  size: 60.sp,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Changement de débit',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Modifiez la vitesse de votre connexion FTTH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Subscription selector
          Text(
            'Sélectionnez votre abonnement',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),

          Obx(() => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  value: controller.selectedSubscription.value,
                  items: controller.activeSubscriptions.map((subscription) {
                    final codeClient = subscription['code_client'] ?? '';
                    final package = subscription['package'] ?? '';
                    return DropdownMenuItem(
                      value: subscription,
                      child: Text(
                        '$codeClient - $package',
                        style: TextStyle(fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: controller.onSubscriptionChanged,
                  decoration: InputDecoration(
                    hintText: 'Choisir un abonnement',
                    prefixIcon: Icon(Icons.wifi, color: AppColors.primaryColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              )),

          // Current package info
          Obx(() {
            if (controller.currentPackageInfo != null) {
              return _buildCurrentPackageInfo();
            }
            return SizedBox.shrink();
          }),

          SizedBox(height: 24.h),

          // New package selector
          Obx(() {
            if (controller.selectedSubscription.value == null) {
              return SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouveau forfait souhaité',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                ...controller.availablePackages.map((pkg) => _buildPackageOption(pkg)),
              ],
            );
          }),

          // Price comparison
          Obx(() {
            if (controller.newPackageInfo != null) {
              return _buildPriceComparison();
            }
            return SizedBox.shrink();
          }),

          SizedBox(height: 24.h),

          // Submit button
          Obx(() => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: (controller.isSubmitting.value ||
                          controller.selectedNewPackage.value == null)
                      ? null
                      : controller.submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? SizedBox(
                          height: 24.sp,
                          width: 24.sp,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Envoyer la demande',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildCurrentPackageInfo() {
    final info = controller.currentPackageInfo!;
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.speed, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forfait actuel',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  info['name'],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${info['price']} MRU',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                '/mois',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption(Map<String, dynamic> pkg) {
    final isSelected = controller.selectedNewPackage.value == pkg['name'];
    final currentSpeed = controller.currentPackageInfo?['speed'] ?? 0;
    final newSpeed = pkg['speed'] as int;
    final isUpgrade = newSpeed > currentSpeed;

    return GestureDetector(
      onTap: () => controller.onNewPackageChanged(pkg['name'] as String),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected
              ? (isUpgrade ? Colors.green.shade50 : Colors.orange.shade50)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? (isUpgrade ? Colors.green : Colors.orange)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isUpgrade ? Colors.green : Colors.orange)
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUpgrade ? Colors.green : Colors.orange,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w),

            // Package info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pkg['name'] as String,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isUpgrade ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUpgrade ? Icons.arrow_upward : Icons.arrow_downward,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isUpgrade ? 'Upgrade' : 'Downgrade',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${pkg['price']} MRU/mois',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceComparison() {
    final current = controller.currentPackageInfo!;
    final newPkg = controller.newPackageInfo!;
    final isUpgrade = controller.isUpgrade;
    final isDowngrade = controller.isDowngrade;

    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDowngrade ? Colors.orange.shade300 : Colors.green.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: isDowngrade ? Colors.orange : Colors.green,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Récapitulatif du changement',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),

          // Current vs New
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Actuel',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      current['name'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${current['price']} MRU/mois',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: isDowngrade ? Colors.orange : Colors.green,
                size: 32.sp,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Nouveau',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      newPkg['name'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDowngrade ? Colors.orange : Colors.green,
                      ),
                    ),
                    Text(
                      '${newPkg['price']} MRU/mois',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDowngrade ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Upgrade info
          if (isUpgrade)
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aucun frais supplémentaire',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'L\'augmentation de débit est gratuite!',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Downgrade penalty warning
          if (isDowngrade)
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Pénalité de réduction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${SpeedChangeController.downgradePenalty} MRU',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Frais de pénalité à payer',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'La réduction de débit entraîne des frais de pénalité.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.red.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
