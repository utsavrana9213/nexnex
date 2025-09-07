import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:Wow/pages/preview_hash_tag_page/model/create_hash_tag_model.dart';
import 'package:Wow/utils/api.dart';
import 'package:Wow/utils/enums.dart';
import 'package:Wow/utils/internet_connection.dart';
import 'package:Wow/utils/utils.dart';

class CreateHashTagApi {
  static Future<CreateHashTagModel?> callApi({required String hashTag}) async {
    Utils.showLog("Create HashTag Api Calling...");

    final uri = Uri.parse(Api.createHashTag);

    final headers = {"key": Api.secretKey, "Content-Type": "application/json"};

    final body = json.encode({"hashTag": hashTag});

    try {
      if (InternetConnection.isConnect.value) {
        final response = await http.post(uri, headers: headers, body: body);

        if (response.statusCode == 200) {
          Utils.showLog("Create HashTag Api Response => ${response.body}");
          final jsonResponse = json.decode(response.body);
          return CreateHashTagModel.fromJson(jsonResponse);
        } else {
          Utils.showLog("Create HashTag Api State Code Error => ${response.statusCode}");
        }
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      }
    } catch (error) {
      Utils.showLog("Create HashTag Api Error => $error");
    }
    return null;
  }
}
