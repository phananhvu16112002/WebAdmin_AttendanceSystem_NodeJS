import 'package:admin_attendancesystem_nodejs/models/HomePage/ClassModel.dart';

class ClassData {
   int? totalPage;
   List<ClassModel>? classes;

  ClassData({
     this.totalPage,
     this.classes,
  });

  factory ClassData.fromJson(Map<String, dynamic> map) {
    return ClassData(
      totalPage: map['totalPage'] as int?,
      classes: (map['classes'] as List<dynamic>)
          .map((x) => ClassModel.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
}
