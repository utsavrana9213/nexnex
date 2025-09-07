import 'package:get/get.dart';
import 'package:Wow/pages/live_page/controller/live_controller.dart';

class LiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveController>(() => LiveController());
  }
}
