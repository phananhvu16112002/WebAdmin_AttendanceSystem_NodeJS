import 'dart:math';
import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomTextField.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/DetailPage/StudentDetail.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/ClassModel.dart';
import 'package:admin_attendancesystem_nodejs/models/StudentPage/Student.dart';
import 'package:admin_attendancesystem_nodejs/models/test/StudentTest.dart';
import 'package:admin_attendancesystem_nodejs/models/test/StudentTest.dart';
import 'package:admin_attendancesystem_nodejs/screens/DetailClass/chart_class_screen.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/HomePage.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.classModel});
  final ClassModel classModel;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController searchInDashboardController = TextEditingController();
  TextEditingController studentIDController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();
  TextEditingController studentEmailController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool checkHome = true;
  bool checkChart = false;

  int currentPage = 0;
  int studentsPerPage = 10;
  List<StudentDetail> listData = [];
  List<StudentDetail> listTemp = [];
  List<StudentDetail> searchResult = [];
  // List<StudentTest> listData = StudentTest.listData();
  // List<StudentTest> listTemp = [];
  // List<StudentTest> searchResult = [];
  late Future<List<StudentDetail>> _fetchListStudent;
  late ProgressDialog _progressDialog;
  Uint8List? _excelBytes;
  String fileName = '';
  final formkey = GlobalKey<FormState>();
  bool isCollapsedOpen = true;

  void fetchData() async {
    _fetchListStudent =
        API(context).getStudentsInClass(widget.classModel.classID ?? '');
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
    List<StudentDetail> temp = listData;
    for (var element in temp) {
      if (element.studentEmail!.contains(query.trim()) ||
          element.studentEmail!.toLowerCase().trim() ==
              query.toLowerCase().trim() ||
          element.studentName!.contains(query.trim()) ||
          element.studentName?.toLowerCase().trim() ==
              query.toLowerCase().trim() ||
          element.studentID!.contains(query.trim()) ||
          element.studentID?.toLowerCase().trim() ==
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

  Future<void> _uploadFile() async {
    if (_excelBytes == null) {
      // Fluttertoast.showToast(msg: 'Please select a file to upload');
      print('null');
      return;
    }
    try {
      _progressDialog.show();
      var response = await API(context).uploadExcelStudentInsideClass(
          _excelBytes!, widget.classModel.classID ?? '');
      print('response: $response');
      if (response != null) {
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
                    Text(response.message),
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
                        listTemp.addAll(response.students);
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
                    Text(response?.message ??
                        "Failed upload file excel to server "),
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

  void toggleDrawer() {
    setState(() {
      isCollapsedOpen = !isCollapsedOpen;
    });
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
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsedOpen ? 250 : 70,
              child: isCollapsedOpen ? leftHeader() : collapsedSideBar(),
            ),
            Expanded(
              child: selectedPage(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      leading: Icon(null),
      backgroundColor: AppColors.colorHeader,
      flexibleSpace: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const HomePage()));
                  },
                  mouseCursor: SystemMouseCursors.click,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 180),
                IconButton(
                    onPressed: () {
                      toggleDrawer();
                    },
                    icon: const Icon(
                      Icons.menu,
                      size: 25,
                      color: AppColors.textName,
                    ))
              ],
            ),
            Row(
              children: [
                CustomTextField(
                  controller: searchController,
                  textInputType: TextInputType.text,
                  obscureText: false,
                  suffixIcon: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.search)),
                  hintText: 'Search',
                  prefixIcon: const Icon(null),
                  readOnly: false,
                  height: 40,
                  width: 350,
                ),
                const SizedBox(
                  width: 60,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_outlined)),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.messenger_outline_sharp)),
                const SizedBox(
                  width: 10,
                ),
                MouseRegion(
                  onHover: (event) => showMenu(
                    color: Colors.white,
                    context: context,
                    position: const RelativeRect.fromLTRB(300, 50, 30, 100),
                    items: [
                      const PopupMenuItem(
                        child: Text("My Profile"),
                      ),
                      const PopupMenuItem(
                        child: Text("Log Out"),
                      ),
                    ],
                  ),
                  child: Container(
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              AssetImage('assets/images/avatar.png'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        CustomText(
                            message: 'Admin',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textName)
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget leftHeader() {
    return Container(
      width: 250,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(5), bottomRight: Radius.circular(5))),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const CustomText(
                message: 'Main',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Manage', const Icon(Icons.home_outlined), checkHome),
            const CustomText(
                message: 'Analyze',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Chart', const Icon(Icons.bar_chart_sharp), checkChart),
          ],
        ),
      ),
    );
  }

  Widget itemHeader(String title, Icon icon, bool check) {
    return InkWell(
      onTap: () {
        setState(() {
          checkHome = false;
          checkChart = false;
          if (title == 'Manage') {
            checkHome = true;
          } else if (title == 'Chart') {
            checkChart = true;
          }
        });
      },
      child: Container(
        height: 40,
        width: 220,
        decoration: BoxDecoration(
            color: check
                ? const Color.fromARGB(62, 226, 240, 253)
                : Colors.transparent,
            border: Border.all(color: Colors.transparent, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              icon,
              const SizedBox(
                width: 5,
              ),
              CustomText(
                  message: title,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textName)
            ],
          ),
        ),
      ),
    );
  }

  Widget collapsedSideBar() {
    return Container(
      width: 80,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              setState(() {
                checkHome = true;
                checkChart = false;
              });
            },
            child:
                iconCollapseSideBar(const Icon(Icons.home_outlined), checkHome),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              setState(() {
                checkHome = false;
                checkChart = true;
              });
            },
            child: iconCollapseSideBar(
              const Icon(Icons.bar_chart_sharp),
              checkChart,
            ),
          ),
        ],
      ),
    );
  }

  Container iconCollapseSideBar(Icon icon, bool check) {
    return Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.white),
            color: check
                ? AppColors.colorHeader.withOpacity(0.5)
                : Colors.transparent),
        child: icon);
  }

  Widget selectedPage() {
    if (checkHome) {
      return containerHome();
    } else if (checkChart) {
      // html.window.history.pushState({}, 'Notification', '/Detail/Notification');
      return ChartClassScreen(classModel: widget.classModel,);
    } else {
      return containerHome();
    }
  }

  Widget containerHome() {
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
            CustomText(
                message:
                    '${widget.classModel.course?.courseName} - Room: ${widget.classModel.roomNumber} - Shift: ${widget.classModel.shiftNumber}',
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText),
            const SizedBox(
              height: 10,
            ),
            CustomText(
                message:
                    'Lecturer: ${widget.classModel.teacher?.teacherName} - ${widget.classModel.teacher?.teacherID}',
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
                      function: () {
                        createNewStudent(context);
                      },
                      height: 50,
                      width: 150,
                      fontSize: 12,
                      colorShadow: Colors.white,
                      borderRadius: 8),
                  SizedBox(
                    width: 10,
                  ),
                  CustomButton(
                      buttonName: 'Delete all student',
                      backgroundColorButton: AppColors.importantText,
                      borderColor: Colors.transparent,
                      textColor: Colors.white,
                      function: () {
                        // showDialog(context: context, builder: (builder) => AlertDialog(

                        // ));
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

  Table tableAttendance(List<StudentDetail> studentAttendance) {
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
                        message: studentAttendance[i].studentID ?? '',
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
                        message: studentAttendance[i].studentName ?? '',
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
                  child: const Center(
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
                        message: studentAttendance[i].studentEmail ?? '',
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
                  child: const Center(
                    child: Text('',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        )),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  editStudentDialog(
                      context,
                      studentAttendance[i].studentID ?? '',
                      studentAttendance[i].studentName ?? '',
                      i);
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
                  _deleteStudentDialog(studentAttendance ?? [], i);
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

  Future<dynamic> editStudentDialog(BuildContext context, String studentID,
          String studentName, int index) =>
      showDialog(
          context: context,
          builder: (builder) {
            studentIDController.text = studentID;
            studentNameController.text = studentName;
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
                    key: formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: CustomText(
                              message: 'Edit Student',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryButton),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const CustomText(
                            message: 'Student ID',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            true,
                            studentIDController,
                            TextInputType.phone,
                            const IconButton(
                                onPressed: null,
                                icon: Icon(Icons.card_membership_outlined,
                                    color: Colors.blue)),
                            'Ex: 520H0696',
                            true),
                        const SizedBox(
                          height: 10,
                        ),
                        const CustomText(
                            message: 'Student Name',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                          false,
                          studentNameController,
                          TextInputType.phone,
                          const IconButton(
                              onPressed: null,
                              icon: Icon(Icons.card_membership_outlined,
                                  color: Colors.blue)),
                          'Ex: Nguyen Van A',
                          true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: CustomButton(
                              buttonName: 'Edit',
                              backgroundColorButton: AppColors.primaryButton,
                              borderColor: Colors.white,
                              textColor: Colors.white,
                              function: () async {
                                _editLecturer(studentID,
                                    studentNameController.text, index);
                              },
                              height: 40,
                              width: 200,
                              fontSize: 15,
                              colorShadow: Colors.transparent,
                              borderRadius: 10),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });

  Future<void> _editLecturer(
      String studentID, String studentName, int index) async {
    try {
      _progressDialog.show();
      var response = await API(context).updateStudent(studentID, studentName);
      if (response != null && response) {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Edit Student"),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Edit student successfully"),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      setState(() {
                        listTemp[index].studentID = studentID;
                        listTemp[index].studentName = studentName;
                      });
                      Navigator.of(context).pop();
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
                    const Text("Failed edit student "),
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

  Future<dynamic> _deleteStudentDialog(List<StudentDetail> studentList, int i) {
    return showDialog(
        context: context,
        builder: (builder) => AlertDialog(
              backgroundColor: Colors.white,
              title: const CustomText(
                  message: 'Are you want to delete student ?',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: CustomText(
                        message: 'Cancel',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryButton)),
                TextButton(
                  onPressed: () async {
                    _progressDialog.show();
                    String? check = await API(context).deleteStudentInsideClass(
                        widget.classModel.classID ?? '',
                        studentList[i].studentID ?? '');
                    if (check != null && check.isNotEmpty) {
                      await _progressDialog.hide();
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (builder) => AlertDialog(
                            title: CustomText(
                                message: check,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText),
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
                            title: CustomText(
                                message: check ?? 'Delete student failed',
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

  Widget showPage(List<StudentDetail> studentAttendance) {
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

  Future<dynamic> createNewStudent(BuildContext context) {
    studentIDController.text = '';
    return showDialog(
        context: context,
        builder: (builder) => Dialog(
              backgroundColor: Colors.white,
              child: Container(
                width: (MediaQuery.of(context).size.width - 250) / 2 - 20,
                // height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Center(
                          child: CustomText(
                              message: 'Create New Student',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryButton),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const CustomText(
                            message: 'Student ID',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            false,
                            studentIDController,
                            TextInputType.phone,
                            IconButton(
                                onPressed: null,
                                icon: const Icon(Icons.card_membership_outlined,
                                    color: Colors.blue)),
                            'Ex: 520H0696',
                            true),
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
                                    studentIDController.text = '';
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
                                  if (formkey.currentState!.validate()) {
                                    _submitStudent(
                                      studentIDController.text,
                                      widget.classModel.classID ?? '',
                                    );
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

  Future<void> _submitStudent(
    String studentID,
    String classID,
  ) async {
    try {
      _progressDialog.show();
      var response =
          await API(context).createNewStudentInsideClass(studentID, classID);
      if (response != null) {
        await _progressDialog.hide();
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Create Student"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${response.message}'),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      setState(() {
                        listTemp.add(response.studentDetail);
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
                title: const Text("Failed"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(response?.message ?? ''),
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
