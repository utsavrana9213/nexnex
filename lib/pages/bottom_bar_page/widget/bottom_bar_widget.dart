import 'package:Wow/ui/video_picker_bottom_sheet_ui.dart';
import 'package:curved_labeled_gradient_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:Wow/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/constant.dart';
import 'package:curved_labeled_gradient_navigation_bar/curved_navigation_bar.dart';
import 'dart:math' as math;

class BottomBarUi extends StatelessWidget {
  const BottomBarUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomBarController>(
      id: "onChangeBottomBar",
      builder: (logic) {
        return SizedBox(
          height: AppConstant.bottomBarSize.toDouble(),
          width: Get.width,
          child: CurvedNavigationBar(
            index: logic.selectedTabIndex,
            height: 65,
            backgroundColor: Colors.transparent,
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF200648), Color(0xFF200648)],
              transform: GradientRotation(85.84 * math.pi / 180),
            ),
            buttonGradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF200648), Color(0xFF200648)],
              transform: GradientRotation(85.84 * math.pi / 180),
            ),
            items: [
              CurvedNavigationBarItem(
                child: Image.asset("assets/icons/ic_watch.png",scale: 80,),
                label: 'Watch',
                labelStyle: TextStyle(
                  color: Colors.white

                )
              ),
              CurvedNavigationBarItem(
                child: Image.asset("assets/icons/ic_livestream.png",scale: 16,),
                label: 'Live',
                  labelStyle: TextStyle(
                      color: Colors.white
                  )
              ),
              CurvedNavigationBarItem(
                child:Image.asset("assets/icons/ic_chat.png",scale: 16,),
                label: 'Chat',
                  labelStyle: TextStyle(
                      color: Colors.white
                  )
              ),
              CurvedNavigationBarItem(
                child: Image.asset("assets/icons/ic_profile.png",scale: 80,),
                label: 'Profile',
                  labelStyle: TextStyle(
                      color: Colors.white
                  )
              ),
            /*  CurvedNavigationBarItem(
                child: Image.asset(
                  logic.selectedTabIndex == 4
                      ? AppAsset.icFeedsSelected
                      : AppAsset.icFeeds,
                  height: 28,
                  color:logic.selectedTabIndex == 4
                      ?AppColor.white: Colors.grey,
                ),
                label: 'Feeds',
                  labelStyle: TextStyle(
                      color: Colors.white
                  )
              ),*/
              CurvedNavigationBarItem(
                  child:  Image.asset("assets/icons/ic_video2.png",scale: 16,),
                  label: 'CREATE',
                  labelStyle: TextStyle(
                      color: Colors.white
                  )
              ),
         /*     CustomIconButton(
                circleSize: 40,
                iconSize: 25,
                icon: AppAsset.icCreate,
                callback: () {
                  isReelsPage.value = false;
                  VideoPickerBottomSheetUi.show(context: context);
                },
              ),
*/
            ],
            onTap: (index) {
              if (index == 4) {
                VideoPickerBottomSheetUi.show(context: context);
              } else {
                logic.onChangeBottomBar(index);
              }
            },
          )
         /* Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _BottomBarIconUi(
                icon: logic.selectedTabIndex == 0 ? AppAsset.icReelsSelected : AppAsset.icReels,
                callback: () => logic.onChangeBottomBar(0),
              ),
              _BottomBarIconUi(
                icon: logic.selectedTabIndex == 1 ? AppAsset.icStreamingSelected : AppAsset.icStreaming,
                callback: () => logic.onChangeBottomBar(1),
              ),
              _BottomBarIconUi(
                icon: logic.selectedTabIndex == 2 ? AppAsset.icFeedsSelected : AppAsset.icFeeds,
                callback: () => logic.onChangeBottomBar(2),
              ),
              _BottomBarIconUi(
                icon: logic.selectedTabIndex == 3 ? AppAsset.icMessageSelected : AppAsset.icMessage,
                callback: () => logic.onChangeBottomBar(3),
              ),
              _BottomBarIconUi(
                icon: logic.selectedTabIndex == 4 ? AppAsset.icProfileSelected : AppAsset.icProfile,
                callback: () => logic.onChangeBottomBar(4),
              ),
            ],
          ),*/
        );
      },
    );
  }
}
