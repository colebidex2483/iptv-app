import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/on_boarding/bindings/onboarding_binding.dart';
import 'package:ibo_clone/app/modules/on_boarding/views/onboarding_page.dart';

import '../modules/demo_details/bindings/demo_details_binding.dart';
import '../modules/demo_details/views/demo_details_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_tabs.dart';
import '../modules/playlists/bindings/playlists_binding.dart';
import '../modules/playlists/views/playlist_page.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/spalsh/views/splash_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPALSH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () =>  HomeTabs(initialTabIndex: 0),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPALSH,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.PLAYLISTS,
      page: () => const PlaylistsPage(),
      binding: PlaylistsBinding(),
    ),
    GetPage(
      name: _Paths.DEMO_DETAILS,
      page: () => const HomeView(),
      binding: DemoDetailsBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
