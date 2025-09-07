import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/main.dart';
import 'package:Wow/utils/asset.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/font_style.dart';

class NoDataFoundUi extends StatelessWidget {
  const NoDataFoundUi({
    super.key,
    required this.iconSize,
    required this.fontSize,
  });

  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAsset.icNoDataFound, width: iconSize),
          15.height,
          Text(
            EnumLocal.txtNoDataFound.name.tr,
            style: AppFontStyle.styleW500(AppColor.colorGreyHasTagText, fontSize),
          ),
        ],
      ),
    );
  }
}
