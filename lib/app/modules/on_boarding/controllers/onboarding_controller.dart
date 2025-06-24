import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class OnboardingController extends GetxController {
  final RxBool isTrialActive = false.obs;
  final RxInt daysLeft = 0.obs;
  final RxString deviceId = 'Loading...'.obs;
  final RxString deviceKey = 'Loading...'.obs;
  final Rx<DateTime> trialStartDate = DateTime.now().obs;

  // Trial duration in days
  static const int trialDurationDays = 6;

  late final DeviceInfoPlugin _deviceInfo;

  @override
  void onInit() {
    super.onInit();
    _deviceInfo = DeviceInfoPlugin();
    initializeDeviceInfo();
  }

  Future<void> initializeDeviceInfo() async {
    try {
      String id = 'unknown-device';

      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        id = android.id ?? android.fingerprint ?? 'unknown-android';
      } else if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        id = ios.identifierForVendor ?? 'unknown-ios';
      }

      deviceId.value = id;

      final packageInfo = await PackageInfo.fromPlatform();
      final rawKey = '${packageInfo.packageName}-$id';
      deviceKey.value = rawKey.hashCode.toRadixString(36);

      await checkTrialStatus();
    } catch (e) {
      print('Error getting device info: $e');
      deviceId.value = 'error';
      deviceKey.value = 'error';
    }
  }


  Future<void> checkTrialStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final isActivated = prefs.getBool('isActivated') ?? false;
    if (isActivated) {
      isTrialActive.value = true;
      daysLeft.value = trialDurationDays;
      return;
    }

    final savedDate = prefs.getString('trialStartDate');
    if (savedDate == null) {
      trialStartDate.value = DateTime.now();
      await prefs.setString('trialStartDate', trialStartDate.value.toIso8601String());
      daysLeft.value = trialDurationDays - 1;
      isTrialActive.value = true;
      return;
    }

    trialStartDate.value = DateTime.parse(savedDate);
    final difference = DateTime.now().difference(trialStartDate.value).inDays;
    daysLeft.value = trialDurationDays - 1 - difference;
    isTrialActive.value = daysLeft.value >= 0;

    if (!isTrialActive.value) {
      await prefs.remove('trialStartDate');
    }
  }

  Future<void> launchPaymentWebsite() async {
    const url = 'https://livecostplayer.com';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch website');
    }
  }

  Future<void> activateFullVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isActivated', true);
    isTrialActive.value = true;
    daysLeft.value = trialDurationDays;
  }
}
