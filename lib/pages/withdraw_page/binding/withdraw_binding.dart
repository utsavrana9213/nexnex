import 'package:get/get.dart';
import 'package:Wow/pages/withdraw_page/controller/withdraw_controller.dart';

class WithdrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawController>(() => WithdrawController());
  }
}
