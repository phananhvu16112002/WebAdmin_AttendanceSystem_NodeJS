class TeacherPage {
   String? teacherID;
   String? teacherName;
   String? teacherEmail;

  TeacherPage({
     this.teacherID,
     this.teacherName,
     this.teacherEmail,
  });

  factory TeacherPage.fromJson(Map<String, dynamic> json) {
    return TeacherPage(
      teacherID: json['teacherID'],
      teacherName: json['teacherName'],
      teacherEmail: json['teacherEmail'],
    );
  }
}