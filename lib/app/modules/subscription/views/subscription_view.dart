import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';

import '../controllers/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Form(
              key: controller.formKey,
              child: ListView(
                controller: controller.scrollController,
                children: [
                  // Client Information Section
                  _buildSectionHeader('Informations client', Icons.person, Colors.teal),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: controller.fullNameController,
                    label: 'Nom complet *',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est obligatoire';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: controller.phone1Controller,
                    label: 'Téléphone principal *',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est obligatoire';
                      }
                      if (!controller.isValidPhone(value)) {
                        return 'Numéro invalide (ex: 22123456)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: controller.phone2Controller,
                    label: 'WhatsApp (optionnel)',
                    icon: Icons.message,
                    iconColor: Colors.green,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !controller.isValidPhone(value)) {
                        return 'Numéro invalide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: controller.emailController,
                    label: 'Email (optionnel)',
                    icon: Icons.email,
                    iconColor: Colors.orange,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !controller.isValidEmail(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24.h),
                  // Identity Document Section
                  _buildSectionHeader('Pièce d\'identité', Icons.badge, Colors.indigo),
                  SizedBox(height: 12.h),
                  _buildDropdown(
                    value: controller.identityType,
                    label: 'Type de pièce *',
                    icon: Icons.badge,
                    items: controller.identityTypes,
                    onChanged: (value) => controller.identityType.value = value,
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: controller.nniController,
                    label: 'Numéro NNI *',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est obligatoire';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildPhotoUploadSection(
                    title: 'Photo de la pièce d\'identité',
                    isUploading: controller.isUploadingId,
                    progress: controller.idUploadProgress,
                    file: controller.idPhotoFile,
                    onCameraTap: () => controller.uploadIdPhoto(true),
                    onGalleryTap: () => controller.uploadIdPhoto(false),
                  ),

                  SizedBox(height: 24.h),
                  // Electricity Bill Section (Optional)
                  _buildSectionHeader('Facture d\'électricité (Optionnel)', Icons.receipt_long, Colors.amber),
                  SizedBox(height: 12.h),
                  _buildOptionalDropdown(
                    value: controller.billType,
                    label: 'Type de facture',
                    icon: Icons.receipt_long,
                    items: controller.billTypes,
                    onChanged: (value) => controller.billType.value = value,
                  ),
                  SizedBox(height: 12.h),
                  _buildPhotoUploadSection(
                    title: 'Photo de la facture (optionnel)',
                    isUploading: controller.isUploadingBill,
                    progress: controller.billUploadProgress,
                    file: controller.billPhotoFile,
                    onCameraTap: () => controller.uploadBillPhoto(true),
                    onGalleryTap: () => controller.uploadBillPhoto(false),
                  ),

                  SizedBox(height: 24.h),
                  // Address Section
                  _buildSectionHeader('Adresse et coordonnées', Icons.location_on, Colors.red),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: controller.addressController,
                    label: 'Adresse complète *',
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est obligatoire';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Carte',
                          icon: Icons.map,
                          color: Colors.green,
                          onTap: () {
                            // TODO: Open map
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(() => _buildActionButton(
                          label: 'Ma position',
                          icon: Icons.my_location,
                          color: Colors.green,
                          isLoading: controller.isLoading.value && controller.gpsCoordinates.value == null,
                          onTap: controller.getCurrentLocation,
                        )),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.gpsCoordinates.value != null) {
                      return Container(
                        margin: EdgeInsets.only(top: 12.h),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                controller.gpsCoordinates.value!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  SizedBox(height: 24.h),
                  // Package Section
                  _buildSectionHeader('Forfait commercial', Icons.speed, AppColors.primaryColor),
                  SizedBox(height: 12.h),
                  _buildDropdown(
                    value: controller.package,
                    label: 'Forfait souhaité *',
                    icon: Icons.speed,
                    items: controller.packages,
                    onChanged: (value) => controller.package.value = value,
                  ),
                  Obx(() {
                    if (controller.package.value == 'Autre débit') {
                      return Column(
                        children: [
                          SizedBox(height: 12.h),
                          _buildTextField(
                            controller: controller.customSpeedController,
                            label: 'Débit personnalisé (Mbps) *',
                            icon: Icons.speed,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (controller.package.value == 'Autre débit' &&
                                  (value == null || value.isEmpty)) {
                                return 'Ce champ est obligatoire';
                              }
                              return null;
                            },
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  SizedBox(height: 24.h),
                  // Submit Button
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () => controller.submitForm(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Envoyer la demande',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          // Loading overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Traitement en cours...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.secondaryColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Abonnement FTTH',
        style: TextStyle(
          color: AppColors.secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Image.asset(
            'assets/images/moov_ftth_logo.png',
            height: 40.h,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? iconColor,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor ?? AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildDropdown({
    required Rxn<String> value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Obx(() => DropdownButtonFormField<String>(
      value: value.value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: (value) => value == null ? 'Ce champ est obligatoire' : null,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
    ));
  }

  Widget _buildOptionalDropdown({
    required Rxn<String> value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Obx(() => DropdownButtonFormField<String>(
      value: value.value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
    ));
  }

  Widget _buildPhotoUploadSection({
    required String title,
    required RxBool isUploading,
    required RxDouble progress,
    required Rxn file,
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildActionButton(
                label: 'Caméra',
                icon: Icons.camera_alt,
                color: AppColors.primaryColor,
                isLoading: isUploading.value,
                onTap: onCameraTap,
              )),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Obx(() => _buildActionButton(
                label: 'Galerie',
                icon: Icons.upload_file,
                color: AppColors.primaryColor,
                isLoading: isUploading.value,
                onTap: onGalleryTap,
              )),
            ),
          ],
        ),
        Obx(() {
          if (isUploading.value) {
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${(progress.value * 100).toInt()}%',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          if (file.value != null && !isUploading.value) {
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Photo téléchargée',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? SizedBox(
              height: 16.sp,
              width: 16.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18.sp),
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
