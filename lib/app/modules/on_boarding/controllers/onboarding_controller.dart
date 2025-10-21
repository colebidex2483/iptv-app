import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ibo_clone/app/modules/demo_details/views/demo_details_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:ibo_clone/app/core/firebase_service.dart';

class OnboardingController extends GetxController {
  final RxBool isTrialActive = false.obs;
  final RxBool isActivated = false.obs;
  final RxInt daysLeft = 0.obs;
  final RxString deviceId = 'Loading...'.obs;
  final RxString deviceKey = 'Loading...'.obs;
  final Rx<DateTime> trialStartDate = DateTime.now().obs;
  final FirebaseService _firebaseService = FirebaseService();
  final RxString warningMessage = ''.obs;
  static const int trialDurationDays = 50;
  static const int warningThreshold = 3;
  late final DeviceInfoPlugin _deviceInfo;
  final RxBool isInitialized = false.obs;
  @override
  void onInit() {
    super.onInit();
    _deviceInfo = DeviceInfoPlugin();
    // initializeDeviceInfo();
  }

  Future<void> initializeApp() async {
    await initializeDeviceInfo();  // Already exists
    isInitialized.value = true;
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

      await _firebaseService.ensureDeviceDocumentExists(deviceId.value);
      final packageInfo = await PackageInfo.fromPlatform();
      final rawKey = '${packageInfo.packageName}-$id';
      deviceKey.value = rawKey.hashCode.toRadixString(36);

      final prefs = await SharedPreferences.getInstance();

      final doc = await _firebaseService.getActivationByDeviceId(deviceId.value);
      if (doc != null && doc['trialStartDate'] != null) {
        trialStartDate.value = DateTime.parse(doc['trialStartDate']);

        if (doc['isActivated'] == true) {
          await prefs.setBool('isActivated', true);
          isTrialActive.value = false;
          daysLeft.value = 0;
          return;
        } else if (doc['isTrialActive'] == true) {
          final now = await getOnlineDateTime();
          final today = DateTime(now.year, now.month, now.day);
          final start = DateTime(trialStartDate.value.year, trialStartDate.value.month, trialStartDate.value.day);
          final difference = today.difference(start).inDays;

          daysLeft.value = trialDurationDays - difference;
          isTrialActive.value = daysLeft.value > 0;

          await prefs.setBool('isTrialActive', isTrialActive.value);
          await prefs.setString('trialStartDate', trialStartDate.value.toIso8601String());

          await _firebaseService.updateTrialStatus(
            deviceId: deviceId.value,
            daysLeft: daysLeft.value,
            isTrialActive: isTrialActive.value,
          );

          showTrialWarning();
          return;
        }
      }

      await checkTrialStatus(doc);

      final alreadySent = prefs.getBool('deviceInfoSent') ?? false;
      if (!alreadySent || doc == null) {
        await _firebaseService.logDeviceInfo(
          deviceId: deviceId.value,
          deviceKey: deviceKey.value,
          isTrialActive: isTrialActive.value,
          daysLeft: daysLeft.value,
          trialStartDate: trialStartDate.value,
        );
        await prefs.setBool('deviceInfoSent', true);
      }
    } catch (e) {
      print('Error initializing device info: $e');
      deviceId.value = 'error';
      deviceKey.value = 'error';
    }
  }

  Future<DateTime> getOnlineDateTime({int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await http.get(Uri.parse('https://worldtimeapi.org/api/ip'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return DateTime.parse(data['datetime']);
        }
      } catch (e) {
        print('Failed to get online time (attempt ${i + 1}): $e');
      }
    }
    print('⚠️ Fallback to local time');
    return DateTime.now();
  }

  Future<void> checkTrialStatus([Map<String, dynamic>? doc]) async {
    final prefs = await SharedPreferences.getInstance();
    final isActivated = prefs.getBool('isActivated') ?? false;
    final savedDate = prefs.getString('trialStartDate');

    if (isActivated) {
      isTrialActive.value = false;
      return;
    }

    if (savedDate == null) {
      final onlineDate = await getOnlineDateTime();
      trialStartDate.value = onlineDate;
      await prefs.setString('trialStartDate', onlineDate.toIso8601String());
      await prefs.setBool('isTrialActive', true);
      isTrialActive.value = true;
      daysLeft.value = trialDurationDays;
      print('🆕 Trial just started. Days left: ${daysLeft.value}');
    } else {
      trialStartDate.value = DateTime.parse(savedDate);
      final now = await getOnlineDateTime();
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(trialStartDate.value.year, trialStartDate.value.month, trialStartDate.value.day);
      final difference = today.difference(start).inDays;

      daysLeft.value = trialDurationDays - difference;
      isTrialActive.value = daysLeft.value > 0;
      if (doc != null) {
        await _firebaseService.updateTrialStatus(
          deviceId: deviceId.value,
          daysLeft: daysLeft.value,
          isTrialActive: isTrialActive.value,
        );
      }


      if (!isTrialActive.value) {
        await prefs.remove('trialStartDate');
        await prefs.setBool('isTrialActive', false);
      }
    }

    showTrialWarning();
  }

  void showTrialWarning() {
    if (isTrialActive.value && daysLeft.value <= warningThreshold) {
      warningMessage.value = '⚠️ Trial expires in ${daysLeft.value} day(s)!';
    } else {
      warningMessage.value = '';
    }
  }

  Future<void> launchPaymentWebsite() async {
    const url = 'https://livecostplayer.com';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch URL';
      }

  }

  Future<void> activateFullVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isActivated', true);
    isTrialActive.value = true;
    daysLeft.value = trialDurationDays;
  }
}
