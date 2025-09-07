import 'package:Wow/custom/custom_video_picker.dart';
import 'package:Wow/custom/custom_video_time.dart';
import 'package:Wow/main.dart';
import 'package:Wow/routes/app_routes.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/ui/video_picker_bottom_sheet_ui.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';
import 'package:Wow/utils/internet_connection.dart';
import 'package:Wow/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:Wow/pages/bottom_bar_page/widget/bottom_bar_widget.dart';

class BottomBarView extends StatelessWidget {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BottomBarController>(
        id: "onChangeBottomBar",
        builder: (logic) {
          return PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logic.bottomBarPages.length,
            controller: logic.pageController,
            onPageChanged: (int index) => logic.onChangeBottomBar(index,context: context),
            itemBuilder: (context, index) {
                return logic.bottomBarPages[logic.selectedTabIndex];
            },
          );
        },
      ),
      bottomNavigationBar: const BottomBarUi(),
    );
  }
}
