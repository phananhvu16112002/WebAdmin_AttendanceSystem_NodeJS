import 'package:admin_attendancesystem_nodejs/models/DetailPage/StudentDetail.dart';

class UploadStudentsResponse {
  final List<StudentDetail> students;
  final String message;

  UploadStudentsResponse({
    required this.students,
    required this.message,
  });

  factory UploadStudentsResponse.fromJson(Map<String, dynamic> json) {
    List<StudentDetail> studentList = (json['data'] as List)
        .map((studentJson) =>
            StudentDetail.fromJson(studentJson))
        .toList();

    return UploadStudentsResponse(
      students: studentList,
      message: json['message'],
    );
  }
}
