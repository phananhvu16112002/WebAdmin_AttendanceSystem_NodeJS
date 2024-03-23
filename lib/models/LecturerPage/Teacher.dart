class TeacherPage {
  final String teacherID;
  final String teacherName;
  final String teacherEmail;

  TeacherPage({
    required this.teacherID,
    required this.teacherName,
    required this.teacherEmail,
  });

  factory TeacherPage.fromJson(Map<String, dynamic> json) {
    return TeacherPage(
      teacherID: json['teacherID'],
      teacherName: json['teacherName'],
      teacherEmail: json['teacherEmail'],
    );
  }
}