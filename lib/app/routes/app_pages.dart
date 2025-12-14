import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/services/bindings/services_binding.dart';
import '../modules/services/views/services_view.dart';
import '../modules/subscription/bindings/subscription_binding.dart';
import '../modules/subscription/views/subscription_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/demandes/bindings/demandes_binding.dart';
import '../modules/demandes/views/demandes_view.dart';
import '../modules/service_request/bindings/service_request_binding.dart';
import '../modules/service_request/views/service_request_view.dart';
import '../modules/speed_change/bindings/speed_change_binding.dart';
import '../modules/speed_change/views/speed_change_view.dart';
import '../modules/facture/bindings/facture_binding.dart';
import '../modules/facture/views/facture_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SERVICES,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION,
      page: () => const SubscriptionView(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DEMANDES,
      page: () => const DemandesView(),
      binding: DemandesBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_REQUEST,
      page: () => const ServiceRequestView(),
      binding: ServiceRequestBinding(),
    ),
    GetPage(
      name: _Paths.SPEED_CHANGE,
      page: () => const SpeedChangeView(),
      binding: SpeedChangeBinding(),
    ),
    GetPage(
      name: _Paths.FACTURE,
      page: () => const FactureView(),
      binding: FactureBinding(),
    ),
  ];
}
