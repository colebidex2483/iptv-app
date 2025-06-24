import 'package:get/get.dart';

import '../controllers/demo_details_controller.dart';

class DemoDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DemoDetailsController>(
      () => DemoDetailsController(),
    );
  }
}
