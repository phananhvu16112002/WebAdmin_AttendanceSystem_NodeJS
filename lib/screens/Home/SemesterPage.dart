import 'dart:math';
import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/CoursePage/CourseModel.dart';

import 'package:admin_attendancesystem_nodejs/models/StudentPage/Student.dart';
import 'package:admin_attendancesystem_nodejs/models/semester.dart';
import 'package:admin_attendancesystem_nodejs/screens/DetailCourse/detail_course_screen.dart';

import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class SemesterPage extends StatefulWidget {
  const SemesterPage({super.key});

  @override
  State<SemesterPage> createState() => _SemesterPageState();
}

class _SemesterPageState extends State<SemesterPage> {
  TextEditingController searchInDashboardController = TextEditingController();
  TextEditingController semesterID = TextEditingController();
  TextEditingController semesterNameController = TextEditingController();
  TextEditingController semesterDescription = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController credit = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? dateStart;
  DateTime? dateEnd;
  bool isStartDateSelected = false;
  bool isEndDateSelected = false;

  int currentPage = 0;
  int studentsPerPage = 10;
  List<Semester> listData = [];
  List<Semester> listTemp = [];
  List<Semester> searchResult = [];
  late Future<List<Semester>> _fetchListSemester;

  late ProgressDialog _progressDialog;
  Uint8List? _excelBytes;
  String fileName = '';

