import 'package:get/get.dart';
import '../controllers/facture_controller.dart';

class FactureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FactureController>(() => FactureController());
  }
}
