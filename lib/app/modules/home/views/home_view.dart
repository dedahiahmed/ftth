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
                _buildPackagesSection(),
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
                onPressed: () {},
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
        default:
          return Icons.apps;
      }
    }

    return GestureDetector(
      onTap: () {},
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

  Widget _buildPackagesSection() {
    final packages = [
      {
        'name': 'Basic',
        'speed': '10 Mbps',
        'price': '5000',
        'color': Colors.teal,
        'features': [
          'Internet illimité',
          'Support 24/7',
          'Installation gratuite',
        ],
      },
      {
        'name': 'Standard',
        'speed': '25 Mbps',
        'price': '10000',
        'color': AppColors.primaryColor,
        'features': [
          'Internet illimité',
          'Support prioritaire',
          'Installation gratuite',
          'Router inclus',
        ],
      },
      {
        'name': 'Premium',
        'speed': '50 Mbps',
        'price': '20000',
        'color': Colors.orange,
        'features': [
          'Internet illimité',
          'Support VIP',
          'Installation gratuite',
          'Router premium',
          'IP fixe',
        ],
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Forfaits recommandés',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
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
            height: 320.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: packages.length,
              itemBuilder: (context, index) {
                return _buildPackageCard(packages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: package['color'] as Color,
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      color: AppColors.secondaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${package['price']} MRU/mois',
                        style: TextStyle(
                          color: package['color'] as Color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...(package['features'] as List<String>).map((feature) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.r),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: AppColors.secondaryColor,
                              size: 12.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12.sp,
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
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: package['color'] as Color,
                        side: BorderSide(
                          color: package['color'] as Color,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
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
    );
  }
}
