import 'package:get/get.dart';
import '../controllers/home_tab_controller.dart'; // Changed to import HomeTabController

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeTabController>( // Changed from HomeController to HomeTabController
          () => HomeTabController(),
    );
  }
}