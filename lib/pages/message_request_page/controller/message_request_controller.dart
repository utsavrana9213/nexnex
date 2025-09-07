import 'package:get/get.dart';
import 'package:Wow/pages/message_request_page/api/delete_all_message_request_api.dart';
import 'package:Wow/pages/message_request_page/api/fetch_message_request_api.dart';
import 'package:Wow/pages/message_request_page/model/delete_all_message_request_model.dart';
import 'package:Wow/pages/message_request_page/model/fetch_message_request_model.dart';
import 'package:Wow/ui/loading_ui.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/utils.dart';

class MessageRequestController extends GetxController {
  FetchMessageRequestModel? fetchMessageRequestModel;

  List<Data> messageRequest = [];
  bool isLoading = false;

  DeleteAllMessageRequestModel? deleteAllMessageRequestModel;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    onGetMessageRequest();
  }

  Future<void> onGetMessageRequest() async {
    fetchMessageRequestModel = null;
    isLoading = true;
    update(["onGetMessageRequest"]);
    fetchMessageRequestModel = await FetchMessageRequestApi.callApi(loginUserId: Database.loginUserId);

    if (fetchMessageRequestModel?.data != null) {
      messageRequest.clear();
      messageRequest.addAll(fetchMessageRequestModel?.data ?? []);
      isLoading = false;
      update(["onGetMessageRequest"]);
    }
  }

  Future<void> onDeleteAllRequest() async {
    deleteAllMessageRequestModel = null;

    Get.dialog(LoadingUi(), barrierDismissible: false); // Start Loading...
    deleteAllMessageRequestModel = await DeleteAllMessageRequestApi.callApi(loginUserId: Database.loginUserId);
    Get.back(); // Stop Loading...
    if (deleteAllMessageRequestModel?.status == true) {
      Utils.showToast(deleteAllMessageRequestModel?.message ?? "");
      Get.back();
    } else {
      Utils.showToast(deleteAllMessageRequestModel?.message ?? "");
    }
  }
}
