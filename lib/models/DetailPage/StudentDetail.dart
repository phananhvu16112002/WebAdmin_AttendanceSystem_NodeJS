class StudentDetail {
  String? studentID;
  String? studentName;
  String? studentEmail;

  StudentDetail({
    this.studentID,
    this.studentName,
    this.studentEmail,
  });

  factory StudentDetail.fromJson(Map<String, dynamic> json) {
    return StudentDetail(
      studentID: json['studentDetail']['studentID'],
      studentName: json['studentDetail']['studentName'],
      studentEmail: json['studentDetail']['studentEmail'],
    );
  }
}
