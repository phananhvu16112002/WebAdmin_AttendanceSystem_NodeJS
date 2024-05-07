class CourseModel {
  String? courseID;
  String? courseName;
  int? totalWeeks;
  int? requiredWeeks;
  int? credit;

  CourseModel({
     this.courseID,
     this.courseName,
     this.totalWeeks,
     this.requiredWeeks,
     this.credit,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseID: json['courseID'] ,
      courseName: json['courseName'],
      totalWeeks: json['totalWeeks'],
      requiredWeeks: json['requiredWeeks'],
      credit: json['credit'],
    );
  }
}
