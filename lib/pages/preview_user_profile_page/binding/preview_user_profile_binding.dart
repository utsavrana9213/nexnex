import 'package:get/get.dart';
import 'package:Wow/pages/preview_user_profile_page/controller/preview_user_profile_controller.dart';

class PreviewUserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreviewUserProfileController>(() => PreviewUserProfileController());
  }
}
