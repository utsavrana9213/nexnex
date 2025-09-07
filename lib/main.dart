import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:Wow/firebase_options.dart';
import 'package:Wow/localization/locale_constant.dart';
import 'package:Wow/localization/localizations_delegate.dart';
import 'package:Wow/routes/app_pages.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/constant.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/internet_connection.dart';
import 'package:Wow/utils/notification_services.dart';
import 'package:Wow/utils/platform_device_id.dart';
import 'package:Wow/utils/utils.dart';

List<CameraDescription> _cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _cameras = await availableCameras().timeout(
      const Duration(seconds: 5),
      onTimeout: () => <CameraDescription>[],
    );
  } catch (e) {
    Utils.showLog("Camera initialization failed: $e");
  }

  await GetStorage.init();
  InternetConnection.init();

  await Firebase.initializeApp(
    name: "NexNexAppp",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await onInitializeCrashlytics();

  try {
    final identity = await PlatformDeviceId.getDeviceId;
    final fcmToken = await FirebaseMessaging.instance
        .getToken()
        .timeout(const Duration(seconds: 5), onTimeout: () => null);

    Utils.showLog("Device Id => $identity");
    Utils.showLog("FCM Token => $fcmToken");

    if (identity != null && fcmToken != null) {
      await Future.microtask(() => Database.init(identity, fcmToken));
    }
  } catch (e) {
    Utils.showLog("Device ID or FCM Token fetch error => $e");
  }

  try {
    await NotificationServices.init();
    NotificationServices.firebaseInit();
    FirebaseMessaging.onBackgroundMessage(
        NotificationServices.onShowBackgroundNotification);
  } catch (e) {
    Utils.showLog("Notification Init Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final StreamController<PurchaseDetails> purchaseStreamController =
      StreamController<PurchaseDetails>.broadcast();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Utils.isAppOpen.value = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Utils.isAppOpen.value = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Utils.isAppOpen.value = true;
      Utils.showLog("User Back To App...");
    } else if (state == AppLifecycleState.inactive) {
      Utils.isAppOpen.value = false;
      Utils.showLog("User Try To Exit...");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getLocale().then((locale) {
      if (mounted) {
        setState(() {
          Get.updateLocale(locale);
          Utils.showLog("Language Code => ${locale.languageCode}");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: EnumLocal.txtAppName.name.tr,
      debugShowCheckedModeBanner: false,
      color: AppColor.white,
      translations: AppLanguages(),
      fallbackLocale: const Locale(AppConstant.languageEn, AppConstant.countryCodeEn),
      locale: const Locale(AppConstant.languageEn),
      defaultTransition: Transition.fade,
      getPages: AppPages.list,
      initialRoute: AppRoutes.initial,
    );
  }
}

// ───────────────────────── Extensions ─────────────────────────
extension HeightExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
}

extension WidthExtension on num {
  SizedBox get width => SizedBox(width: toDouble());
}

// ───────────────────────── Firebase Crashlytics Init ─────────────────────────
Future<void> onInitializeCrashlytics() async {
  try {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    Utils.showLog("Initialize Crashlytics Failed => $e");
  }
}

// ───────────────────────── Branch.io Init ─────────────────────────
Future<void> onInitializeBranchIo() async {
  try {
    await FlutterBranchSdk.init();
  } catch (e) {
    Utils.showLog("Initialize Branch SDK Failed => $e");
  }
}
