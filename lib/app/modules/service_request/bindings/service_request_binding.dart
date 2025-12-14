import 'package:get/get.dart';
import '../controllers/service_request_controller.dart';

class ServiceRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceRequestController>(() => ServiceRequestController());
  }
}
