import 'dart:math';
import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/StudentPage/Student.dart';
import 'package:admin_attendancesystem_nodejs/models/test/StudentTest.dart';
import 'package:admin_attendancesystem_nodejs/models/test/StudentTest.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  TextEditingController searchInDashboardController = TextEditingController();
  int currentPage = 0;
  int studentsPerPage = 10;
  List<Student> listData = [];
  List<Student> listTemp = [];
  List<Student> searchResult = [];
  // List<StudentTest> listData = StudentTest.listData();
  // List<StudentTest> listTemp = [];
  // List<StudentTest> searchResult = [];
  late Future<List<Student>> _fetchListStudent;
  late ProgressDialog _progressDialog;
  Uint8List? _excelBytes;
  String fileName = '';

  void fetchData() async {
    _fetchListStudent = API().getStudent();
    _fetchListStudent.then((value) {
      setState(() {
        listData = value;
        listTemp = value;
      });
    });
  }

  void searchTextChanged(String query) {
    searchResult.clear();
    if (query.isEmpty) {
      setState(() {
        listTemp = listData;
      });
      return;
    }
    List<Student> temp = listData;
    for (var element in temp) {
      if (element.studentEmail.contains(query) ||
          element.studentEmail.toLowerCase().trim() ==
              query.toLowerCase().trim() ||
          element.studentName.contains(query) ||
          element.studentName.toLowerCase().trim() ==
              query.toLowerCase().trim() ||
          element.studentID.contains(query) ||
          element.studentID.toLowerCase().trim() ==
              query.toLowerCase().trim()) {
        searchResult.add(element);
      }
    }
    print('----SearchResult: $searchResult');
    setState(() {
      currentPage = 0;
      listTemp = searchResult;
    });
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _excelBytes = result.files.single.bytes;
        fileName = result.files.single.name!;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_excelBytes == null) {
      // Fluttertoast.showToast(msg: 'Please select a file to upload');
      print('null');
      return;
    }
    try {
      _progressDialog.show();
      var response = await API().uploadExcelStudent(_excelBytes!);
      print('response: $response');
      if (response!.isNotEmpty ) {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Upload Excel"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Upload file excel to server successfully"),
                    const SizedBox(height: 8),
                    Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      setState(() {
                        fileName = '';
                        listTemp.addAll(response);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }

        print('ok');
      } else {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Upload Excel"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Failed upload file excel to server "),
                    const SizedBox(height: 8),
                    Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }

        print('failed');
      }
    } catch (e) {
      print('error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    _progressDialog = ProgressDialog(context,
        customBody: Container(
          width: 200,
          height: 150,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white),
          child: const Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryButton,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Loading',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500),
              ),
            ],
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 250,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const CustomText(
                message: 'Information Students',
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 250,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButtonDashBoard('Import Excel'),
                  _excelBytes != null
                      ? Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(),
                  customButtonUploadFile('Upload'),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 450,
                    height: 40,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color:
                            const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.2),
                        width: 0.5,
                      ),
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        searchTextChanged(value);
                      },
                      readOnly: false,
                      controller: searchInDashboardController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        hintText: 'Search Lectuer',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(73, 0, 0, 0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                              width: 1, color: AppColors.primaryButton),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  CustomButton(
                      buttonName: 'Create New Student',
                      backgroundColorButton: const Color(0xff2d71b1),
                      borderColor: Colors.transparent,
                      textColor: Colors.white,
                      function: () {},
                      height: 50,
                      width: 150,
                      fontSize: 12,
                      colorShadow: Colors.white,
                      borderRadius: 8)
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            listTemp.isNotEmpty
                ? Container(
                    width: MediaQuery.of(context).size.width - 250,
                    height: 380,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        tableAttendance(listTemp), // Truyen listData vao
                        const SizedBox(height: 20),
                        showPage(listTemp),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Opacity(
                          opacity: 0.3,
                          child: Image.asset('assets/images/nodata.png'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomText(
                          message: 'No Student Record',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: AppColors.primaryText.withOpacity(0.3))
                    ],
                  )),
          ],
        ),
      ),
    );
  }

  Table tableAttendance(List<Student> studentAttendance) {
    int startIndex = currentPage * studentsPerPage;
    int endIndex =
        min((currentPage + 1) * studentsPerPage, studentAttendance.length);
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FixedColumnWidth(120),
        2: IntrinsicColumnWidth(),
        3: FlexColumnWidth(1),
        4: IntrinsicColumnWidth(),
        5: FlexColumnWidth(1),
        6: FixedColumnWidth(70),
        7: FixedColumnWidth(70),
      },
      border: TableBorder.all(color: AppColors.secondaryText),
      children: [
        TableRow(
          children: [
            TableCell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xff1770f0).withOpacity(0.21),
                child: const Center(
                  child: CustomText(
                      message: 'No',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            TableCell(
              child: Container(
                color: const Color(0xff1770f0).withOpacity(0.21),
                padding: const EdgeInsets.all(5),
                child: const Center(
                  child: CustomText(
                      message: 'StudentID',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            TableCell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xff1770f0).withOpacity(0.21),
                child: const Center(
                  child: CustomText(
                      message: 'Name',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            TableCell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xff1770f0).withOpacity(0.21),
                child: const Center(
                  child: CustomText(
                      message: 'Phone Number',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            TableCell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xff1770f0).withOpacity(0.21),
                child: const Center(
                  child: CustomText(
                      message: 'Email',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            TableCell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xff1770f0).withOpacity(0.21),
                child: const Center(
                  child: CustomText(
                      message: 'Faculty',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            TableCell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xff1770f0).withOpacity(0.21),
                child: const Center(
                  child: CustomText(
                      message: 'Edit',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            TableCell(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xff1770f0).withOpacity(0.21),
                child: const Center(
                  child: CustomText(
                      message: 'Delete',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        //------------------------------------------
        for (int i = startIndex; i < endIndex; i++)
          TableRow(
            children: [
              TableCell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Center(
                    child: CustomText(
                        message: '${i + 1}',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: CustomText(
                        message: studentAttendance[i].studentID,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Center(
                    child: CustomText(
                        message: studentAttendance[i].studentName,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Center(
                    child: CustomText(
                        message: '',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Center(
                    child: CustomText(
                        message: studentAttendance[i].studentEmail,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Center(
                    child: Text('',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        )),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Edit',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryButton,
                          decorationColor: AppColors.primaryButton,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: const Center(
                    child: Text('Delete',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.importantText,
                            decorationColor: AppColors.importantText,
                            decoration: TextDecoration.underline)),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget showPage(List<Student> studentAttendance) {
    int startIndex = currentPage * studentsPerPage;
    int endIndex = (currentPage + 1) * studentsPerPage;
    if (endIndex > studentAttendance.length) {
      endIndex = studentAttendance.length;
    }

    return Row(
      children: [
        CustomText(
          message:
              'Show ${startIndex + 1} - $endIndex of ${studentAttendance.length} results',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              currentPage > 0 ? Colors.white : Colors.white,
            ),
          ),
          onPressed: currentPage > 0
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
          child: Text(
            'Previous',
            style: TextStyle(
              fontSize: 12,
              color: currentPage > 0 ? const Color(0xff2d71b1) : Colors.grey,
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        CustomText(
            message:
                '${currentPage + 1}/${(studentAttendance.length / studentsPerPage).ceil()}',
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: AppColors.primaryText),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              currentPage <
                      (studentAttendance.length / studentsPerPage).ceil() - 1
                  ? Colors.white
                  : Colors.white,
            ),
          ),
          onPressed: currentPage <
                  (studentAttendance.length / studentsPerPage).ceil() - 1
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
          child: Text(
            'Next',
            style: TextStyle(
              fontSize: 12,
              color: currentPage <
                      (studentAttendance.length / studentsPerPage).ceil() - 1
                  ? const Color(0xff2d71b1)
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget customButtonDashBoard(String nameButton) {
    return InkWell(
      onTap: _selectFile,
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
            color: nameButton == 'Import Excel'
                ? const Color(0xff2d71b1)
                : Colors.white,
            border: Border.all(
              width: 0.5,
              color: Colors.black.withOpacity(0.2),
            )),
        child: Center(
          child: CustomText(
              message: nameButton,
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: nameButton == 'Import Excel'
                  ? Colors.white
                  : AppColors.primaryText),
        ),
      ),
    );
  }

  Widget customButtonUploadFile(String nameButton) {
    return InkWell(
      onTap: _uploadFile,
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
            color:
                nameButton == 'Import' ? const Color(0xff2d71b1) : Colors.white,
            border: Border.all(
              width: 0.5,
              color: Colors.black.withOpacity(0.2),
            )),
        child: Center(
          child: CustomText(
              message: nameButton,
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: nameButton == 'Import'
                  ? Colors.white
                  : AppColors.primaryText),
        ),
      ),
    );
  }
}