  void fetchData() async {
    _fetchListSemester = API(context).getSemester();
    _fetchListSemester.then((value) {
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
    List<Semester> temp = listData;
    for (var element in temp) {
      if (element.semesterName!.contains(query) ||
          element.semesterName?.toLowerCase().trim() ==
              query.toLowerCase().trim() ||
          element.semesterDescription!.contains(query) ||
          element.semesterDescription?.toLowerCase().trim() ==
              query.toLowerCase().trim()) {
        searchResult.add(element);
      }
    }
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
        fileName = result.files.single.name;
      });
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

  Future<void> selectDateStart(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: dateStart ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: 'Select Start Date For Attendance',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(useMaterial3: false)
              .copyWith(primaryColor: Colors.white),
          child: child!,
        );
      },
    );
    if (date != null && date != dateStart) {
      setState(() {
        dateStart = date;
        isStartDateSelected = true;
        startTimeController.text = formatDatePicker(dateStart!).toString();
        checkDuplicateDate();
      });
    }
  }

  Future<void> selectDateEnd(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: dateEnd ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: 'Select End Date For Attendance',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(useMaterial3: false)
              .copyWith(primaryColor: Colors.white),
          child: child!,
        );
      },
    );
    if (date != null && date != dateEnd) {
      setState(() {
        dateEnd = date;
        isEndDateSelected = true;
        endTimeController.text = formatDatePicker(dateEnd!).toString();
        checkDuplicateDate();
      });
    }
  }

  bool checkDuplicateDate() {
    if (isStartDateSelected && isEndDateSelected) {
      if (dateStart!.isAfter(dateEnd!) ||
          dateStart!.isAtSameMomentAs(dateEnd!)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Error'),
              content: const Text('Start Date must be before End Date.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                message: 'Information Courses',
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
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
                        hintText: 'Search Semester',
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
                      buttonName: 'Create New Semester',
                      backgroundColorButton: const Color(0xff2d71b1),
                      borderColor: Colors.transparent,
                      textColor: Colors.white,
                      function: () {
                        createNewSemester(context);
                      },
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
                ? SizedBox(
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

  Table tableAttendance(List<Semester> semester) {
    int startIndex = currentPage * studentsPerPage;
    int endIndex = min((currentPage + 1) * studentsPerPage, semester.length);
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
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
                      message: 'Semester Name',
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
                      message: 'Descriptions',
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
                      message: 'Start Date',
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
                      message: 'End Date',
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
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (builder) => DetailCourseScreen(
                  //             courseModel: semester[i])));
                },
                child: TableCell(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.white,
                    child: Center(
                      child: CustomText(
                          message: '${semester[i].semesterID}',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (builder) => DetailCourseScreen(
                  //               courseModel: semester[i],
                  //             )));
                },
                child: TableCell(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: CustomText(
                          message: semester[i].semesterName.toString(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: TableCell(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.white,
                    child: Center(
                      child: CustomText(
                          message: semester[i].semesterDescription ?? '',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: TableCell(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.white,
                    child: Center(
                      child: CustomText(
                          message:
                              '${formatDate(semester[i].startDate.toString())}',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: TableCell(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.white,
                    child: Center(
                      child: CustomText(
                          message:
                              '${formatDate(semester[i].endDate.toString())}',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  editSemester(
                      context,
                      semester[i].semesterName ?? '',
                      semester[i].semesterDescription ?? '',
                      semester[i].startDate ?? '',
                      semester[i].endDate ?? '',
                      semester[i].semesterID ?? 0);
                },
                child: TableCell(
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
              ),
              InkWell(
                onTap: () {
                  _deleteSemesterDialog(semester, i);
                },
                child: TableCell(
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
              ),
            ],
          ),
      ],
    );
  }

  Future<dynamic> _deleteSemesterDialog(List<Semester> semester, int i) {
    return showDialog(
        context: context,
        builder: (builder) => AlertDialog(
              backgroundColor: Colors.white,
              title: const CustomText(
                  message: 'Are you want to delete semester ?',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const CustomText(
                      message: 'Cancel',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryButton),
                ),
                TextButton(
                  onPressed: () async {
                    _progressDialog.show();
                    String? check = await API(context)
                        .deleteSemester(semester[i].semesterID ?? 0);
                    if (  check != null && check.isNotEmpty) {
                      await _progressDialog.hide();
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (builder) => AlertDialog(
                            title: const CustomText(
                                message: 'Delete semester successfully',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryButton),
                            actions: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    listTemp.removeAt(i);
                                  });
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const CustomText(
                                    message: 'OK',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryButton),
                              )
                            ],
                          ),
                        );
                      }
                    } else {
                      await _progressDialog.hide();
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (builder) => AlertDialog(
                            title: const CustomText(
                                message: 'Delete cousre failed',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryButton),
                            actions: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const CustomText(
                                    message: 'OK',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.importantText),
                              )
                            ],
                          ),
                        );
                      }
                    }
                  },
                  child: const CustomText(
                      message: 'Accept',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.importantText),
                ),
              ],
            ));
  }

  Widget showPage(List<Semester> semester) {
    int startIndex = currentPage * studentsPerPage;
    int endIndex = (currentPage + 1) * studentsPerPage;
    if (endIndex > semester.length) {
      endIndex = semester.length;
    }

    return Row(
      children: [
        CustomText(
          message:
              'Show ${startIndex + 1} - $endIndex of ${semester.length} results',
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
                '${currentPage + 1}/${(semester.length / studentsPerPage).ceil()}',
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: AppColors.primaryText),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              currentPage < (semester.length / studentsPerPage).ceil() - 1
                  ? Colors.white
                  : Colors.white,
            ),
          ),
          onPressed:
              currentPage < (semester.length / studentsPerPage).ceil() - 1
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
              color:
                  currentPage < (semester.length / studentsPerPage).ceil() - 1
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
      onTap: () {},
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

  Future<dynamic> createNewSemester(BuildContext context) {
    semesterID.text = '';
    semesterNameController.text = '';
    semesterDescription.text = '';
    startTimeController.text = '';
    endTimeController.text = '';
    credit.text = '';
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) => Dialog(
              backgroundColor: Colors.white,
              child: Container(
                width: (MediaQuery.of(context).size.width - 250) / 2 - 20,
                // height: 600,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black.withOpacity(0.1))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Center(
                          child: CustomText(
                              message: 'Create New Semester',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryButton),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const CustomText(
                            message: 'Semester Name',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                          false,
                          semesterNameController,
                          TextInputType.phone,
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.card_membership_outlined,
                                  color: Colors.blue)),
                          'Học kì 1 2023 - 2024',
                          true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const CustomText(
                            message: 'Description',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                          false,
                          semesterDescription,
                          TextInputType.phone,
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.card_membership_outlined,
                                  color: Colors.blue)),
                          'Ex: Nguyen Van A',
                          true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const CustomText(
                            message: 'Start Date',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        dateTime(
                            null,
                            40,
                            true,
                            startTimeController,
                            TextInputType.text,
                            IconButton(
                                onPressed: () => selectDateStart(context),
                                icon: Icon(Icons.lock_clock_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex: 15:15:00',
                            true, (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is not empty';
                          }
                          return null;
                        }),
                        const SizedBox(
                          height: 10,
                        ),
                        const CustomText(
                            message: 'End Date',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        dateTime(
                            null,
                            40,
                            true,
                            endTimeController,
                            TextInputType.text,
                            IconButton(
                                onPressed: () => selectDateEnd(context),
                                icon: Icon(Icons.lock_clock_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex: 15:15:00',
                            true, (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is not empty';
                          }
                          return null;
                        }),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                                buttonName: 'Cancel',
                                backgroundColorButton: Colors.transparent,
                                borderColor: Colors.white,
                                textColor: AppColors.primaryText,
                                function: () {
                                  setState(() {
                                    semesterDescription.text = '';
                                    semesterNameController.text = '';
                                    startTimeController.text = '';
                                    endTimeController.text = '';
                                  });
                                  Navigator.pop(context);
                                },
                                height: 40,
                                width: 200,
                                fontSize: 15,
                                colorShadow: Colors.transparent,
                                borderRadius: 10),
                            SizedBox(
                              width: 20,
                            ),
                            CustomButton(
                                buttonName: 'Create',
                                backgroundColorButton: AppColors.primaryButton,
                                borderColor: Colors.white,
                                textColor: Colors.white,
                                function: () {
                                  if (_formKey.currentState!.validate()) {
                                    _submitSemester(
                                        semesterNameController.text,
                                        semesterDescription.text,
                                        startTimeController.text,
                                        endTimeController.text);
                                  } else {
                                    if (semesterNameController.text.isEmpty) {
                                      _customDialog(
                                          context,
                                          'Field Semester Name',
                                          "Semester name is required");
                                    } else if (semesterDescription
                                        .text.isEmpty) {
                                      _customDialog(
                                          context,
                                          'Field Description',
                                          "Description is required");
                                    } else if (startTimeController
                                        .text.isEmpty) {
                                      _customDialog(context, 'Field StartTime',
                                          "StartTime is required");
                                    } else if (endTimeController.text.isEmpty) {
                                      _customDialog(context, 'Field EndTime',
                                          "EndTime is required");
                                    }
                                  }
                                },
                                height: 40,
                                width: 200,
                                fontSize: 15,
                                colorShadow: Colors.transparent,
                                borderRadius: 10),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  Future<dynamic> editSemester(BuildContext context, String semesterName,
          String description, String startTime, String endTime, int index) =>
      showDialog(
          context: context,
          builder: (builder) {
            semesterNameController.text = semesterName;
            semesterDescription.text = description;
            startTimeController.text =
                formatDatePicker(DateTime.parse(startTime));
            endTimeController.text = formatDatePicker(DateTime.parse(endTime));

            return Dialog(
              child: Container(
                width: (MediaQuery.of(context).size.width - 250) / 2 - 20,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black.withOpacity(0.1))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          const Center(
                            child: CustomText(
                                message: 'Edit Semester',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryButton),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const CustomText(
                              message: 'Semester Name',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                            false,
                            semesterNameController,
                            TextInputType.phone,
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.card_membership_outlined,
                                    color: Colors.blue)),
                            'Học kì 1 2023 - 2024',
                            true,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const CustomText(
                              message: 'Description',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                            false,
                            semesterDescription,
                            TextInputType.phone,
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.card_membership_outlined,
                                    color: Colors.blue)),
                            'Ex: Nguyen Van A',
                            true,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const CustomText(
                              message: 'Start Date',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          dateTime(
                              null,
                              40,
                              true,
                              startTimeController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: () => selectDateStart(context),
                                  icon: Icon(Icons.lock_clock_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex: 15:15:00',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          }),
                          const SizedBox(
                            height: 10,
                          ),
                          const CustomText(
                              message: 'End Date',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          dateTime(
                              null,
                              40,
                              true,
                              endTimeController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: () => selectDateEnd(context),
                                  icon: Icon(Icons.lock_clock_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex: 15:15:00',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          }),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                  buttonName: 'Cancel',
                                  backgroundColorButton: Colors.transparent,
                                  borderColor: Colors.white,
                                  textColor: AppColors.primaryText,
                                  function: () {
                                    setState(() {
                                      semesterDescription.text = '';
                                      semesterNameController.text = '';
                                      startTimeController.text = '';
                                      endTimeController.text = '';
                                    });
                                    Navigator.pop(context);
                                  },
                                  height: 40,
                                  width: 200,
                                  fontSize: 15,
                                  colorShadow: Colors.transparent,
                                  borderRadius: 10),
                              SizedBox(
                                width: 20,
                              ),
                              CustomButton(
                                  buttonName: 'Edit',
                                  backgroundColorButton:
                                      AppColors.primaryButton,
                                  borderColor: Colors.white,
                                  textColor: Colors.white,
                                  function: () {
                                    if (_formKey.currentState!.validate()) {
                                      _editSemester(
                                          index,
                                          semesterNameController.text,
                                          semesterDescription.text,
                                          formatDatePicker(DateTime.parse(
                                              startTimeController.text)),
                                          formatDatePicker(DateTime.parse(
                                              endTimeController.text)));
                                    } else {
                                      if (semesterNameController.text.isEmpty) {
                                        _customDialog(
                                            context,
                                            'Field Semester Name',
                                            "Semester name is required");
                                      } else if (semesterDescription
                                          .text.isEmpty) {
                                        _customDialog(
                                            context,
                                            'Field Description',
                                            "Description is required");
                                      } else if (startTimeController
                                          .text.isEmpty) {
                                        _customDialog(
                                            context,
                                            'Field StartTime',
                                            "StartTime is required");
                                      } else if (endTimeController
                                          .text.isEmpty) {
                                        _customDialog(context, 'Field EndTime',
                                            "EndTime is required");
                                      }
                                    }
                                  },
                                  height: 40,
                                  width: 200,
                                  fontSize: 15,
                                  colorShadow: Colors.transparent,
                                  borderRadius: 10),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ]),
                  ),
                ),
              ),
            );
          });

  Widget customTextField(
      bool readOnly,
      TextEditingController controller,
      TextInputType textInputType,
      IconButton iconSuffix,
      String hintText,
      bool enabled) {
    return Container(
      // width: width,
      // height: height,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: TextFormField(
        enabled: enabled,
        readOnly: readOnly,
        controller: controller,
        keyboardType: textInputType,
        style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.normal,
            fontSize: 15),
        obscureText: false,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(20),
            suffixIcon: iconSuffix,
            hintText: hintText,
            hintStyle:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5)),
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide:
                    BorderSide(width: 1, color: Colors.black.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide:
                    BorderSide(width: 1, color: Colors.black.withOpacity(0.2))),
            // errorBorder: ,
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(
                    width: 1, color: Colors.black.withOpacity(0.5)))),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Future<dynamic> _customDialog(
      BuildContext context, String title, String content) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget dateTime(
      double? width,
      double height,
      bool readOnly,
      TextEditingController controller,
      TextInputType textInputType,
      IconButton iconSuffix,
      String hintText,
      bool enabled,
      String? Function(String?)? validator) {
    return Container(
      width: width,
      // height: height,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: TextFormField(
        enabled: enabled,
        readOnly: readOnly,
        controller: controller,
        keyboardType: textInputType,
        style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.normal,
            fontSize: 15),
        obscureText: false,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(20),
            suffixIcon: iconSuffix,
            hintText: hintText,
            hintStyle:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5)),
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide:
                    BorderSide(width: 1, color: Colors.black.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide:
                    BorderSide(width: 1, color: Colors.black.withOpacity(0.2))),
            // errorBorder: ,
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(
                    width: 1, color: Colors.black.withOpacity(0.5)))),
        validator: validator,
      ),
    );
  }

  String formatDate(String date) {
    DateTime serverDateTime = DateTime.parse(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(serverDateTime);
    return formattedDate;
  }

  String formatTime(String time) {
    DateTime serverDateTime = DateTime.parse(time);
    String formattedTime = DateFormat('HH:mm a').format(serverDateTime);
    return formattedTime;
  }

  DateTime formatTimeOfDate(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  String formatDatePicker(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _submitSemester(String semesterName, String semesterDescription,
      String startDate, String endDate) async {
    try {
      _progressDialog.show();
      var response = await API(context).createSemester(
          semesterName, semesterDescription, startDate, endDate);
      if (response.isNotEmpty) {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Create Semester"),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Create semester successfully"),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      setState(() {
                        listTemp = response;
                      });
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Failed"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Failed create semester "),
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
      }
    } catch (e) {}
  }

  Future<void> _editSemester(int semesterId, String semesterName,
      String description, String startDate, String endDate) async {
    try {
      _progressDialog.show();
      var response = await API(context).editSemester(
          semesterId, semesterName, description, startDate, endDate);
      if (response.isNotEmpty) {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Edit Semester"),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Edit semester successfully"),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      setState(() {
                        listTemp = response;
                      });
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Failed"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Failed edit course "),
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
}
