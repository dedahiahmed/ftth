import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';
import 'package:ftth/app/widgets/app_layout.dart';

import '../controllers/services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 3,
      appBar: _buildAppBar(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Obx(() => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return _buildServiceTile(
                icon: _getIcon(service['icon'] as String),
                title: service['title'] as String,
                color: service['color'] as Color,
                onTap: () => controller.navigateToService(service['route'] as String),
              );
            },
          )),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      title: Container(
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
            fontSize: 16.sp,
          ),
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

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'list_alt':
        return Icons.list_alt;
      case 'wifi':
        return Icons.wifi_tethering;
      case 'add_circle':
        return Icons.fiber_new_outlined;
      case 'receipt':
        return Icons.receipt_long;
      case 'report_problem':
        return Icons.report_problem;
      case 'phone':
        return Icons.phone;
      case 'language':
        return Icons.language;
      case 'speed':
        return Icons.speed;
      case 'router':
        return Icons.router;
      case 'swap_horiz':
        return Icons.swap_horiz;
      default:
        return Icons.apps;
    }
  }

  Widget _buildServiceTile({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28.sp,
                  color: AppColors.secondaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
