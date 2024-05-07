// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TotalModel {
  int? totalStudents;
  int? totalTeachers;
  int? totalCourses;
  int? totalClasses;
  TotalModel({
    this.totalStudents,
    this.totalTeachers,
    this.totalCourses,
    this.totalClasses,
  });

  TotalModel copyWith({
    int? totalStudents,
    int? totalTeachers,
    int? totalCourses,
    int? totalClasses,
  }) {
    return TotalModel(
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalCourses: totalCourses ?? this.totalCourses,
      totalClasses: totalClasses ?? this.totalClasses,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalCourses': totalCourses,
      'totalClasses': totalClasses,
    };
  }

  factory TotalModel.fromJson(Map<String, dynamic> map) {
    return TotalModel(
      totalStudents:
          map['totalStudents'] != null ? map['totalStudents'] as int : null,
      totalTeachers:
          map['totalTeachers'] != null ? map['totalTeachers'] as int : null,
      totalCourses:
          map['totalCourses'] != null ? map['totalCourses'] as int : null,
      totalClasses:
          map['totalClasses'] != null ? map['totalClasses'] as int : null,
    );
  }

  @override
  String toString() {
    return 'TotalModel(totalStudents: $totalStudents, totalTeachers: $totalTeachers, totalCourses: $totalCourses, totalClasses: $totalClasses)';
  }

  @override
  bool operator ==(covariant TotalModel other) {
    if (identical(this, other)) return true;

    return other.totalStudents == totalStudents &&
        other.totalTeachers == totalTeachers &&
        other.totalCourses == totalCourses &&
        other.totalClasses == totalClasses;
  }

  @override
  int get hashCode {
    return totalStudents.hashCode ^
        totalTeachers.hashCode ^
        totalCourses.hashCode ^
        totalClasses.hashCode;
  }
}
