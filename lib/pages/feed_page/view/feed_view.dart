import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:Wow/pages/feed_page/controller/feed_controller.dart';
import 'package:Wow/pages/feed_page/widget/feed_widget.dart';
import 'package:Wow/shimmer/feed_shimmer_ui.dart';
import 'package:Wow/ui/no_data_found_ui.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/constant.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.init();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.transparent,
        flexibleSpace: const FeedAppBarView(),
      ),
      body: RefreshIndicator(
        color: AppColor.primary,
        onRefresh: () async => controller.init(),
        child: SingleChildScrollView(
          child: SizedBox(
            // This Is Use To Active Refresh Indicator (25 - Extra Space)
            height: Get.height + 1 - AppConstant.bottomBarSize - 25,
            child: GetBuilder<FeedController>(
              id: "onGetPost",
              builder: (controller) => controller.isLoadingPost
                  ? FeedShimmerUi()
                  : controller.mainPost.isEmpty
                      ? const NoDataFoundUi(iconSize: 160, fontSize: 19)
                      : RefreshIndicator(
                          color: AppColor.primary,
                          onRefresh: () async => await controller.init(),
                          child: SingleChildScrollView(
                            controller: controller.scrollController,
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.mainPost.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final post = controller.mainPost[index];
                                    return


                                            PostView(
                                                id: post.id ?? "",
                                                userId: post.userId ?? "",
                                                profileImage: post.userImage ?? "",
                                                postImages: post.postImage ?? [],
                                                title: post.name ?? "",
                                                subTitle: post.userName ?? "",
                                                isLike: post.isLike ?? false,
                                                isFollow: post.isFollow ?? false,
                                                isVerified: post.isVerified ?? false,
                                                description: post.caption ?? "",
                                                hastTag: post.hashTag ?? [],
                                                time: post.time ?? "",
                                                likes: post.totalLikes ?? 0,
                                                comments: post.totalComments ?? 0,
                                                isFakeUser: post.isFake ?? false,
                                                isProfileImageBanned: post.isProfileImageBanned ?? false,
                                              );
                                  },
                                ),
                                SizedBox(height: AppConstant.bottomBarSize.toDouble()), // Use For Last Element Proper Show...
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GetBuilder<FeedController>(
        id: "onPagination",
        builder: (controller) => Visibility(
          visible: controller.isPaginationLoading,
          child: LinearProgressIndicator(color: AppColor.primary),
        ),
      ),
    );
  }
}
