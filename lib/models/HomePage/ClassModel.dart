import 'package:admin_attendancesystem_nodejs/models/CoursePage/CourseModel.dart';
import 'package:admin_attendancesystem_nodejs/models/LecturerPage/Teacher.dart';

class ClassModel {
  final String classID;
  final String roomNumber;
  final int shiftNumber;
  final String startTime;
  final String endTime;
  final String classType;
  final String group;
  final String subGroup;
  final TeacherPage teacher;
  final CourseModel course;

  ClassModel({
    required this.classID,
    required this.roomNumber,
    required this.shiftNumber,
    required this.startTime,
    required this.endTime,
    required this.classType,
    required this.group,
    required this.subGroup,
    required this.teacher,
    required this.course,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      classID: json['classID'],
      roomNumber: json['roomNumber'],
      shiftNumber: json['shiftNumber'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      classType: json['classType'],
      group: json['group'],
      subGroup: json['subGroup'],
      teacher: TeacherPage.fromJson(json['teacher']),
      course: CourseModel.fromJson(json['course']),
    );
  }
}
