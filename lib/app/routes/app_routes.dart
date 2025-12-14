part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SERVICES = _Paths.SERVICES;
  static const SUBSCRIPTION = _Paths.SUBSCRIPTION;
  static const LOGIN = _Paths.LOGIN;
  static const DEMANDES = _Paths.DEMANDES;
  static const SERVICE_REQUEST = _Paths.SERVICE_REQUEST;
  static const SPEED_CHANGE = _Paths.SPEED_CHANGE;
  static const FACTURE = _Paths.FACTURE;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SERVICES = '/services';
  static const SUBSCRIPTION = '/subscription';
  static const LOGIN = '/login';
  static const DEMANDES = '/demandes';
  static const SERVICE_REQUEST = '/service-request';
  static const SPEED_CHANGE = '/speed-change';
  static const FACTURE = '/facture';
}
