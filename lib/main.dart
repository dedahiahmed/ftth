import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftth/app/routes/app_pages.dart';
import 'package:ftth/app/services/auth_service.dart';
import 'package:ftth/app/services/form_persistence_service.dart';
import 'package:ftth/app/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:ftth/app/configs/dev.dart' as dev;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

late Logger logger;
late SharedPreferences pref;

late SupabaseClient supabase;

class AppColors {
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.white;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first so we can see all initialization logs
  logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  _configureEasyLoading();

  // Set status bar to transparent with light icons globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  await Supabase.initialize(
    url: dev.Config.supabaseUrl,
    anonKey: dev.Config.supabaseAnonKey,
  );
  supabase = Supabase.instance.client;

  // Initialize GetX services
  Get.put(AuthService(), permanent: true);
  Get.put(FormPersistenceService(), permanent: true);
  Get.put(NotificationService(), permanent: true);

  // Keep preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  pref = await SharedPreferences.getInstance();

  runApp(
    ScreenUtilInit(
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return GetMaterialApp(
          title: "FTTH",
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
          debugShowCheckedModeBanner: false,
          enableLog: true,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr'), Locale('ar'), Locale('en')],
          fallbackLocale: const Locale('fr'),
          builder: EasyLoading.init(
            builder: (BuildContext context, Widget? child) {
              return ToastificationWrapper(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..lineWidth = 4
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = AppColors.primaryColor
    ..backgroundColor = Colors.white
    ..indicatorColor = AppColors.primaryColor
    ..textColor = Colors.black
    ..maskColor = Colors.white.withValues(alpha: 1)
    ..indicatorWidget = LoadingAnimationWidget.discreteCircle(
      color: AppColors.primaryColor,
      thirdRingColor: AppColors.primaryColor,
      size: 60.0,
    )
    ..boxShadow = [
      BoxShadow(
        color: AppColors.primaryColor.withValues(alpha: 0),
        blurRadius: 20,
        offset: const Offset(5, 5),
      ),
    ]
    ..maskType = EasyLoadingMaskType.custom
    ..userInteractions = false
    ..dismissOnTap = false;
}
