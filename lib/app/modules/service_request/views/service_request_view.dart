import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';

import '../controllers/service_request_controller.dart';

class ServiceRequestView extends GetView<ServiceRequestController> {
  const ServiceRequestView({super.key});

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
          controller.requestTypeLabel,
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
              'Vous devez avoir un abonnement actif pour faire cette demande.',
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
    final isTransfertLigne = controller.isTransfertLigne;
    final isIpPublique = controller.isIpPublique;
    final isVoip = controller.isVoip;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and title
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
                  controller.requestTypeIcon,
                  size: 60.sp,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 12.h),
                Text(
                  controller.requestTypeLabel,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  controller.requestDescription,
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
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => controller.selectedSubscription.value = value,
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

          SizedBox(height: 24.h),

          // Pricing info for IP Publique and VoIP
          if (isIpPublique || isVoip) ...[
            _buildPricingInfo(),
            SizedBox(height: 24.h),
          ],

          // Location section for transfert ligne
          if (isTransfertLigne) ...[
            Text(
              'Nouvelle adresse',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),

            // Address text field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: controller.newAddress,
                decoration: InputDecoration(
                  hintText: 'Adresse complète (optionnel)',
                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // GPS location button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isGettingLocation.value
                        ? null
                        : controller.getCurrentLocation,
                    icon: controller.isGettingLocation.value
                        ? SizedBox(
                            height: 20.sp,
                            width: 20.sp,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.my_location, size: 20.sp),
                    label: Text(
                      controller.isGettingLocation.value
                          ? 'Récupération...'
                          : 'Récupérer ma position',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                )),

            // Show GPS coordinates if available
            Obx(() {
              if (controller.gpsCoordinates.value != null) {
                return Container(
                  margin: EdgeInsets.only(top: 12.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Position récupérée',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                                color: Colors.green.shade700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              controller.gpsCoordinates.value!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            SizedBox(height: 24.h),
          ],

          // Info box
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _getInfoText(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Submit button
          Obx(() => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.submitRequest,
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

  Widget _buildPricingInfo() {
    final isIpPublique = controller.isIpPublique;
    final fee = controller.monthlyFee;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frais mensuels',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '+$fee MRU/mois',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
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
            child: Text(
              isIpPublique
                  ? 'Ce montant sera ajouté à votre facture mensuelle après activation de l\'IP publique.'
                  : 'Ce montant sera ajouté à votre facture mensuelle. Vous recevrez un numéro de téléphone fixe.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getInfoText() {
    switch (controller.requestType) {
      case 'achat_modem':
        return 'Notre équipe vous contactera pour la livraison du modem.';
      case 'transfert_ligne':
        return 'Notre équipe vous contactera pour planifier le transfert de votre ligne vers la nouvelle adresse.';
      case 'ip_publique':
        return 'Une adresse IP publique fixe sera attribuée à votre connexion. Ce service est utile pour l\'hébergement ou l\'accès distant.';
      case 'voip':
        return 'Un numéro de téléphone fixe vous sera attribué. Ce numéro sera communiqué depuis notre back-office.';
      default:
        return 'Nous traiterons votre demande dans les plus brefs délais.';
    }
  }
}
