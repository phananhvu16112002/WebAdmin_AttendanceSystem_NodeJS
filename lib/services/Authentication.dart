import 'dart:convert';
import 'package:admin_attendancesystem_nodejs/services/SecureStorage.dart';
import 'package:admin_attendancesystem_nodejs/utils/constants.dart';
import 'package:http/http.dart' as http;

class Authentication{
  String baseURl = Constants.baseUrl;
  Future<String> login(String email, String password) async {
    var URL = 'http://$baseURl:8080/api/admin/login';
    var request = {'email': email, 'password': password};
    var body = json.encode(request);
    var headers = {
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    final response =
        await http.post(Uri.parse(URL), headers: headers, body: body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      var accessToken = responseData['accessToken'];
      var refreshToken = responseData['refreshToken'];
      // var teacherID = responseData['teacherID'];
      // var teacherEmail = responseData['teacherEmail'];
      // var teacherName = responseData['teacherName'];

      // print('--Response Data: $responseData');

      await SecureStorage().writeSecureData('accessToken', accessToken);
      await SecureStorage().writeSecureData('refreshToken', refreshToken);
      // await SecureStorage().writeSecureData('teacherID', teacherID);
      // await SecureStorage().writeSecureData('teacherEmail', teacherEmail);
      // await SecureStorage().writeSecureData('teacherName', teacherName);
      return '';
    } else {
      // ignore: avoid_print
      final Map<String, dynamic> responseData1 = jsonDecode(response.body);
      // print('Message: ${responseData1['message']}');
      return responseData1['message'];
    }
  }
}