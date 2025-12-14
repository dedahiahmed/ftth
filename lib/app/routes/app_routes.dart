part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SERVICES = _Paths.SERVICES;
  static const SUBSCRIPTION = _Paths.SUBSCRIPTION;
  static const LOGIN = _Paths.LOGIN;
  static const DEMANDES = _Paths.DEMANDES;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SERVICES = '/services';
  static const SUBSCRIPTION = '/subscription';
  static const LOGIN = '/login';
  static const DEMANDES = '/demandes';
}
