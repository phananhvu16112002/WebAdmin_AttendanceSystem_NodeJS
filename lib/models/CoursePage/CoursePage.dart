class CourseModel {
  String courseID;
  String courseName;
  int totalWeeks;
  int requiredWeeks;
  int credit;

  CourseModel({
    required this.courseID,
    required this.courseName,
    required this.totalWeeks,
    required this.requiredWeeks,
    required this.credit,
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
