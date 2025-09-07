import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Wow/utils/api.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/internet_connection.dart';
import 'package:Wow/utils/utils.dart';

class CheckUserExistApi {
  static Future<bool?> callApi({required String identity}) async {
    Utils.showLog("Check User Exist Api Calling...");

    final uri = Uri.parse("${Api.checkUserExit}?identity=$identity");

    final headers = {"key": Api.secretKey};

    try {
      if (InternetConnection.isConnect.value) {
        final response = await http.post(uri, headers: headers);

        if (response.statusCode == 200) {
          Utils.showLog("Check User Exist Api Response => ${response.body}");
          final jsonResponse = json.decode(response.body);
          return jsonResponse["isLogin"];
        } else {
          Utils.showLog(">>>>> Check User Exist Api StateCode Error <<<<<");
        }
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      }
    } catch (error) {
      Utils.showLog("Check User Exist Api Error => $error");
    }
    return null;
  }
}
