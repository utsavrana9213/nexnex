import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Wow/custom/custom_image_picker.dart';
import 'package:Wow/custom/custom_multi_image_picker.dart';
import 'package:Wow/pages/feed_page/api/fetch_post_api.dart';
import 'package:Wow/pages/feed_page/model/fetch_post_model.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/ui/image_picker_bottom_sheet_ui.dart';
import 'package:Wow/utils/branch_io_services.dart';
import 'package:Wow/utils/database.dart';

class FeedController extends GetxController {
  ScrollController scrollController = ScrollController();

  FetchPostModel? fetchPostModel;
  List<Post> mainPost = [];
  bool isLoadingPost = false;
  bool isPaginationLoading = false;

  @override
  void onInit() {
    scrollController.addListener(onPagination);
    super.onInit();
  }

  Future<void> init() async {
    isLoadingPost = true;
    mainPost.clear();
    update(["onGetPost"]);
    FetchPostApi.startPagination = 0;
    await onGetPost();
    isLoadingPost = false;
  }

  void onPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && isPaginationLoading == false) {
      isPaginationLoading = true;
      update(["onPagination"]);
      await onGetPost();
      isPaginationLoading = false;
      update(["onPagination"]);
    }
  }

  Future<void> onGetPost() async {
    fetchPostModel = null;
    var res = await FetchPostApi.callApi(loginUserId: Database.loginUserId, postId: BranchIoServices.eventId);
         print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
         fetchPostModel = FetchPostModel.fromJson(res);
    if (fetchPostModel?.post != null) {
      if (fetchPostModel!.post!.isNotEmpty) {
        final paginationData = fetchPostModel?.post ?? [];

        mainPost.addAll(paginationData);

        update(["onGetPost"]);
      } else {
        FetchPostApi.startPagination--;
      }
    }
    if (mainPost.isEmpty) {
      update(["onGetPost"]);
    }
    update();
    isLoadingPost=false;
  }

  Future<void> onPickPost(BuildContext context) async {
    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickGallery: () async {
        Get.back();
        final List<String> images = await CustomMultiImagePicker.pickImage();

        if (images.isNotEmpty) {
          Get.toNamed(AppRoutes.uploadPostPage, arguments: {"images": images, "isEdit": false});
        }
      },
      onClickCamera: () async {
        Get.back();
        final String? imagePath = await CustomImagePicker.pickImage(ImageSource.camera);
        if (imagePath != null) {
          List<String> images = [];
          images.add(imagePath);
          Get.toNamed(AppRoutes.uploadPostPage, arguments: {"images": images, "isEdit": false});
        }
      },
    );
  }
}
