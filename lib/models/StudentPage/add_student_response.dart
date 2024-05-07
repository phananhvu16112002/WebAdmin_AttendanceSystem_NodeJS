import 'package:admin_attendancesystem_nodejs/models/DetailPage/StudentDetail.dart';

class AddStudentResponse {
  final StudentDetail studentDetail;
  final String message;

  AddStudentResponse({
    required this.studentDetail,
    required this.message,
  });

  factory AddStudentResponse.fromJson(Map<String, dynamic> json) {
    return AddStudentResponse(
      studentDetail: StudentDetail.fromJson(json['data']),
      message: json['message'],
    );
  }
}
