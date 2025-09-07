import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:Wow/pages/splash_screen_page/model/admin_setting_model.dart';
import 'package:Wow/utils/api.dart';
import 'package:Wow/utils/utils.dart';

class AdminSettingsApi {
  static AdminSettingModel? adminSettingModel;
  static Future<void> callApi() async {
    Utils.showLog("Get Admin Settings Api Calling...");

    final uri = Uri.parse(Api.adminSetting);

    Utils.showLog("Get Admin Settings Api Url => $uri");

    final headers = {"key": Api.secretKey};
    print("keyyyyyyyyyyyyyyyyyyyyyyyyyy:::::::::::::::::::::::::::::::::::::::::::: ${Api.secretKey}");

    try {
      final response = await http.get(uri, headers: headers);
      print("responseeeeeeeeeeeeeeee: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Get Admin Settings Api Response => ${response.body}");

        adminSettingModel = AdminSettingModel.fromJson(jsonResponse);
      } else {
        print("eeeeeeeeeeeerrrrrrrrrrrrr: ${response.body}");
        Utils.showLog("Get Admin Settings Api StateCode Error");
      }
    } catch (error) {
      print("errrrrrrrrrrrrrrrrr: ${error}");
      Utils.showLog("Get Admin Settings Api Error => $error");
    }
  }
}
