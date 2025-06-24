import 'package:get/get.dart';

class HomeTabController extends GetxController {
  var selectedTab = 'Live'.obs;

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void changeTabByIndex(int index) {
    switch (index) {
      case 0:
        selectedTab.value = 'Live';
        break;
      case 1:
        selectedTab.value = 'Movies';
        break;
      case 2:
        selectedTab.value = 'Series';
        break;
      default:
        selectedTab.value = 'Live';
    }
  }
}