class TeacherPage {
   String teacherID;
   String teacherName;
   String teacherEmail;

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