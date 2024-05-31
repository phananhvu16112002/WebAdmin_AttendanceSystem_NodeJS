import 'dart:math';

import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomTextField.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/Class.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/ClassModel.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/class_data_model.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/total_model.dart';
import 'package:admin_attendancesystem_nodejs/models/semester.dart';
import 'package:admin_attendancesystem_nodejs/screens/Authentication/WelcomePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/DetailClass/detail_class.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CoursePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewLectuer.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewStudent.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewClass.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/LectuerTestPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/LectuersPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/NotificationPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/SettingPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/StudentsPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/PreviewExcel.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/PreviewStudent.dart';
import 'package:admin_attendancesystem_nodejs/screens/Test.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:admin_attendancesystem_nodejs/services/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  bool checkHome = true;
  bool checkNotification = false;
  bool checkLectuers = false;
  bool checkStudents = false;
  bool checkSettings = false;
  bool checkCourse = false;
  bool checkCreateClass = false;
  bool checkPreviewClassExcel = false;
  bool checkPreviewStudentExcel = false;
  int totalLecturer = 0;
  int totalCourse = 0;
  int totalClass = 0;
  int totalStudent = 0;

  OverlayEntry? overlayEntry;
  int page = 1;

  bool isCollapsedOpen = true;
  SecureStorage storage = SecureStorage();
  late Future<TotalModel?> _fetchTotalModel;
  List<Semester> semesters = [];
  String dropdownvalue = '';
  int selectedIndex = 0;
  late Future<List<Semester>> _fetchSemester;

  void toggleDrawer() {
    setState(() {
      isCollapsedOpen = !isCollapsedOpen;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadToken();
    fetchData();
    fetchSemester();
  }

  Future<void> _loadToken() async {
    String? loadToken = await storage.readSecureData('accessToken');
    String? refreshToken1 = await storage.readSecureData('refreshToken');
    if (loadToken.isEmpty ||
        refreshToken1.isEmpty ||
        loadToken.contains('No Data Found') ||
        refreshToken1.contains('No Data Found')) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  void fetchData() async {
    _fetchTotalModel = API(context).getTotalHomePage();
    _fetchTotalModel.then((value) {
      setState(() {
        totalLecturer = value?.totalTeachers ?? 0;
        totalStudent = value?.totalStudents ?? 0;
        totalClass = value?.totalClasses ?? 0;
        totalCourse = value?.totalCourses ?? 0;
      });
    });
  }

  void fetchSemester() async {
    _fetchSemester = API(context).getSemester();
    _fetchSemester.then((value) {
      setState(() {
        semesters = value;
        dropdownvalue = semesters.first.semesterName ?? '';
      });
    });
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
                checkNotification = false;
                checkLectuers = false;
                checkStudents = false;
                checkSettings = false;
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
                checkNotification = true;
                checkLectuers = false;
                checkStudents = false;
                checkSettings = false;
              });
            },
            child: iconCollapseSideBar(
              const Icon(Icons.notifications_outlined),
              checkNotification,
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              setState(() {
                checkHome = false;
                checkNotification = false;
                checkLectuers = true;
                checkStudents = false;
                checkSettings = false;
              });
            },
            child: iconCollapseSideBar(
                const Icon(Icons.person_2_outlined), checkLectuers),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              setState(() {
                checkHome = false;
                checkNotification = false;
                checkLectuers = false;
                checkStudents = true;
                checkSettings = false;
              });
            },
            child: iconCollapseSideBar(
              const Icon(Icons.person_3_outlined),
              checkStudents,
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              setState(() {
                checkHome = false;
                checkNotification = false;
                checkLectuers = false;
                checkStudents = false;
                checkSettings = true;
              });
            },
            child: iconCollapseSideBar(
              const Icon(Icons.settings_outlined),
              checkSettings,
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

  PreferredSizeWidget appBar() {
    return AppBar(
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

  Widget itemHeader(String title, Icon icon, bool check) {
    return InkWell(
      onTap: () {
        setState(() {
          checkHome = false;
          checkNotification = false;
          checkLectuers = false;
          checkStudents = false;
          checkSettings = false;
          checkCourse = false;
          checkPreviewClassExcel = false;
          checkPreviewStudentExcel = false;

          if (title == 'Home') {
            checkHome = true;
          } else if (title == 'Notifications') {
            checkNotification = true;
          } else if (title == 'Courses') {
            checkCourse = true;
          } else if (title == 'Lectuers') {
            checkLectuers = true;
          } else if (title == 'Students') {
            checkStudents = true;
          } else if (title == 'Settings') {
            checkSettings = true;
          } else if (title == 'Excel Class') {
            checkPreviewClassExcel = true;
          } else if (title == 'Excel Student') {
            checkPreviewStudentExcel = true;
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

            // ElevatedButton(
            //     onPressed: () {}, child: const Text('Read Class Excel')),
            // ElevatedButton(
            //     onPressed: () {}, child: const Text('Read Student Excel')),
            const CustomText(
                message: 'Main',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Home', const Icon(Icons.home_outlined), checkHome),
            const CustomText(
                message: 'Analyze',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Notifications',
                const Icon(Icons.notifications_outlined), checkNotification),
            itemHeader('Courses', const Icon(Icons.bookmark_add_outlined),
                checkCourse),
            const CustomText(
                message: 'Manage',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader(
                'Lectuers', const Icon(Icons.person_2_outlined), checkLectuers),
            itemHeader(
                'Students', const Icon(Icons.person_2_outlined), checkStudents),
            const CustomText(
                message: 'Excel',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Excel Class', const Icon(Icons.data_saver_on_outlined),
                checkPreviewClassExcel),
            itemHeader(
                'Excel Student',
                const Icon(Icons.person_add_alt_1_outlined),
                checkPreviewStudentExcel),
            const CustomText(
                message: 'Personal',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader(
                'Settings', const Icon(Icons.settings_outlined), checkSettings),

            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget selectedPage() {
    if (checkHome) {
      return containerHome();
    } else if (checkNotification) {
      // html.window.history.pushState({}, 'Notification', '/Detail/Notification');
      return const NotificationPage();
    } else if (checkCourse) {
      return const CoursePage();
    } else if (checkLectuers) {
      return const LecturerPage();
    } else if (checkStudents) {
      return const StudentsPage();
    } else if (checkSettings) {
      return const SettingPage();
    } else if (checkPreviewClassExcel) {
      return const PreviewExcel();
    } else if (checkPreviewStudentExcel) {
      return const PreviewStudentExcel();
    } else {
      return containerHome();
    }
  }

  Widget customClass(
      String classID,
      String className,
      String typeClass,
      String group,
      String subGroup,
      int shiftNumber,
      String room,
      String imgPath,
      String teacherName,
      String teacherID,
      double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(0.1),
          )
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                SizedBox(
                  height: 150,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.asset(
                      imgPath,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Group: $group - Sub: $subGroup | ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Type: $typeClass',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Shift: $shiftNumber | ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Room: $room',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      CustomText(
                          message: 'Teacher: $teacherName',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {},
                    itemBuilder: (BuildContext bc) {
                      return [
                        const PopupMenuItem(
                          value: '/repository',
                          child: Text("Repository"),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            _deleteClassDialog(classID);
                          },
                          value: '/delete',
                          child: Text("Delete"),
                        ),
                      ];
                    },
                  ),
                )
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_2_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.document_scanner_outlined),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: 1150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.white,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuItem(
                  child: Text("My Profile"),
                ),
                PopupMenuItem(
                  child: Text("Log Out"),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  void _removePopupMenu() {
    overlayEntry?.remove();
  }

  Widget cusTomText(
      String message, double fontSize, FontWeight fontWeight, Color color) {
    return Text(message,
        overflow: TextOverflow.ellipsis,
        maxLines: null,
        style: GoogleFonts.inter(
            fontSize: fontSize, fontWeight: fontWeight, color: color));
  }

  Widget containerHome() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 250,
      height: MediaQuery.of(context).size.height,
      child: Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const CustomText(
                    message: 'Home',
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 250,
                  // height: 130,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: customBoxInformation(
                            'Classes', 'assets/icons/class.png', totalClass),
                      ),
                      const SizedBox(
                        width: 40,
                      ), // Show ben duoi theo class
                      Expanded(
                        child: customBoxInformation(
                            'Courses', 'assets/images/course.png', totalCourse),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      Expanded(
                        child: customBoxInformation('Students',
                            'assets/icons/student.png', totalStudent),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      Expanded(
                        child: customBoxInformation('Lectuers',
                            'assets/icons/lectuer.png', totalLecturer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    CustomText(
                        message: 'Select semester',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primaryText.withOpacity(0.2))),
                      child: DropdownButton<String>(
                        focusColor: Colors.transparent,
                        underline: Container(),
                        value: dropdownvalue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                        iconSize: 15,
                        menuMaxHeight: 150,
                        style: TextStyle(fontSize: 15),
                        items: semesters
                            .map<DropdownMenuItem<String>>((Semester value) {
                          return DropdownMenuItem<String>(
                            value: value.semesterName,
                            child: Text(value.semesterName ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                FutureBuilder(
                  future: API(context).getClasses(page),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        ClassData? classesData = snapshot.data;
                        // Future.delayed(Duration.zero, () {
                        //   classDataProvider.setAttendanceFormData(classes!);
                        // });
                        return Column(
                          children: [
                            GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        childAspectRatio: 2.1,
                                        mainAxisSpacing: 10),
                                itemCount: classesData?.classes?.length,
                                itemBuilder: (context, index) {
                                  ClassModel? data =
                                      classesData!.classes?[index];
                                  var randomBanner = Random().nextInt(3);

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) => DetailPage(
                                                    classModel:
                                                        data ?? ClassModel(),
                                                  )));
                                    },
                                    mouseCursor: SystemMouseCursors.click,
                                    child: customClass(
                                        data?.classID ?? '',
                                        data?.course?.courseName ?? '',
                                        data?.classType ?? '',
                                        data?.group ?? '',
                                        data?.subGroup ?? '',
                                        data?.shiftNumber ?? 0,
                                        data?.roomNumber ?? '',
                                        'assets/images/banner$randomBanner.jpg',
                                        data?.teacher?.teacherName ?? '',
                                        data?.teacher?.teacherID ?? '',
                                        550),
                                  );
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildPaginationButtons(classesData?.totalPage ?? 1)
                          ],
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                        value: 5,
                      ));
                    }
                    return const Center(child: Text('Data is not available'));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customBoxInformation(
    String title,
    String imagePath,
    int count,
  ) {
    return InkWell(
      onTap: () {},
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        width: 200,
        height: 91,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.secondaryText,
                  blurRadius: 2,
                  offset: Offset(0, 2))
            ],
            border: Border.all(color: Colors.white)),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                      message: title,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorInformation),
                  CustomText(
                      message: '$count',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorNumberInformation),
                  CustomText(
                      message: getTitle(title),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText)
                ],
              ),
              Image.asset(
                imagePath,
                width: 60,
                height: 60,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _deleteClassDialog(String classID) {
    return showDialog(
        context: context,
        builder: (builder) => AlertDialog(
              backgroundColor: Colors.white,
              title: const CustomText(
                  message: 'Are you want to delete class ?',
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
                    String? check = await API(context).deleteClass(classID);
                    if (check != null && check.isNotEmpty) {
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
                                  setState(() {});
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
                      // await _progressDialog.hide();
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (builder) => AlertDialog(
                            title: CustomText(
                                message: check ?? 'Delete class failed',
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

  // Widget _buildPaginationButtons(int totalPage) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       ElevatedButton(
  //         onPressed: () {
  //           if (page > 1) {
  //             setState(() {
  //               page--;
  //             });
  //           }
  //         },
  //         child: Text(
  //           'Previous',
  //           style: TextStyle(
  //             fontSize: 12,
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 10),
  //       CustomText(
  //           message: '$page/${totalPage}',
  //           fontSize: 13,
  //           fontWeight: FontWeight.w500,
  //           color: AppColors.primaryText),
  //       SizedBox(width: 10),
  //       ElevatedButton(
  //         // style: const ButtonStyle(
  //         //   backgroundColor: MaterialStatePropertyAll(Colors.white),
  //         // ),
  //         onPressed: () {
  //           setState(() {
  //             page++;
  //           });
  //         },
  //         child: Text(
  //           'Next',
  //           style: TextStyle(
  //             fontSize: 12,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPaginationButtons(int totalPage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: page > 1
              ? () {
                  setState(() {
                    page--;
                  });
                }
              : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey.withOpacity(0.2);
                }
                return null; // Màu mặc định khi không bị vô hiệu hóa
              },
            ),
          ),
          child: const Text(
            'Previous',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        CustomText(
          message: '$page/$totalPage',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: page < totalPage
              ? () {
                  setState(() {
                    page++;
                  });
                }
              : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey.withOpacity(0.2);
                }
                return null;
              },
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

String getTitle(String title) {
  if (title == 'Classes') {
    return 'Classes';
  } else if (title == 'Students') {
    return 'Students';
  } else {
    return 'Lectuers';
  }
}
