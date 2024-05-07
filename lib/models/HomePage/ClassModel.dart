  import 'package:admin_attendancesystem_nodejs/models/CoursePage/CourseModel.dart';
  import 'package:admin_attendancesystem_nodejs/models/LecturerPage/Teacher.dart';

  class ClassModel {
     String? classID;
     String? roomNumber;
     int? shiftNumber;
     String? startTime;
     String? endTime;
     String? classType;
     String? group;
     String? subGroup;
     TeacherPage? teacher;
     CourseModel? course;

    ClassModel({
       this.classID,
       this.roomNumber,
       this.shiftNumber,
       this.startTime,
       this.endTime,
       this.classType,
       this.group,
       this.subGroup,
       this.teacher,
       this.course,
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
