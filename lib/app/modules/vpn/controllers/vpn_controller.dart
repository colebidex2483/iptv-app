import 'package:get/get.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';

class VPNController extends GetxController {
  final Rx<FlutterVpnState> vpnState = FlutterVpnState.disconnected.obs;
  final RxBool isConnecting = false.obs;

  final String server = "fi2.vpnjantit.com"; // Replace with real server IP or domain
  final String username = "ibotv-vpnjantit.com";
  final String password = "ibotv";
  final String psk = "providedPsk";

  @override
  void onInit() {
    super.onInit();
    FlutterVpn.prepare();
    FlutterVpn.onStateChanged.listen((state) {
      vpnState.value = state;
      isConnecting.value = false;
    });
  }

  Future<void> connectVPN() async {
    isConnecting.value = true;
    await FlutterVpn.connectIkev2EAP(
      server: server,
      username: username,
      password: password,
    );
  }

  Future<void> disconnectVPN() async {
    await FlutterVpn.disconnect();
    isConnecting.value = false;
  }

  void toggleVPN() {
    if (vpnState.value == FlutterVpnState.connected) {
      disconnectVPN();
    } else {
      connectVPN();
    }
  }
}
