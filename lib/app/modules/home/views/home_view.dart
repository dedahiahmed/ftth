import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';
import 'package:ftth/app/widgets/app_layout.dart';
import 'package:ftth/app/widgets/notification_badge.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 0,
      appBar: _buildAppBar(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildCitiesSection(),
                SizedBox(height: 24.h),
                _buildQuickServicesSection(),
                SizedBox(height: 24.h),
                _buildFTTHPackagesSection(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      }),
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
        const NotificationBadge(),
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

  Widget _buildCitiesSection() {
    final cities = [
      {'name': 'Nouakchott', 'image': 'assets/images/nouakchott.jpg'},
      {'name': 'Nouadhibou', 'image': 'assets/images/noudhibou.jpg'},
      {'name': 'Rosso', 'image': 'assets/images/rosso.jpg'},
      {'name': 'Kaédi', 'image': 'assets/images/kaedi.jpg'},
      {'name': 'Kiffa', 'image': 'assets/images/kiffa.jpeg'},
      {'name': 'Aïoun', 'image': 'assets/images/laeyoun.jpg'},
      {'name': 'Néma', 'image': 'assets/images/nema.jpg'},
      {'name': 'Sélibabi', 'image': 'assets/images/selibabib.jpg'},
      {'name': 'Tidjikja', 'image': 'assets/images/tejkja.jpg'},
      {'name': 'Atar', 'image': 'assets/images/atar.jpg'},
      {'name': 'Akjoujt', 'image': 'assets/images/Akjoujt.JPG'},
      {'name': 'Zouérate', 'image': 'assets/images/zouerate.jpg'},
      {'name': 'Aleg', 'image': 'assets/images/aleg.jpg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'FTTH',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Disponible à',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: cities.length,
            itemBuilder: (context, index) {
              return _buildCityCard(cities[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityCard(Map<String, String> city) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Image.asset(
                city['image']!,
                height: 140.h,
                width: 160.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140.h,
                  width: 160.w,
                  color: AppColors.primaryColor.withOpacity(0.3),
                  child: Icon(
                    Icons.location_city,
                    size: 50.sp,
                    color: AppColors.primaryColor.withOpacity(0.5),
                  ),
                ),
              ),
              Container(
                height: 140.h,
                width: 160.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12.h,
                left: 12.w,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city['name']!,
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Couverture FTTH',
                      style: TextStyle(
                        color: AppColors.secondaryColor.withOpacity(0.8),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickServicesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services rapides',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => controller.navigateToServices(),
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: controller.quickActions.length,
              itemBuilder: (context, index) {
                return _buildServiceItem(controller.quickActions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> action) {
    IconData getIcon(String iconName) {
      switch (iconName) {
        case 'list_alt':
          return Icons.list_alt;
        case 'wifi':
          return Icons.wifi;
        case 'add_circle':
          return Icons.add_circle_outline;
        case 'receipt':
          return Icons.receipt_long;
        case 'report_problem':
          return Icons.report_problem_outlined;
        case 'phone':
          return Icons.phone;
        case 'speed':
          return Icons.speed;
        case 'language':
          return Icons.language;
        default:
          return Icons.apps;
      }
    }

    return GestureDetector(
      onTap: () => controller.navigateToQuickAction(action),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getIcon(action['icon']),
                color: AppColors.primaryColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              action['title'],
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFTTHPackagesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'FTTH',
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Forfaits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => controller.navigateToServices(),
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 380.h,
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.ftthPackages.length,
              itemBuilder: (context, index) {
                return _buildFTTHPackageCard(controller.ftthPackages[index]);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFTTHPackageCard(Map<String, dynamic> package) {
    final color = Color(package['color'] as int);
    final isPopular = package['popular'] as bool;
    final features = (package['features'] as List<String>).take(4).toList();

    return Container(
      width: 220.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Header with speed
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package['name'] as String,
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          color: AppColors.secondaryColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          package['speed'] as String,
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${package['price']} MRU/mois',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Features
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...features.map((feature) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 2.h),
                                padding: EdgeInsets.all(2.r),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: AppColors.secondaryColor,
                                  size: 8.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => controller.subscribeToPackage(package),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: AppColors.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'Souscrire',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Popular badge
          if (isPopular)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 12.sp),
                    SizedBox(width: 3.w),
                    Text(
                      'Populaire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
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
}
