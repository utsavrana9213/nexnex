import 'package:get/get.dart';
import 'package:Wow/pages/preview_created_reels_page/controller/preview_created_reels_controller.dart';

class PreviewCreatedReelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreviewCreatedReelsController>(() => PreviewCreatedReelsController());
  }
}
