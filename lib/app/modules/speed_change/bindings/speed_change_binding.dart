import 'package:get/get.dart';
import '../controllers/speed_change_controller.dart';

class SpeedChangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpeedChangeController>(() => SpeedChangeController());
  }
}
