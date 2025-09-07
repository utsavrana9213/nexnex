import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/terms_of_use_page/controller/terms_of_use_controller.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/ui/simple_app_bar_ui.dart';
import 'package:Wow/utils/color.dart';
import 'package:Wow/utils/enums.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsOfUseView extends StatelessWidget {
  const TermsOfUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.white,
          shadowColor: AppColor.black.withOpacity(0.4),
          flexibleSpace: SimpleAppBarUi(title: EnumLocal.txtTermsOfUse.name.tr),
        ),
      ),
      body: GetBuilder<TermsOfUseController>(
        id: "onInitializeWebView",
        builder: (controller) => controller.webViewController != null
            ? WebViewWidget(controller: controller.webViewController!)
            : const LoadingUi(),
      ),
    );
  }
}
