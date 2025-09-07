import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/custom/custom_fetch_user_coin.dart';
import 'package:Wow/pages/preview_shorts_video_page/model/preview_shorts_video_model.dart';
import 'package:Wow/pages/profile_page/api/delete_post_api.dart';
import 'package:Wow/pages/profile_page/api/delete_reels_api.dart';
import 'package:Wow/pages/profile_page/api/fetch_profile_api.dart';
import 'package:Wow/pages/profile_page/api/fetch_profile_collection_api.dart';
import 'package:Wow/pages/profile_page/api/fetch_profile_post_api.dart';
import 'package:Wow/pages/profile_page/api/fetch_profile_video_api.dart';
import 'package:Wow/pages/profile_page/model/delete_post_model.dart';
import 'package:Wow/pages/profile_page/model/delete_reels_model.dart';
import 'package:Wow/pages/profile_page/model/fetch_profile_collection_model.dart';
import 'package:Wow/pages/profile_page/model/fetch_profile_model.dart';
import 'package:Wow/pages/profile_page/model/fetch_profile_post_model.dart';
import 'package:Wow/pages/profile_page/model/fetch_profile_video_model.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/ui/delete_post_dialog_ui.dart';
import 'package:Wow/ui/delete_reels_dialog_ui.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/utils.dart';

