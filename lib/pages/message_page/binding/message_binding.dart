import 'package:get/get.dart';
import 'package:Wow/pages/message_page/controller/message_controller.dart';

class MessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageController>(() => MessageController(), fenix: true);
  }
}
