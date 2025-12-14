import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';
import 'package:ftth/app/services/notification_service.dart';

class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetX<NotificationService>(
      builder: (notificationService) {
        final count = notificationService.enCoursCount.value;

        return GestureDetector(
          onTap: onTap ?? () => Get.toNamed('/demandes'),
          child: Container(
            padding: EdgeInsets.all(8.r),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.secondaryColor,
                  size: 26.sp,
                ),
                if (count > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.r,
                        minHeight: 18.r,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
