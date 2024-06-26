import 'dart:convert';
import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/models/Chart/progress_model.dart';
import 'package:admin_attendancesystem_nodejs/models/Class.dart';
import 'package:admin_attendancesystem_nodejs/models/CoursePage/CourseModel.dart';
import 'package:admin_attendancesystem_nodejs/models/DetailPage/StudentDetail.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/ClassModel.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/class_data_model.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/total_model.dart';
import 'package:admin_attendancesystem_nodejs/models/LecturerPage/Teacher.dart';
import 'package:admin_attendancesystem_nodejs/models/StudentPage/Student.dart';
import 'package:admin_attendancesystem_nodejs/models/StudentPage/add_student_response.dart';
import 'package:admin_attendancesystem_nodejs/models/StudentPage/upload_student_response.dart';
import 'package:admin_attendancesystem_nodejs/models/Teacher.dart';
import 'package:admin_attendancesystem_nodejs/screens/Authentication/WelcomePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CoursePage.dart';
import 'package:admin_attendancesystem_nodejs/services/SecureStorage.dart';
import 'package:admin_attendancesystem_nodejs/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class API {
  String baseURl = Constants.baseUrl;
  BuildContext context;
  API(this.context);

  Future<String> getAccessToken() async {
    SecureStorage secureStorage = SecureStorage();
    var accessToken = await secureStorage.readSecureData('accessToken');
    // print('alo alo accesss');
    return accessToken;
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    var url = 'http://$baseURl:8080/api/token/refreshAccessToken'; // 10.0.2.2
    var headers = {'authorization': refreshToken};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Create New AccessToken is successfully');
        var newAccessToken = jsonDecode(response.body)['accessToken'];
        return newAccessToken;
      } else if (response.statusCode == 401) {
        print('Refresh Token is expired'); // Navigation to welcomePage

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                // Navigate to WelcomePage when dialog is dismissed
                await SecureStorage().deleteSecureData('refreshToken');
                await SecureStorage().deleteSecureData('accessToken');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomePage(),
                  ),
                );
                return true; // Return true to allow pop
              },
              child: AlertDialog(
                backgroundColor: Colors.white,
                elevation: 0.5,
                title: const Text('Unauthorized'),
                content: const Text(
                    'Your session has expired. Please log in again.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await SecureStorage().deleteSecureData('refreshToken');
                      await SecureStorage().deleteSecureData('accessToken');
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomePage(),
                        ),
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );

        return '';
      } else if (response.statusCode == 498) {
        print('Refresh Token is invalid');
        return '';
      } else {
        print(
            'Failed to refresh accessToken. Status code: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error234: $e');
      return '';
    }
  }

  Future<List<TeacherPage>?> uploadExcelTeachers(Uint8List excelBytes) async {
    var uri = Uri.parse('http://$baseURl:8080/api/admin/submit/teachers');
    var accessToken = await getAccessToken();
    try {
      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );
      request.files.add(multipartFile);
      request.headers['Authorization'] = accessToken;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        List<TeacherPage>? data = [];
        if (responseBody.isNotEmpty) {
          var jsonResponse = jsonDecode(responseBody);
          if (jsonResponse.containsKey('data')) {
            List teacherList = jsonResponse['data'];
            for (var teacherData in teacherList) {
              print('teacherData: $teacherData');
              try {
                data.add(TeacherPage.fromJson(teacherData));
              } catch (e) {
                print('Error parsing teacherData : $e');
              }
            }
          } else {
            print('No teacherData  found in response');
          }
        } else {
          print('Response body is empty');
        }
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          var retryRequest = http.MultipartRequest("POST", uri);
          retryRequest.headers['Authorization'] = newAccessToken;
          var retryMultipartFile = http.MultipartFile.fromBytes(
            'file',
            excelBytes,
            filename: 'excel_file.xlsx',
          );
          retryRequest.files.add(retryMultipartFile);

          var retryResponse = await retryRequest.send();
          if (retryResponse.statusCode == 200) {
            var retryReponsebody = await retryResponse.stream.bytesToString();
            List<TeacherPage>? listTeacher = [];
            if (retryReponsebody.isNotEmpty) {
              var jsonRetryResponse = jsonDecode(retryReponsebody);
              if (jsonRetryResponse.containsKey('data')) {
                List listData = jsonRetryResponse['data'];
                for (var student in listData) {
                  try {
                    listTeacher.add(TeacherPage.fromJson(student));
                  } catch (e) {
                    print('Error parsing teacherData: $e');
                  }
                }
              } else {
                print('No teacherData found in response');
              }
            }
            return listTeacher;
          }
        } else {
          print('Access Token is empty');
        }
      } else {
        print('Non-200 response: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
    return null;
  }

  Future<List<Student>?> uploadExcelStudent(Uint8List excelBytes) async {
    var uri = Uri.parse('http://$baseURl:8080/api/admin/submit/students');
    var accessToken = await getAccessToken();
    try {
      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );
      request.files.add(multipartFile);
      request.headers['Authorization'] = accessToken;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        List<Student>? data = [];
        if (responseBody.isNotEmpty) {
          var jsonResponse = jsonDecode(responseBody);
          if (jsonResponse.containsKey('data')) {
            List studentList = jsonResponse['data'];
            for (var studentData in studentList) {
              try {
                data.add(Student.fromJson(studentData));
              } catch (e) {
                print('Error parsing student data: $e');
              }
            }
          } else {
            print('No student data found in response');
          }
        } else {
          print('Response body is empty');
        }
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          var retryRequest = http.MultipartRequest("POST", uri);
          retryRequest.headers['Authorization'] = newAccessToken;
          var retryMultipartFile = http.MultipartFile.fromBytes(
            'file',
            excelBytes,
            filename: 'excel_file.xlsx',
          );
          retryRequest.files.add(retryMultipartFile);

          var retryResponse = await retryRequest.send();
          print('retryResponse status: ${retryResponse.statusCode}');
          if (retryResponse.statusCode == 200) {
            var retryReponsebody = await retryResponse.stream.bytesToString();
            List<Student>? listStudent = [];
            if (retryReponsebody.isNotEmpty) {
              var jsonRetryResponse = jsonDecode(retryReponsebody);
              if (jsonRetryResponse.containsKey('data')) {
                List listData = jsonRetryResponse['data'];
                for (var student in listData) {
                  try {
                    listStudent.add(Student.fromJson(student));
                  } catch (e) {
                    print('Error parsing student data: $e');
                  }
                }
              } else {
                print('No student data found in response');
              }
            }
            return listStudent;
          }
        } else {
          print('Access Token is empty');
        }
      } else {
        print('Non-200 response: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
    return null;
  }

  Future<List<CourseModel>?> uploadExcelCourses(Uint8List excelBytes) async {
    var uri = Uri.parse('http://$baseURl:8080/api/admin/submit/courses');
    var accessToken = await getAccessToken();
    try {
      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );
      request.files.add(multipartFile);
      request.headers['Authorization'] = accessToken;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        List<CourseModel>? data = [];
        if (responseBody.isNotEmpty) {
          var jsonResponse = jsonDecode(responseBody);
          if (jsonResponse.containsKey('data')) {
            List courseList = jsonResponse['data'];
            for (var courseData in courseList) {
              try {
                data.add(CourseModel.fromJson(courseData));
              } catch (e) {
                print('Error parsing student data: $e');
              }
            }
          } else {
            print('No courses data found in response');
          }
        } else {
          print('Response body is empty');
        }
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          var retryRequest = http.MultipartRequest("POST", uri);
          retryRequest.headers['Authorization'] = newAccessToken;
          var retryMultipartFile = http.MultipartFile.fromBytes(
            'file',
            excelBytes,
            filename: 'excel_file.xlsx',
          );
          retryRequest.files.add(retryMultipartFile);

          var retryResponse = await retryRequest.send();
          if (retryResponse.statusCode == 200) {
            var retryReponsebody = await retryResponse.stream.bytesToString();
            List<CourseModel>? listCourses = [];
            if (retryReponsebody.isNotEmpty) {
              var jsonRetryResponse = jsonDecode(retryReponsebody);
              if (jsonRetryResponse.containsKey('data')) {
                List listData = jsonRetryResponse['data'];
                for (var course in listData) {
                  try {
                    listCourses.add(CourseModel.fromJson(course));
                  } catch (e) {
                    print('Error parsing student data: $e');
                  }
                }
              } else {
                print('No student data found in response');
              }
            }
            return listCourses;
          }
        } else {
          print('Access Token is empty');
        }
      } else {
        print('Non-200 response: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
    return null;
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
    var uri = Uri.parse('http://$baseURl:8080/api/admin/submit/classes');

    try {
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

      // Kiểm tra accessToken
      var accessToken = await getAccessToken();
      request.headers['Authorization'] = accessToken;

      var response = await request.send();
      if (response.statusCode == 200) {
        return 'OK';
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        // Nếu mã lỗi là 498 hoặc 401, thử lại với refreshToken
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          var retryRequest = http.MultipartRequest("POST", uri);
          retryRequest.headers['Authorization'] = newAccessToken;
          retryRequest.fields['courseID'] = courseID.toString();
          retryRequest.fields['teacherID'] = teacherID.toString();
          retryRequest.fields['roomNumber'] = roomNumber.toString();
          retryRequest.fields['shiftNumber'] = shiftNumber.toString();
          retryRequest.fields['startTime'] = startTime.toString();
          retryRequest.fields['endTime'] = endTime.toString();
          retryRequest.fields['classType'] = classType.toString();
          retryRequest.fields['group'] = group.toString();
          retryRequest.fields['subGroup'] = subGroup.toString();

          // Tạo một MultipartFile mới cho request thử lại
          var retryMultipartFile = http.MultipartFile.fromBytes(
            'file',
            excelBytes,
            filename: 'excel_file.xlsx',
          );
          retryRequest.files.add(retryMultipartFile);

          var retryResponse = await retryRequest.send();
          if (retryResponse.statusCode == 200) {
            return 'OK';
          } else {
            dynamic data =
                jsonDecode(await retryResponse.stream.bytesToString());
            String message = data['message'];
            print('Failed: $message');
            return null;
          }
        } else {
          print('Access Token is empty');
          return null;
        }
      } else {
        dynamic data = jsonDecode(await response.stream.bytesToString());
        String message = data['message'];
        print('Failed: $message');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<List<Student>> getStudents() async {
    var URL = 'http://$baseURl:8080/api/admin/students'; //10.0.2.2

    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        List<Student> data = [];

        if (responseData is List) {
          for (var temp in responseData) {
            if (temp is Map<String, dynamic>) {
              try {
                data.add(Student.fromJson(temp));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Invalid data type: $temp');
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          try {
            data.add(Student.fromJson(responseData));
          } catch (e) {
            print('Error parsing data: $e');
          }
        } else {
          print('Unexpected data type: $responseData');
        }
        // print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            List<Student> data = [];

            if (responseData is List) {
              for (var temp in responseData) {
                if (temp is Map<String, dynamic>) {
                  try {
                    data.add(Student.fromJson(temp));
                  } catch (e) {
                    print('Error parsing data: $e');
                  }
                } else {
                  print('Invalid data type: $temp');
                }
              }
            } else if (responseData is Map<String, dynamic>) {
              try {
                data.add(Student.fromJson(responseData));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Unexpected data type: $responseData');
            }

            // print('Data $data');
            return data;
          } else {
            return [];
          }
        } else {
          print('New Access Token is empty');
          return [];
        }
      } else {
        print(
            'Failed to load reports data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<TeacherPage>> getTeachers() async {
    var URL = 'http://$baseURl:8080/api/admin/teachers'; //10.0.2.2

    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        List<TeacherPage> data = [];

        if (responseData is List) {
          for (var temp in responseData) {
            if (temp is Map<String, dynamic>) {
              try {
                data.add(TeacherPage.fromJson(temp));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Invalid data type: $temp');
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          try {
            data.add(TeacherPage.fromJson(responseData));
          } catch (e) {
            print('Error parsing data: $e');
          }
        } else {
          print('Unexpected data type: $responseData');
        }
        // print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            List<TeacherPage> data = [];

            if (responseData is List) {
              for (var temp in responseData) {
                if (temp is Map<String, dynamic>) {
                  try {
                    data.add(TeacherPage.fromJson(temp));
                  } catch (e) {
                    print('Error parsing data: $e');
                  }
                } else {
                  print('Invalid data type: $temp');
                }
              }
            } else if (responseData is Map<String, dynamic>) {
              try {
                data.add(TeacherPage.fromJson(responseData));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Unexpected data type: $responseData');
            }

            // print('Data $data');
            return data;
          } else {
            return [];
          }
        } else {
          print('New Access Token is empty');
          return [];
        }
      } else {
        print(
            'Failed to load reports data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<CourseModel>> getCourses() async {
    var URL = 'http://$baseURl:8080/api/admin/courses'; //10.0.2.2

    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        List<CourseModel> data = [];

        if (responseData is List) {
          for (var temp in responseData) {
            if (temp is Map<String, dynamic>) {
              try {
                data.add(CourseModel.fromJson(temp));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Invalid data type: $temp');
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          try {
            data.add(CourseModel.fromJson(responseData));
          } catch (e) {
            print('Error parsing data: $e');
          }
        } else {
          print('Unexpected data type: $responseData');
        }
        print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            List<CourseModel> data = [];

            if (responseData is List) {
              for (var temp in responseData) {
                if (temp is Map<String, dynamic>) {
                  try {
                    data.add(CourseModel.fromJson(temp));
                  } catch (e) {
                    print('Error parsing data: $e');
                  }
                } else {
                  print('Invalid data type: $temp');
                }
              }
            } else if (responseData is Map<String, dynamic>) {
              try {
                data.add(CourseModel.fromJson(responseData));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Unexpected data type: $responseData');
            }

            // print('Data $data');
            return data;
          } else {
            return [];
          }
        } else {
          print('New Access Token is empty');
          return [];
        }
      } else {
        print(
            'Failed to load reports data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // Future<List<ClassModel>> getClasses(int page) async {
  //   var URL = 'http://$baseURl:8080/api/admin/classes/page/$page'; //10.0.2.2

  //   var accessToken = await getAccessToken();
  //   var headers = {'authorization': accessToken};
  //   try {
  //     final response = await http.get(Uri.parse(URL), headers: headers);
  //     if (response.statusCode == 200) {
  //       dynamic responseData = jsonDecode(response.body);
  //       List<ClassModel> data = [];

  //       if (responseData is List) {
  //         for (var temp in responseData) {
  //           if (temp is Map<String, dynamic>) {
  //             try {
  //               data.add(ClassModel.fromJson(temp));
  //             } catch (e) {
  //               print('Error parsing data: $e');
  //             }
  //           } else {
  //             print('Invalid data type: $temp');
  //           }
  //         }
  //       } else if (responseData is Map<String, dynamic>) {
  //         try {
  //           data.add(ClassModel.fromJson(responseData));
  //         } catch (e) {
  //           print('Error parsing data: $e');
  //         }
  //       } else {
  //         print('Unexpected data type: $responseData');
  //       }
  //       // print('Data $data');
  //       return data;
  //     } else if (response.statusCode == 498 || response.statusCode == 401) {
  //       var refreshToken = await SecureStorage().readSecureData('refreshToken');
  //       var newAccessToken = await refreshAccessToken(refreshToken);
  //       if (newAccessToken.isNotEmpty) {
  //         headers['authorization'] = newAccessToken;
  //         final retryResponse =
  //             await http.get(Uri.parse(URL), headers: headers);
  //         if (retryResponse.statusCode == 200) {
  //           dynamic responseData = jsonDecode(retryResponse.body);
  //           List<ClassModel> data = [];

  //           if (responseData is List) {
  //             for (var temp in responseData) {
  //               if (temp is Map<String, dynamic>) {
  //                 try {
  //                   data.add(ClassModel.fromJson(temp));
  //                 } catch (e) {
  //                   print('Error parsing data: $e');
  //                 }
  //               } else {
  //                 print('Invalid data type: $temp');
  //               }
  //             }
  //           } else if (responseData is Map<String, dynamic>) {
  //             try {
  //               data.add(ClassModel.fromJson(responseData));
  //             } catch (e) {
  //               print('Error parsing data: $e');
  //             }
  //           } else {
  //             print('Unexpected data type: $responseData');
  //           }

  //           // print('Data $data');
  //           return data;
  //         } else {
  //           return [];
  //         }
  //       } else {
  //         print('New Access Token is empty');
  //         return [];
  //       }
  //     } else {
  //       print(
  //           'Failed to load reports data. Status code: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     return [];
  //   }
  // }

  Future<ClassData?> getClasses(int page) async {
    var URL = 'http://$baseURl:8080/api/admin/classes/page/$page';
    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        ClassData data = ClassData.fromJson(responseData);
        print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            ClassData data = ClassData.fromJson(responseData);

            // print('Data $data');
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<TotalModel?> getTotalHomePage() async {
    var URL = 'http://$baseURl:8080/api/admin/home';
    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        TotalModel data = TotalModel.fromJson(responseData);
        print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            TotalModel data = TotalModel.fromJson(responseData);

            // print('Data $data');
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<TeacherPage?> createNewLecturer(
      String lecturerID, String lecturerName, String lecturerEmail) async {
    var url = 'http://$baseURl:8080/api/admin/submit/teacher';
    var accessToken = await getAccessToken();
    var request = {
      'teacherID': lecturerID,
      'teacherName': lecturerName,
      'teacherEmail': lecturerEmail,
    };
    var body = json.encode(request);
    var headers = {
      'authorization': accessToken,
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      print('body:$body');
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        TeacherPage data = TeacherPage.fromJson(responseData);
        print('Data1:$data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.post(Uri.parse(url), headers: headers, body: body);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            TeacherPage data = TeacherPage.fromJson(responseData);
            print('Data $data');
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool?> updateLecturer(
    String teacherID,
    String teacherName,
  ) async {
    final url = 'http://$baseURl:8080/api/admin/edit/teacher/$teacherID';
    var accessToken = await getAccessToken();
    var request = {
      'teacherName': teacherName,
    };
    var body = json.encode(request);
    var headers = {
      'authorization': accessToken,
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      final response =
          await http.put(Uri.parse(url), headers: headers, body: body);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        String message = responseData['message'];
        print('Message: $message');
        return true;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.put(Uri.parse(url), headers: headers, body: body);
          try {
            if (retryResponse.statusCode == 200) {
              dynamic responseData = jsonDecode(retryResponse.body);
              String message = responseData['message'];
              print('Message: $message');
              return true;
            } else {
              return false;
            }
          } catch (e) {
            print('err:$e');
          }
        } else {
          print('New Access Token is empty');
          return false;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
    return null;
  }

  Future<bool?> deleteLecturer(
    String teacherID,
  ) async {
    final url = 'http://$baseURl:8080/api/admin/teacher/$teacherID';
    var accessToken = await getAccessToken();
    var headers = {
      'authorization': accessToken,
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        String message = responseData['message'];
        print('Message: $message');
        return true;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.delete(Uri.parse(url), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            String message = responseData['message'];
            print('Message: $message');
            return true;
          } else {
            return false;
          }
        } else {
          print('New Access Token is empty');
          return false;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<Student?> createNewStudent(
      String studentID, String studentName, String studentEmail) async {
    var url = 'http://$baseURl:8080/api/admin/submit/student';
    var accessToken = await getAccessToken();
    var request = {
      'studentID': studentID,
      'studentName': studentName,
      'studentEmail': studentEmail,
    };
    var body = json.encode(request);
    var headers = {
      'authorization': accessToken,
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      print('body:$body');
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        Student data = Student.fromJson(responseData);
        print('Data1:$data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.post(Uri.parse(url), headers: headers, body: body);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            Student data = Student.fromJson(responseData);
            print('Data $data');
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool?> updateStudent(
    String studentID,
    String studentName,
  ) async {
    final url = 'http://$baseURl:8080/api/admin/edit/student/$studentID';
    var accessToken = await getAccessToken();
    var request = {
      'studentName': studentName,
    };
    var body = json.encode(request);
    var headers = {
      'authorization': accessToken,
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      final response =
          await http.put(Uri.parse(url), headers: headers, body: body);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        String message = responseData['message'];
        print('Message: $message');
        return true;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.put(Uri.parse(url), headers: headers, body: body);
          if (retryResponse.statusCode == 200) {
            dynamic responseData = jsonDecode(retryResponse.body);
            String message = responseData['message'];
            print('Message: $message');
            return true;
          } else {
            return false;
          }
        } else {
          print('New Access Token is empty');
          return false;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool?> deleteStudent(
    String studentID,
  ) async {
    final url = 'http://$baseURl:8080/api/admin/student/$studentID';
    var accessToken = await getAccessToken();
    var headers = {
      'authorization': accessToken,
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        String message = responseData['message'];
        print('Message: $message');
        return true;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.delete(Uri.parse(url), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            String message = responseData['message'];
            print('Message: $message');
            return true;
          } else {
            return false;
          }
        } else {
          print('New Access Token is empty');
          return false;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<CourseModel?> createNewCourse(String courseID, String courseName,
      int totalWeeks, int requiredWeeks, int credit) async {
    var url = 'http://$baseURl:8080/api/admin/submit/course';
    var accessToken = await getAccessToken();
    var request = {
      'courseID': courseID,
      'courseName': courseName,
      'totalWeeks': totalWeeks,
      'requiredWeeks': requiredWeeks,
      'credit': credit
    };
    var body = json.encode(request);
    var headers = {
      'authorization': accessToken,
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      print('body:$body');
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        CourseModel data = CourseModel.fromJson(responseData);
        print('Data1:$data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.post(Uri.parse(url), headers: headers, body: body);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            CourseModel data = CourseModel.fromJson(responseData);
            print('Data $data');
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool?> updateCourse(String courseID, String courseName, int totalWeeks,
      int requiredWeeks, int credit) async {
    final url = 'http://$baseURl:8080/api/admin/edit/course/$courseID';
    var accessToken = await getAccessToken();
    var request = {
      'courseName': courseName,
      'totalWeeks': totalWeeks,
      'requiredWeeks': requiredWeeks,
      "credit": credit
    };
    var body = json.encode(request);
    var headers = {
      'authorization': accessToken,
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      final response =
          await http.put(Uri.parse(url), headers: headers, body: body);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        String message = responseData['message'];
        print('Message: $message');
        return true;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.put(Uri.parse(url), headers: headers, body: body);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            String message = responseData['message'];
            print('Message: $message');
            return true;
          } else {
            return false;
          }
        } else {
          print('New Access Token is empty');
          return false;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool?> deleteCourse(
    String courseID,
  ) async {
    final url = 'http://$baseURl:8080/api/admin/course/$courseID';
    var accessToken = await getAccessToken();
    var headers = {
      'authorization': accessToken,
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        String message = responseData['message'];
        print('Message: $message');
        return true;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.delete(Uri.parse(url), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            String message = responseData['message'];
            print('Message: $message');
            return true;
          } else {
            return false;
          }
        } else {
          print('New Access Token is empty');
          return false;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<StudentDetail>> getStudentsInClass(String classID) async {
    var URL = 'http://$baseURl:8080/api/admin/classes/$classID'; //10.0.2.2

    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        List<StudentDetail> data = [];

        if (responseData is List) {
          for (var temp in responseData) {
            if (temp is Map<String, dynamic>) {
              try {
                data.add(StudentDetail.fromJson(temp));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Invalid data type: $temp');
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          try {
            data.add(StudentDetail.fromJson(responseData));
          } catch (e) {
            print('Error parsing data: $e');
          }
        } else {
          print('Unexpected data type: $responseData');
        }
        // print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            List<StudentDetail> data = [];

            if (responseData is List) {
              for (var temp in responseData) {
                if (temp is Map<String, dynamic>) {
                  try {
                    data.add(StudentDetail.fromJson(temp));
                  } catch (e) {
                    print('Error parsing data: $e');
                  }
                } else {
                  print('Invalid data type: $temp');
                }
              }
            } else if (responseData is Map<String, dynamic>) {
              try {
                data.add(StudentDetail.fromJson(responseData));
              } catch (e) {
                print('Error parsing data: $e');
              }
            } else {
              print('Unexpected data type: $responseData');
            }

            // print('Data $data');
            return data;
          } else {
            return [];
          }
        } else {
          print('New Access Token is empty');
          return [];
        }
      } else {
        print(
            'Failed to load reports data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<AddStudentResponse?> createNewStudentInsideClass(
      String studentID, String classID) async {
    var url = 'http://$baseURl:8080/api/admin/submit/studentclass';
    var accessToken = await getAccessToken();
    var request = {
      'studentID': studentID,
      'classID': classID,
    };
    var body = json.encode(request);
    var headers = {
      'authorization': accessToken,
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        AddStudentResponse data = AddStudentResponse.fromJson(responseData);
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.post(Uri.parse(url), headers: headers, body: body);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            AddStudentResponse data = AddStudentResponse.fromJson(responseData);
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<String?> deleteStudentInsideClass(
    String classID,
    String studentID,
  ) async {
    final url =
        'http://$baseURl:8080/api/admin/class/$classID/student/$studentID';
    var accessToken = await getAccessToken();
    var headers = {
      'authorization': accessToken,
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        String message = responseData['message'];
        print('Message: $message');
        return message;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.delete(Uri.parse(url), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            String message = responseData['message'];
            print('Message: $message');
            return message;
          } else {
            return '';
          }
        } else {
          print('New Access Token is empty');
          return '';
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }

  Future<ClassData?> getClassesInsideCourse(String courseID, int page) async {
    var URL =
        'http://$baseURl:8080/api/admin/courses/$courseID/classes/page/$page';
    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        ClassData data = ClassData.fromJson(responseData);
        print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            ClassData data = ClassData.fromJson(responseData);

            // print('Data $data');
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<UploadStudentsResponse?> uploadExcelStudentInsideClass(
      Uint8List excelBytes, String classID) async {
    var uri = Uri.parse(
        'http://$baseURl:8080/api/admin/classes/$classID/uploadstudents');
    var accessToken = await getAccessToken();
    try {
      var request = http.MultipartRequest("PUT", uri);
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: 'excel_file.xlsx',
      );
      request.files.add(multipartFile);
      request.headers['Authorization'] = accessToken;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        if (responseBody.isNotEmpty) {
          var jsonResponse = jsonDecode(responseBody);
          UploadStudentsResponse data =
              UploadStudentsResponse.fromJson(jsonResponse);
          return data;
        } else {
          return null;
        }
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          var retryRequest = http.MultipartRequest("PUT", uri);
          retryRequest.headers['Authorization'] = newAccessToken;
          var retryMultipartFile = http.MultipartFile.fromBytes(
            'file',
            excelBytes,
            filename: 'excel_file.xlsx',
          );
          retryRequest.files.add(retryMultipartFile);

          var retryResponse = await retryRequest.send();
          print('retryResponse status: ${retryResponse.statusCode}');
          if (retryResponse.statusCode == 200) {
            var retryReponsebody = await retryResponse.stream.bytesToString();
            if (retryReponsebody.isNotEmpty) {
              var jsonRetryResponse = jsonDecode(retryReponsebody);
              UploadStudentsResponse data =
                  UploadStudentsResponse.fromJson(jsonRetryResponse);
              return data;
            }
            return null;
          }
        } else {
          print('Access Token is empty');
        }
      } else {
        print('Non-200 response: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
    return null;
  }

  Future<ProgressModel?> getDataChart(String classID) async {
    var URL = 'http://$baseURl:8080/api/admin/classes/$classID/stats';
    var accessToken = await getAccessToken();
    var headers = {'authorization': accessToken};
    try {
      final response = await http.get(Uri.parse(URL), headers: headers);
      // print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        ProgressModel data = ProgressModel.fromJson(responseData);
        print('Data $data');
        return data;
      } else if (response.statusCode == 498 || response.statusCode == 401) {
        var refreshToken = await SecureStorage().readSecureData('refreshToken');
        var newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          headers['authorization'] = newAccessToken;
          final retryResponse =
              await http.get(Uri.parse(URL), headers: headers);
          if (retryResponse.statusCode == 200) {
            // print('-- RetryResponse.body ${retryResponse.body}');
            // print('-- Retry JsonDecode:${jsonDecode(retryResponse.body)}');
            dynamic responseData = jsonDecode(retryResponse.body);
            ProgressModel data = ProgressModel.fromJson(responseData);
            // print('Data $data');
            return data;
          } else {
            return null;
          }
        } else {
          print('New Access Token is empty');
          return null;
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
