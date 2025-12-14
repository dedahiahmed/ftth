import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ftth/main.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final PreferredSizeWidget? appBar;
  final bool showBottomNav;

  const AppLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.appBar,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: appBar,
      body: child,
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onNavTap(index),
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Services',
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        if (currentIndex != 0) {
          Get.offAllNamed('/home');
        }
        break;
      case 1:
        if (currentIndex != 1) {
          Get.offAllNamed('/services');
        }
        break;
    }
  }
}

class AppNavBar extends StatelessWidget {
  final int currentIndex;

  const AppNavBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onNavTap(index),
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Services',
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        if (currentIndex != 0) {
          Get.offAllNamed('/home');
        }
        break;
      case 1:
        if (currentIndex != 1) {
          Get.offAllNamed('/services');
        }
        break;
    }
  }
}
