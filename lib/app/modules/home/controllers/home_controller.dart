import 'package:get/get.dart';

class HomeTabController extends GetxController {
  // Rx variable to track the selected tab
  final RxString selectedTab = 'Home'.obs;
  final RxInt selectedTabIndex = 0.obs;

  // Method to change tab by name
  void changeTab(String tabName) {
    selectedTab.value = tabName;
    // Update index based on tab name
    switch (tabName) {
      case 'Home':
        selectedTabIndex.value = 0;
        break;
      case 'Live':
        selectedTabIndex.value = 1;
        break;
      case 'Movies':
        selectedTabIndex.value = 2;
        break;
      case 'Series':
        selectedTabIndex.value = 3;
        break;
    }
  }

  // Method to change tab by index
  void changeTabByIndex(int index) {
    selectedTabIndex.value = index;
    // Update tab name based on index
    switch (index) {
      case 0:
        selectedTab.value = 'Home';
        break;
      case 1:
        selectedTab.value = 'Live';
        break;
      case 2:
        selectedTab.value = 'Movies';
        break;
      case 3:
        selectedTab.value = 'Series';
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialization code if needed
  }

  @override
  void onReady() {
    super.onReady();
    // Post-frame initialization if needed
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}