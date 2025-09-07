import 'dart:developer';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Wow/pages/login_page/api/check_user_exist_api.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:Wow/pages/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/pages/login_page/api/login_api.dart';
import 'package:Wow/pages/login_page/model/login_model.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/internet_connection.dart';
import 'package:Wow/utils/utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  RxBool isAgreedToTerms = false.obs;

  List<String> randomNames = [
    "Emily Johnson",
    "Liam Smith",
    "Isabella Martinez",
    "Noah Brown",
    "Sofia Davis",
    "Oliver Wilson",
    "Mia Anderson",
    "James Thomas",
    "Ava Robinson",
    "Benjamin Lee",
    "Charlotte Miller",
    "Lucas Garcia",
    "Amelia White",
    "Ethan Harris",
    "Harper Clark",
    "Alexander Lewis",
    "Evelyn Walker",
    "Daniel Hall",
    "Grace Young",
    "Michael Allen",
  ];

  String onGetRandomName() {
    math.Random random = new math.Random();
    int index = random.nextInt(randomNames.length);
    return randomNames[index];
  }

  /// Diagnostic method to check Google Sign-In configuration
  Future<void> diagnoseGoogleSignIn() async {
    Utils.showLog('🔍 Starting comprehensive Google Sign-In diagnostics...');

    try {
      // Test 1: Firebase initialization
      Utils.showLog('🔍 Testing Firebase initialization...');
      final firebaseApp = auth.FirebaseAuth.instance.app;
      if (firebaseApp.name.isNotEmpty) {
        Utils.showLog('✅ Firebase initialized: ${firebaseApp.name}');
        Utils.showLog('✅ Project ID: ${firebaseApp.options.projectId}');
        Utils.showLog('✅ App ID: ${firebaseApp.options.appId}');
      } else {
        Utils.showLog('❌ Firebase not properly initialized');
        return;
      }

      // Test 2: Google Sign-In basic initialization
      Utils.showLog('🔍 Testing Google Sign-In initialization...');
      try {
        final basicGoogleSignIn = GoogleSignIn();
        Utils.showLog('✅ Basic GoogleSignIn created successfully');

        // Test with server client ID
        final advancedGoogleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId:
              '41616583072-j07mvrcvrgpmor9tpoos19k0l97n74el.apps.googleusercontent.com',
        );
        Utils.showLog(
            '✅ Advanced GoogleSignIn with serverClientId created successfully');
      } catch (e) {
        Utils.showLog('❌ GoogleSignIn initialization failed: $e');
      }

      // Test 3: Check for existing sessions
      Utils.showLog('🔍 Checking for existing sessions...');
      try {
        final googleSignIn = GoogleSignIn();
        final currentUser = await googleSignIn.signInSilently();
        if (currentUser != null) {
          Utils.showLog(
              'ℹ️ Found existing Google session: ${currentUser.email}');
          Utils.showLog('ℹ️ Display name: ${currentUser.displayName}');
          Utils.showLog('ℹ️ ID: ${currentUser.id}');

          // Test authentication tokens
          try {
            final auth = await currentUser.authentication;
            Utils.showLog('✅ Can get auth tokens from existing session');
            Utils.showLog(
                '✅ Access token: ${auth.accessToken != null ? "Present" : "Missing"}');
            Utils.showLog(
                '✅ ID token: ${auth.idToken != null ? "Present" : "Missing"}');
          } catch (e) {
            Utils.showLog('❌ Cannot get auth tokens: $e');
          }

          // Clear session for clean testing
          await googleSignIn.signOut();
          Utils.showLog('✅ Cleared existing session');
        } else {
          Utils.showLog('ℹ️ No existing Google session found');
        }
      } catch (e) {
        Utils.showLog('❌ Error checking existing sessions: $e');
      }

      // Test 4: Firebase Auth current user
      Utils.showLog('🔍 Checking Firebase Auth current user...');
      final currentFirebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        Utils.showLog(
            'ℹ️ Firebase user logged in: ${currentFirebaseUser.email}');
        Utils.showLog('ℹ️ UID: ${currentFirebaseUser.uid}');
        Utils.showLog(
            'ℹ️ Provider: ${currentFirebaseUser.providerData.map((p) => p.providerId).join(", ")}');

        // Sign out for clean testing
        await auth.FirebaseAuth.instance.signOut();
        Utils.showLog('✅ Signed out Firebase user');
      } else {
        Utils.showLog('ℹ️ No Firebase user currently logged in');
      }

      // Test 5: Platform-specific checks
      Utils.showLog('🔍 Running platform-specific checks...');
      if (GetPlatform.isAndroid) {
        Utils.showLog('📱 Running on Android');
        Utils.showLog(
            'ℹ️ Make sure SHA-1/SHA-256 fingerprints are added to Firebase Console');
        Utils.showLog('ℹ️ google-services.json should be in android/app/');
      } else if (GetPlatform.isIOS) {
        Utils.showLog('📱 Running on iOS');
        Utils.showLog(
            'ℹ️ Make sure GoogleService-Info.plist is in ios/Runner/');
        Utils.showLog('ℹ️ URL schemes should be configured in Info.plist');
      }

      // Test 6: Network connectivity
      Utils.showLog('🔍 Checking network connectivity...');
      if (InternetConnection.isConnect.value) {
        Utils.showLog('✅ Internet connection available');
      } else {
        Utils.showLog('❌ No internet connection');
        return;
      }

      Utils.showLog('✅ Google Sign-In diagnostics completed');
      Utils.showLog('💡 If Google Sign-In still fails, check:');
      Utils.showLog('   1. SHA-1/SHA-256 certificates in Firebase Console');
      Utils.showLog('   2. Package name matches Firebase configuration');
      Utils.showLog('   3. google-services.json is up to date');
      Utils.showLog('   4. Bundle ID matches for iOS');
      Utils.showLog('   5. Firebase project has Google Sign-In enabled');
    } catch (e) {
      Utils.showLog('❌ Diagnostic error: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Run diagnostics on initialization (only in debug mode)
    assert(() {
      Future.delayed(const Duration(seconds: 1), () {
        diagnoseGoogleSignIn();
      });
      return true;
    }());
  }

  Future<void> onQuickLogin() async {
    if (InternetConnection.isConnect.value) {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      // Calling Sign Up Api...

      final isLogin = await CheckUserExistApi.callApi(identity: Database.identity) ?? false;

      Utils.showLog("Quick Login User Is Exist => ${isLogin}");

      try {
        loginModel = isLogin
            ? await LoginApi.callApi(
                loginType: 3,
                email: Database.identity,
                identity: Database.identity,
                fcmToken: Database.fcmToken,
              )
            : await LoginApi.callApi(
                loginType: 3,
                email: Database.identity,
                identity: Database.identity,
                fcmToken: Database.fcmToken,
                userName: onGetRandomName(),
              );
      } catch (e) {
        Utils.showLog("Error in Quick Login: $e");
        Get.back(); // Stop Loading...
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        return;
      }

      Get.back(); // Stop Loading...

      if (loginModel?.status == true && loginModel?.user?.id != null) {
        await onGetProfile(loginUserId: loginModel!.user!.id!); // Get Profile Api...
      } else if (loginModel?.message == "You are blocked by the admin.") {
        Utils.showToast("${loginModel?.message}");
        Utils.showLog("User Blocked By Admin !!");
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Login Api Calling Failed !!");
      }
    } else {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
    }
  }

  Future<void> onGoogleLogin() async {
    // Check terms agreement first
    if (!isAgreedToTerms.value) {
      Utils.showToast('Please agree to Terms of Service to continue');
      return;
    }

    if (!InternetConnection.isConnect.value) {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
      return;
    }

    try {
      Utils.showLog('🔄 Starting Google Sign-In process');
      // Rely on platform config (google-services.json / Info.plist) to avoid mismatches
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Step 2: Clear any existing sessions
      try {
        await googleSignIn.signOut();
        await auth.FirebaseAuth.instance.signOut();
        Utils.showLog('✅ Cleared previous sessions');
      } catch (e) {
        Utils.showLog('ℹ️ No previous session to clear: $e');
      }

      // Step 3: Perform Google Sign-In
      Utils.showLog('🔄 Starting Google Sign-In flow...');

      // 1) Try silent sign-in (no popup)
      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
      // 2) If no cached account, disconnect any stale sessions and show picker ONCE
      if (googleUser == null) {
        try { await googleSignIn.disconnect(); } catch (_) {}
        googleUser = await googleSignIn.signIn();
      }

      if (googleUser == null) {
        Get.back(); // Close loading dialog
        Utils.showLog('ℹ️ User cancelled Google Sign-In');
        return;
      }

      Utils.showLog('✅ Google account selected: ${googleUser.email}');
      Utils.showLog('✅ Display Name: ${googleUser.displayName}');
      Utils.showLog('✅ ID: ${googleUser.id}');

      // Show loading only after user has picked an account
      Get.dialog(const LoadingUi(), barrierDismissible: false);

      // Step 4: Get authentication details
      Utils.showLog('🔄 Getting authentication tokens...');

      GoogleSignInAuthentication? googleAuth;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          googleAuth = await googleUser.authentication;
          if (googleAuth.accessToken != null && googleAuth.idToken != null) {
            break;
          }
        } catch (e) {
          Utils.showLog('❌ Auth token attempt $attempt failed: $e');
          if (attempt == 3) throw e;
          await Future.delayed(Duration(milliseconds: 1000));
        }
      }

      if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
        throw Exception('Failed to get valid authentication tokens');
      }

      Utils.showLog('✅ Got authentication tokens');
      Utils.showLog(
          '✅ Access Token: ${googleAuth!.accessToken != null ? "Present" : "Missing"}');
      Utils.showLog(
          '✅ ID Token: ${googleAuth.idToken != null ? "Present" : "Missing"}');

      // Step 5: Create Firebase credential and sign in
      Utils.showLog('🔄 Creating Firebase credential...');

      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      Utils.showLog('✅ Firebase credential created');
      Utils.showLog('🔄 Signing in to Firebase...');

      auth.UserCredential? userCredential;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          userCredential =
              await auth.FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential.user != null) {
            break;
          }
        } catch (e) {
          Utils.showLog('❌ Firebase sign-in attempt $attempt failed: $e');
          if (attempt == 3) throw e;
          await Future.delayed(Duration(milliseconds: 1500));
        }
      }

      if (userCredential?.user == null) {
        throw Exception('Firebase authentication returned no user');
      }

      final firebaseUser = userCredential!.user!;
      Utils.showLog('✅ Firebase sign-in successful');
      Utils.showLog('✅ Firebase User: ${firebaseUser.email}');
      Utils.showLog('✅ Firebase UID: ${firebaseUser.uid}');
      Utils.showLog('✅ Email Verified: ${firebaseUser.emailVerified}');

      // Step 6: Call your login API
      Utils.showLog('🔄 Calling Login API...');

      LoginModel? apiLoginResult;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          apiLoginResult = await LoginApi.callApi(
            loginType: 2,
            email: firebaseUser.email ?? googleUser.email,
            identity: Database.identity,
            fcmToken: Database.fcmToken,
            userName: firebaseUser.displayName ??
                googleUser.displayName ??
                googleUser.email.split('@')[0] ??
                "Google User",
          );
          break;
        } catch (e) {
          Utils.showLog('❌ Login API attempt $attempt failed: $e');
          if (attempt == 3) {
            throw Exception('Login API failed after 3 attempts: $e');
          }
          await Future.delayed(Duration(milliseconds: 2000));
        }
      }

      loginModel = apiLoginResult;

      Utils.showLog('📡 Login API Status: ${loginModel?.status}');
      Utils.showLog('📡 Login API Message: ${loginModel?.message}');
      Utils.showLog('📡 User ID: ${loginModel?.user?.id}');

      Get.back(); // Close loading dialog

      // Step 7: Handle API response
      if (loginModel?.status == true && loginModel?.user?.id != null) {
        Utils.showLog("✅ Login successful, getting user profile...");
        Utils.showToast("Login successful!");
        await onGetProfile(loginUserId: loginModel!.user!.id!);
      } else if (loginModel?.message?.toLowerCase().contains("blocked") ==
          true) {
        Utils.showToast("Your account has been blocked by admin");
        Utils.showLog("❌ User blocked by admin");
      } else {
        String errorMsg =
            loginModel?.message ?? "Login failed. Please try again.";
        Utils.showToast(errorMsg);
        Utils.showLog("❌ Login API failed: $errorMsg");
      }

    } catch (e) {
      Get.back(); // Close loading dialog

      String userMessage;
      String logMessage = "❌ Google Sign-In Error: ${e.toString()}";

      // Parse specific error types for user-friendly messages
      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains('network') || errorStr.contains('timeout')) {
        userMessage =
            "Network error. Please check your internet connection and try again.";
      } else if (errorStr.contains('cancelled') || errorStr.contains('12501')) {
        userMessage = "Sign-in was cancelled";
        logMessage = "ℹ️ User cancelled Google Sign-In";
      } else if (errorStr.contains('sign_in_failed') ||
          errorStr.contains('10:')) {
        userMessage =
            "Google Sign-In configuration error. Please contact support.";
      } else if (errorStr.contains('invalid') ||
          errorStr.contains('credential')) {
        userMessage = "Invalid credentials. Please try again.";
      } else if (errorStr.contains('blocked') ||
          errorStr.contains('disabled')) {
        userMessage = "This account has been disabled.";
      } else {
        userMessage = "Google Sign-In failed. Please try again.";
      }

      Utils.showLog(logMessage);
      Utils.showToast(userMessage);
    }
  }

  static Future<Map<String, dynamic>?> signInWithGoogleImproved() async {
    // This method is now deprecated in favor of the more robust onGoogleLogin method above
    // Keeping for compatibility but recommend using onGoogleLogin directly
    return {'error': 'This method is deprecated. Use onGoogleLogin directly.'};
  }

  Future<void> onGetProfile({required String loginUserId}) async {
    Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
    try {
      fetchLoginUserProfileModel =
          await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId);
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Error in Get Profile: $e");
      return;
    }
    Get.back(); // Stop Loading...

    if (fetchLoginUserProfileModel?.user?.id != null && fetchLoginUserProfileModel?.user?.loginType != null) {
      Database.onSetIsNewUser(false);
      Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
      Database.onSetLoginType(int.parse((fetchLoginUserProfileModel?.user?.loginType ?? 0).toString()));
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    /*  if (fetchLoginUserProfileModel?.user?.country == "" || fetchLoginUserProfileModel?.user?.bio == "") {
        Get.toNamed(AppRoutes.fillProfilePage);
      } else {*/
        Get.offAllNamed(AppRoutes.bottomBarPage);
    //  }
    } else {
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Get Profile Api Calling Failed !!");
    }
  }

  loginWithApple() async {
    try {
      Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      var authResult = await auth.FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      final user = authResult.user;
      log("oauthCredential :: $oauthCredential");
      log("user :: $user");
      if (user != null) {
        ///=====CALL API======///
        try {
          loginModel = await LoginApi.callApi(
            loginType: 4,
            email: user.email ?? ' ',
            identity: Database.identity,
            fcmToken: Database.fcmToken,
            userName: user.displayName ?? "",
          );
        } catch (e) {
          Get.back(); // Stop Loading...
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          log("Error in Apple Login: $e");
          return;
        }

        Get.back(); // Stop Loading...

        if (loginModel?.status == true && loginModel?.user?.id != null) {
          await onGetProfile(loginUserId: loginModel!.user!.id!); // Get Profile Api...
        } else if (loginModel?.message == "You are blocked by the admin.") {
          Utils.showToast("${loginModel?.message}");
          Utils.showLog("User Blocked By Admin !!");
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          Utils.showLog("Login Api Calling Failed !!");
        }
      } else {
        Get.back(); // Stop Loading...
      }
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      log(" $e");
    }
  }
}
