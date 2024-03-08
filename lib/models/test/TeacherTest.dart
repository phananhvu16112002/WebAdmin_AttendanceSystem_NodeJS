class TeacherTest {
  final String teacherID;
  final String teacherName;
  final String phoneNumber;
  final String teacherEmail;
  final String faculty;

  TeacherTest(
      {required this.teacherID,
      required this.teacherName,
      required this.teacherEmail,
      required this.phoneNumber,
      required this.faculty});

  static List<TeacherTest> listData() {
    List<TeacherTest> listTemp = [];
    for (int i = 0; i < 20; i++) {
      listTemp.add(TeacherTest(
          teacherID: 'teacherID$i',
          teacherName: 'Phan Anh Vu$i',
          teacherEmail: 'phananhvu$i@tdtu.edu.com',
          phoneNumber: '096300517$i',
          faculty: 'Information Technology'));
    }
    listTemp.add(TeacherTest(
        teacherID: '520H0380',
        teacherName: 'Tan Quang Hoang Tri',
        teacherEmail: 'htuankiet@tdtu.edu.vn',
        phoneNumber: '0963005177',
        faculty: 'Software Engineering'));
    listTemp.add(TeacherTest(
        teacherID: '520H0696',
        teacherName: 'Nguyen Hoang Phuong Uyen',
        teacherEmail: 'panhvu1611@tdtu.edu.vn',
        phoneNumber: '0986025322',
        faculty: 'Computer Sience'));

    return listTemp;
  }
}
