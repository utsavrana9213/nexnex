import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Wow/pages/edit_profile_page/model/edit_profile_model.dart';
import 'package:Wow/utils/api.dart';
import 'package:Wow/utils/utils.dart';

class EditProfileApi {
  static Future<EditProfileModel?> callApi({
    required String loginUserId,
    String? image,
    required String name,
    required String userName,
    required String country,
    required String bio,
    required String gender,
    required String countryFlagImage,
  }) async {
    Utils.showLog("Edit Profile Api Calling...");

    try {
      var headers = {'key': Api.secretKey};

      var request = http.MultipartRequest('PATCH', Uri.parse("${Api.editProfile}?userId=$loginUserId"));
      request.fields.addAll({
        'name': name,
        'userName': '@$userName',
        'gender': gender,
        'bio': bio,
        'country': country,
        'countryFlagImage': countryFlagImage,
      });

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image));
      }

      request.headers.addAll(headers);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResult = jsonDecode(responseBody);
        Utils.showLog("Edit Profile Api Response => ${jsonResult}");
        return EditProfileModel.fromJson(jsonResult);
      } else {
        Utils.showLog("Edit Profile Api Response Error");
        return null;
      }
    } catch (e) {
      Utils.showLog("Edit Profile Api Error => $e");
      return null;
    }
  }
}
