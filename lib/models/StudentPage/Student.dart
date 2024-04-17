class Student {
  String studentID;
  String studentName;
  String studentEmail;

  Student({
    required this.studentID,
    required this.studentName,
    required this.studentEmail,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: json['studentID'] ?? '',
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
    );
  }
}