class ProfileController extends GetxController with GetTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  TabController? tabController;

  RxBool isTabBarPinned = false.obs;

  // >>>>> Get Personal User Profile...
  FetchProfileModel? fetchProfileModel;
  bool isLoadingProfile = false;
  bool isFollow = false;

  // >>>>> Get Personal User Video...
  bool isLoadingVideo = true;
  FetchProfileVideoModel? fetchProfileVideoModel;
  List<ProfileVideoData> videoCollection = [];

  // >>>>> Get Personal User Post...
  bool isLoadingPost = true;
  FetchProfilePostModel? fetchProfilePostModel;
  List<ProfilePostData> postCollection = [];

  // >>>>> Get Personal User Collection(Gift)...
  bool isLoadingCollection = true;
  FetchProfileCollectionModel? fetchProfileCollectionModel;
  List<ProfileCollectionData> giftCollection = [];

  DeletePostModel? deletePostModel;
  DeleteReelsModel? deleteReelsModel;

  @override
  void onClose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    tabController = TabController(length: 3, vsync: this);
    tabController?.addListener(onChangeTabBar);
    scrollController.addListener(onScroll);

    super.onInit();
  }

  Future<void> init() async {
    tabController?.index = 0;

    isLoadingVideo = true;
    isLoadingPost = true;
    isLoadingCollection = true;

    onGetProfile(userId: Database.loginUserId);
    onGetVideo(userId: Database.loginUserId);
    CustomFetchUserCoin.init();
  }

  void onScroll() {
    isTabBarPinned.value = scrollController.offset > 75;
  }

  bool isChangingTab = false; // This is use to fixing two time api calling...

  Future<void> onChangeTabBar() async {
    isChangingTab = true;

    await 400.milliseconds.delay();

    if (isChangingTab) {
      isChangingTab = false;

      if (tabController?.index == 0) {
        Utils.showLog("Tab Change To Reels => ${tabController?.index}");
        if (isLoadingVideo) {
          onGetVideo(userId: Database.loginUserId);
        }
      } else if (tabController?.index == 1) {
        Utils.showLog("Tab Change To Feeds => ${tabController?.index}");

        if (isLoadingPost) {
          onGetPost(userId: Database.loginUserId);
        }
      } else if (tabController?.index == 2) {
        Utils.showLog("Tab Change To Collections => ${tabController?.index}");

        if (isLoadingCollection) {
          onGetCollection(userId: Database.loginUserId);
        }
      }
    }
  }

  Future<void> onGetProfile({required String userId}) async {
    isLoadingProfile = true;
    update(["onGetProfile"]);
    fetchProfileModel = await FetchProfileApi.callApi(loginUserId: Database.loginUserId, otherUserId: userId);
    if (fetchProfileModel?.userProfileData?.user?.name != null) {
      isLoadingProfile = false;
      update(["onGetProfile"]);
    }
  }

  Future<void> onGetVideo({required String userId}) async {
    isLoadingVideo = true;
    videoCollection.clear();
    update(["onGetVideo"]);
    fetchProfileVideoModel = await FetchProfileVideoApi.callApi(loginUserId: Database.loginUserId, toUserId: userId);
    if (fetchProfileVideoModel?.data != null) {
      Utils.showLog("Profile Reels Length => ${fetchProfileVideoModel?.data?.length}");
      videoCollection.clear();
      videoCollection.addAll(fetchProfileVideoModel?.data ?? []);
    }
    isLoadingVideo = false;
    update(["onGetVideo"]);
  }

  Future<void> onGetPost({required String userId}) async {
    isLoadingPost = true;
    postCollection.clear();
    update(["onGetPost"]);
    fetchProfilePostModel = await FetchProfilePostApi.callApi(userId: userId);
    if (fetchProfilePostModel?.data != null) {
      Utils.showLog("Profile Post Length => ${fetchProfilePostModel?.data?.length}");
      postCollection.clear();
      postCollection.addAll(fetchProfilePostModel?.data ?? []);
    }
    isLoadingPost = false;
    update(["onGetPost"]);
  }

  Future<void> onGetCollection({required String userId}) async {
    isLoadingCollection = true;
    giftCollection.clear();
    update(["onGetCollection"]);
    fetchProfileCollectionModel = await FetchProfileCollectionApi.callApi(userId: userId);
    if (fetchProfileCollectionModel?.data != null) {
      Utils.showLog("Profile Gift Length => ${fetchProfileCollectionModel?.data?.length}");
      giftCollection.clear();
      giftCollection.addAll(fetchProfileCollectionModel?.data ?? []);
    }
    isLoadingCollection = false;
    update(["onGetCollection"]);
  }

  Future<void> onClickEditProfile() async {
    Get.toNamed(AppRoutes.editProfilePage)?.then(
      (value) => onGetProfile(userId: Database.loginUserId),
    );
  }

  Future<void> onClickFollowing() async {
    Get.toNamed(
      AppRoutes.connectionPage,
      arguments: {
        "userId": Database.loginUserId,
        "name": fetchProfileModel?.userProfileData?.user?.name ?? "",
        "userName": fetchProfileModel?.userProfileData?.user?.userName ?? "",
        "image": fetchProfileModel?.userProfileData?.user?.image ?? "",
        "isProfileImageBanned": fetchProfileModel?.userProfileData?.user?.isProfileImageBanned ?? "",
        "type": 0, // Arguments Type => Following..
      },
    );
  }

  Future<void> onClickFollowers() async {
    Get.toNamed(
      AppRoutes.connectionPage,
      arguments: {
        "userId": Database.loginUserId,
        "name": fetchProfileModel?.userProfileData?.user?.name ?? "",
        "userName": fetchProfileModel?.userProfileData?.user?.userName ?? "",
        "image": fetchProfileModel?.userProfileData?.user?.image ?? "",
        "isProfileImageBanned": fetchProfileModel?.userProfileData?.user?.isProfileImageBanned ?? "",
        "type": 1, // Arguments Type => Followers
      },
    );
  }

  Future<void> onClickReels(int index) async {
    List<PreviewShortsVideoModel> mainShorts = [];
    for (int index = 0; index < videoCollection.length; index++) {
      final video = videoCollection[index];
      mainShorts.add(
        PreviewShortsVideoModel(
          name: video.name.toString(),
          userId: video.userId.toString(),
          userName: video.userName.toString(),
          userImage: video.userImage.toString(),
          videoId: video.id.toString(),
          videoUrl: video.videoUrl.toString(),
          videoImage: video.videoImage.toString(),
          caption: video.caption.toString(),
          hashTag: video.hashTag ?? [],
          isLike: video.isLike ?? false,
          likes: video.totalLikes ?? 0,
          comments: video.totalComments ?? 0,
          isBanned: video.isBanned ?? false,
          songId: video.songId ?? "",
          isProfileImageBanned: video.isProfileImageBanned ?? false,
        ),
      );
    }
    Get.toNamed(AppRoutes.previewShortsVideoPage, arguments: {"index": index, "video": mainShorts, "previousPageIsAudioWiseVideoPage": false});
  }

  void onClickDeleteReels({required String videoId}) {
    DeleteReelsDialogUi.onShow(callBack: () => onDeleteReels(videoId: videoId));
  }

  Future<void> onDeleteReels({required String videoId}) async {
    try {
      Get.dialog(LoadingUi(), barrierDismissible: false); // Start Loading...
      deleteReelsModel = await DeleteReelsApi.callApi(videoId: videoId);
      Get.close(3); // Stop Loading...
      Utils.showToast(deleteReelsModel?.message ?? "");
      init();
    } catch (e) {
      Get.close(2); // Stop Loading...
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
    }
  }

  void onClickDeletePost({required String postId}) {
    DeletePostDialogUi.onShow(callBack: () => onDeletePost(postId: postId));
  }

  Future<void> onDeletePost({required String postId}) async {
    try {
      Get.dialog(LoadingUi(), barrierDismissible: false); // Start Loading...
      deletePostModel = await DeletePostApi.callApi(postId: postId);
      Get.close(3); // Stop Loading...
      Utils.showToast(deletePostModel?.message ?? "");
      init();
    } catch (e) {
      Get.close(2); // Stop Loading...
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
    }
  }
}
