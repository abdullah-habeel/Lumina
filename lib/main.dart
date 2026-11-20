import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/app_pages.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/services/device_info_service.dart';
import 'package:lumina/core/routes/services/notification_services.dart';
import 'package:lumina/core/service/hybrid_ai_service.dart';
import 'package:lumina/core/service/remote_config_service.dart';
import 'package:lumina/features/music/controller/music_controller.dart';
import 'package:lumina/features/music/controller/sound_effects_controller.dart';
import 'package:lumina/features/notification/controller/notification_controller.dart';
import 'package:lumina/features/pin/controller/pin_controller.dart';
import 'package:lumina/features/pin/view/enter_pin_view.dart';
import 'package:lumina/features/review/controller/review_controller.dart';
import 'package:lumina/firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// Fixed debug token — registered once in Firebase Console → App Check
// Never changes regardless of reinstalls
const _appCheckDebugToken = '266011F4-F328-4CA4-A90B-9BF12AF674F9';

Future<void> preloadBookFonts() async {
  GoogleFonts.cinzel();
  GoogleFonts.cormorantGaramond();
  GoogleFonts.lora();
  GoogleFonts.ebGaramond();
  await GoogleFonts.pendingFonts();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFF5EDD9),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FirebaseAnalytics.instance;

  await RemoteConfigService().init();

  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? AndroidDebugProvider(debugToken: _appCheckDebugToken)
        : const AndroidPlayIntegrityProvider(),
  );

  HybridAiService().prepareOnDeviceModel();

  await preloadBookFonts();

  OneSignal.initialize('5b1b66d7-c08c-4447-bdd0-913c72009a13');

  await NotificationService().init();
  await NotificationService().scheduleDailyReminder();

  Get.put(MusicController(), permanent: true);
  Get.put(SoundEffectsController(), permanent: true);
  Get.put(NotificationsController(), permanent: true);
  Get.put(ReviewController(), permanent: true);

  NotificationService().onNotificationTap.listen((payload) {
    NotificationService().handlePayload(payload);
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final PinController pinController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pinController = Get.put(PinController(), permanent: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final musicController = Get.find<MusicController>();

    if (state == AppLifecycleState.paused) {
      pinController.lockApp();
      musicController.pauseForBackground();
    } else if (state == AppLifecycleState.resumed) {
      musicController.resumeFromBackground();
      DeviceInfoService.saveDeviceInfo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lumina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5EDD9),
        fontFamily: GoogleFonts.lora().fontFamily,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      builder: (context, child) {
        return ColoredBox(
          color: const Color(0xFFF5EDD9),
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                child ?? const SizedBox(),
                Obx(() {
                  if (pinController.isLoading.value) {
                    return const SizedBox.shrink();
                  }
                  if (!pinController.isPinEnabled.value ||
                      pinController.isUnlocked.value) {
                    return const SizedBox.shrink();
                  }
                  return const EnterPinView();
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}