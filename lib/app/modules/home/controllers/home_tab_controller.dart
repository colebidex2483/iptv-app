import 'package:get/get.dart';

class HomeTabController extends GetxController {
  var selectedTab = 'live'.obs;

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void changeTabByIndex(int index) {
    switch (index) {
      case 0:
        selectedTab.value = 'home';
        break;
      case 1:
        selectedTab.value = 'live';
        break;
      case 2:
        selectedTab.value = 'movies';
        break;
      case 3:
        selectedTab.value = 'series';
        break;
      default:
        selectedTab.value = 'home';
    }
  }
}