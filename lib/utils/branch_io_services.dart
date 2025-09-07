import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:Wow/utils/api.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:Wow/utils/utils.dart';

import '../routes/app_routes.dart';
import 'database.dart';

class BranchIoServices {
  static BranchContentMetaData branchContentMetaData = BranchContentMetaData();
  static BranchUniversalObject? branchUniversalObject;
  static BranchLinkProperties branchLinkProperties = BranchLinkProperties();

  static String eventId = "";
  static String eventType = "";
  static String eventName = "";
  static String eventImage = "";
  static String eventUserId = "";
  static String eventRoomId = "";
  static String eventUserName = "";
  static int eventViews = 1;
  static bool eventIsFollow = false;
  static bool eventIsHost = false;
  static bool eventIsProfileImageBanned = false;
  static String eventVideoUrl = "";

  // This is Use to Splash Screen...
  static void onListenBranchIoLinks() async {
    StreamController<String> streamController = StreamController<String>();
    StreamSubscription<Map>? streamSubscription = FlutterBranchSdk.listSession().listen(
      (data) async {
        log('Click To Branch Io Link => $data');
        streamController.sink.add((data.toString()));

        if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
          log("Click To Branch Io Link Page Routes => ${data['id']} ====== ${data['roomId']}");

          eventId = data["roomId"] ?? "";
          eventRoomId = data["roomId"] ?? "";
          eventType = data['pageRoutes'];
          eventName = data["name"] ?? "";
          eventImage = data["image"] ?? "";
          eventUserId = data["userId"] ?? "";
          eventUserName = data["userName"] ?? "";
          eventIsFollow = (data["isFollow"].toString().toLowerCase() == "true");
          eventIsHost = (data["isHost"].toString().toLowerCase() == "true");
          eventViews = int.parse(data["views"] ?? "1");
          eventVideoUrl = data["videoUrl"] ?? "";
          eventIsProfileImageBanned = (data["isProfileImageBanned"].toString().toLowerCase() == "true");

          if (BranchIoServices.eventType == "FakeLive") {
            print("Database.loginUserId == BranchIoServices.eventUserId ${BranchIoServices.eventType}");
            await 500.milliseconds.delay();
            if (Database.loginUserId != BranchIoServices.eventUserId) {
              Utils.showLog("Login user id is same-----------------");

              Get.toNamed(AppRoutes.fakeLivePage, arguments: {
                "roomId": BranchIoServices.eventRoomId,
                "isHost": BranchIoServices.eventIsHost,
                "userId": BranchIoServices.eventUserId,
                "image": BranchIoServices.eventImage,
                "name": BranchIoServices.eventName,
                "userName": BranchIoServices.eventUserName,
                "isFollow": BranchIoServices.eventIsFollow,
                "videoUrl": BranchIoServices.eventVideoUrl,
                "views": BranchIoServices.eventViews,
              });
            } else {
              Utils.showLog("Login user id is same");
            }
          }
          print('TYPE :: ${BranchIoServices.eventType}');
          if (BranchIoServices.eventType == "Live") {
            print("Database.loginUserId == BranchIoServices.eventUserId ${BranchIoServices.eventType}");
            await 500.milliseconds.delay();
            if (Database.loginUserId != BranchIoServices.eventUserId) {
              Utils.showLog("Login user id is same-----------------");

              Get.toNamed(AppRoutes.livePage, arguments: {
                "roomId": BranchIoServices.eventRoomId,
                "name": BranchIoServices.eventName,
                "image": BranchIoServices.eventImage,
                "userId": BranchIoServices.eventUserId,
                "userName": BranchIoServices.eventUserName,
                "isFollow": BranchIoServices.eventIsFollow,
                "isHost": BranchIoServices.eventIsHost,
                "isProfileImageBanned": BranchIoServices.eventIsProfileImageBanned,
              });
            } else {
              Utils.showLog("Login user id is same");
            }
          }
        }
      },
      onError: (error) {
        log('Branch Io Listen Error => ${error.toString()}');
      },
    );
    log("Stream Subscription => ${streamSubscription}");
  }

  static Future<void> onCreateBranchIoLink({
    required String pageRoutes,
    required String id,
    required String name,
    required String image,
    required String userId,
  }) async {
    branchContentMetaData = BranchContentMetaData()
      ..addCustomMetadata("pageRoutes", pageRoutes)
      ..addCustomMetadata("id", id)
      ..addCustomMetadata("name", name)
      ..addCustomMetadata("image", image)
      ..addCustomMetadata('userId', userId);

    String completeImageUrl = image.startsWith('http') ? image : Api.baseUrl + image;

    branchUniversalObject = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      // canonicalUrl: 'https://flutter.dev',
      title: name,
      imageUrl: Api.baseUrl + image,
      contentDescription: name,
      contentMetadata: branchContentMetaData,
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      expirationDateInMilliSec: DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
    );

    branchLinkProperties =
        BranchLinkProperties(channel: 'facebook', feature: 'sharing', stage: 'new share', campaign: 'campaign', tags: ['one', 'two', 'three'])
          ..addControlParam('\$uri_redirect_mode', '1')
          ..addControlParam('\$ios_nativelink', true)
          ..addControlParam('\$match_duration', 7200)
          ..addControlParam('\$always_deeplink', true)
          ..addControlParam('\$android_redirect_timeout', 750)
          ..addControlParam('referring_user_id', 'user_id');
  }

  static Future<void> onCreateFakeLiveBranchIoLink({
    required String roomId,
    required bool isHost,
    required String userId,
    required String image,
    required String name,
    required String userName,
    required int views,
    required bool isFollow,
    required String pageRoutes,
    required String videoUrl,
  }) async {
    branchContentMetaData = BranchContentMetaData()
      ..addCustomMetadata("roomId", roomId)
      ..addCustomMetadata("pageRoutes", pageRoutes)
      ..addCustomMetadata("name", name)
      ..addCustomMetadata("image", image)
      ..addCustomMetadata('userId', userId)
      ..addCustomMetadata("userName", userName)
      ..addCustomMetadata("isFollow", isFollow.toString())
      ..addCustomMetadata("isHost", isHost)
      ..addCustomMetadata("views", views)
      ..addCustomMetadata("videoUrl", videoUrl);

    branchUniversalObject = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      canonicalUrl: 'https://flutter.dev',
      title: name,
      imageUrl: image,
      contentDescription: name,
      contentMetadata: branchContentMetaData,
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      expirationDateInMilliSec: DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
    );

    branchLinkProperties =
        BranchLinkProperties(channel: 'facebook', feature: 'sharing', stage: 'new share', campaign: 'campaign', tags: ['one', 'two', 'three'])
          ..addControlParam('\$uri_redirect_mode', '1')
          ..addControlParam('\$ios_nativelink', true)
          ..addControlParam('\$match_duration', 7200)
          ..addControlParam('\$always_deeplink', true)
          ..addControlParam('\$android_redirect_timeout', 750)
          ..addControlParam('referring_user_id', 'user_id');
  }

  static Future<void> onCreateLiveBranchIoLink({
    required String roomId,
    required bool isHost,
    required String userId,
    required String image,
    required String name,
    required String userName,
    required bool isFollow,
    required String pageRoutes,
    required bool isProfileImageBanned,
  }) async {
    branchContentMetaData = BranchContentMetaData()
      ..addCustomMetadata("roomId", roomId)
      ..addCustomMetadata("pageRoutes", pageRoutes)
      ..addCustomMetadata("name", name)
      ..addCustomMetadata("image", image)
      ..addCustomMetadata('userId', userId)
      ..addCustomMetadata("userName", userName)
      ..addCustomMetadata("isFollow", isFollow.toString())
      ..addCustomMetadata("isHost", isHost)
      ..addCustomMetadata("isProfileImageBanned", isProfileImageBanned);

    branchUniversalObject = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      canonicalUrl: 'https://flutter.dev',
      title: name,
      imageUrl: image,
      contentDescription: name,
      contentMetadata: branchContentMetaData,
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      expirationDateInMilliSec: DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
    );

    branchLinkProperties =
        BranchLinkProperties(channel: 'facebook', feature: 'sharing', stage: 'new share', campaign: 'campaign', tags: ['one', 'two', 'three'])
          ..addControlParam('\$uri_redirect_mode', '1')
          ..addControlParam('\$ios_nativelink', true)
          ..addControlParam('\$match_duration', 7200)
          ..addControlParam('\$always_deeplink', true)
          ..addControlParam('\$android_redirect_timeout', 750)
          ..addControlParam('referring_user_id', 'user_id');
  }

  static Future<String?> onGenerateLink() async {
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: branchUniversalObject!, linkProperties: branchLinkProperties);
    if (response.success) {
      log("Generated Branch Io Link => ${response.result}");

      return response.result.toString();
    } else {
      log("Generating Branch Io Link Failed !! => ${response.errorCode} - ${response.errorMessage}");
      return null;
    }
  }
}
