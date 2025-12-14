import 'package:get/get.dart';

import '../controllers/demandes_controller.dart';

class DemandesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DemandesController>(() => DemandesController());
  }
}
