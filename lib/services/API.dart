import 'dart:convert';
import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/models/Class.dart';
import 'package:http/http.dart' as http;

class API {
  Future<List<Class>> getClassForTeacher(String teacherID) async {
    final url = 'http://localhost:8080/api/teacher/getClasses';
    var request = {'teacherID': teacherID};
    var body = json.encode(request);
    var headers = {
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    try {
      if (response.statusCode == 200) {
        print('Respone.body ${response.body}');
        print('JsonDecode:${jsonDecode(response.body)}');
        List classTeacherList = jsonDecode(response.body);
        List<Class> data = [];
        for (var temp in classTeacherList) {
          if (temp is Map<String, dynamic>) {
            try {
              data.add(Class.fromJson(temp));
            } catch (e) {
              print('Error parsing data: $e');
            }
          } else {
            print('Invalid data type: $temp');
          }
        }
        print('Data ${data}');
        return data;
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<String?> uploadExcelTeacher(Uint8List excelBytes) async {
    var uri = Uri.parse('http://localhost:8080/api/admin/submit/teachers');

    try {
      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );

      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        return 'OK';
      } else {
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<String?> uploadExcelStudent(Uint8List excelBytes) async {
    var uri = Uri.parse('http://localhost:8080/api/admin/submit/students');

    try {
      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );

      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        return 'OK';
      } else {
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<String?> uploadExcelCourse(Uint8List excelBytes) async {
    var uri = Uri.parse('http://localhost:8080/api/admin/submit/course');

    try {
      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );

      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        return 'OK';
      } else {
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<String?> uploadExcelClasses(
      Uint8List excelBytes,
      String courseID,
      String teacherID,
      String roomNumber,
      String shiftNumber,
      String startTime,
      String endTime,
      String classType,
      String group,
      String subGroup) async {
    var uri = Uri.parse('http://localhost:8080/api/admin/submit/classes');

    try {
      print(excelBytes.runtimeType);
      print('CourseID:${courseID.runtimeType}');
      print('TeacherID:${teacherID.runtimeType}');
      print('RoomNumber: ${roomNumber.runtimeType}');
      print('Shift:${shiftNumber.runtimeType}');
      print('StartTime:${startTime.runtimeType}');
      print('EndTime:${endTime.runtimeType}');
      print('Type:${classType.runtimeType}');
      print('Group:${group.runtimeType}');
      print('SubGroup:${subGroup.runtimeType}');


      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );
      request.fields['courseID'] = courseID.toString();
      request.fields['teacherID'] = teacherID.toString();
      request.fields['roomNumber'] = roomNumber.toString();
      request.fields['shiftNumber'] = shiftNumber.toString();
      request.fields['startTime'] = startTime.toString();
      request.fields['endTime'] = endTime.toString();
      request.fields['classType'] = classType.toString();
      request.fields['group'] = group.toString();
      request.fields['subGroup'] = subGroup.toString();
      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        return 'OK';
      } else {
        dynamic data = jsonEncode(await response.stream.bytesToString());
        String message = data['message'];
        print('failedasdasda $message');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}
