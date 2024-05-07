import 'dart:math';

import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomTextField.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/Class.dart';
import 'package:admin_attendancesystem_nodejs/models/CoursePage/CourseModel.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/ClassModel.dart';
import 'package:admin_attendancesystem_nodejs/models/HomePage/class_data_model.dart';
import 'package:admin_attendancesystem_nodejs/providers/selected_detail_provider.dart';
import 'package:admin_attendancesystem_nodejs/screens/Authentication/WelcomePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/DetailClass/detail_class.dart';
import 'package:admin_attendancesystem_nodejs/screens/DetailCourse/chart_course_screen.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CoursePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewLectuer.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewStudent.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/HomePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewClass.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/LectuerTestPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/LectuersPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/NotificationPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/SettingPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/StudentsPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Test.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:admin_attendancesystem_nodejs/services/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

class DetailCourseScreen extends StatefulWidget {
  const DetailCourseScreen({super.key, required this.courseModel});
  final CourseModel courseModel;

  @override
  State<DetailCourseScreen> createState() => _DetailCourseScreenState();
}

class _DetailCourseScreenState extends State<DetailCourseScreen> {
  TextEditingController searchController = TextEditingController();
  bool checkHome = true;
  bool checkChart = false;
  bool checkCreateClass = false;

  OverlayEntry? overlayEntry;
  int page = 1;

  bool isCollapsedOpen = true;
  SecureStorage storage = SecureStorage();

  void toggleDrawer() {
    setState(() {
      isCollapsedOpen = !isCollapsedOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPageProvider = Provider.of<SelectedPageProvider>(context);
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCollapsedOpen ? 250 : 70,
              child: isCollapsedOpen
                  ? leftHeader(selectedPageProvider)
                  : collapsedSideBar(),
            ),
            Expanded(
              child: selectedPage(selectedPageProvider),
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
              const Icon(Icons.pie_chart_outline),
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

  Widget itemHeader(String title, Icon icon, bool check,
      SelectedPageProvider selectedPageProvider) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPageProvider.setCheckHome(false);
          selectedPageProvider.setCheckChart(false);
          // checkHome = false;
          // checkChart = false;
          if (title == 'Manage Class') {
            // checkHome = true;
            selectedPageProvider.setCheckHome(true);
          } else if (title == 'Dashboard') {
            // checkChart = true;
            selectedPageProvider.setCheckChart(true);
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

  Widget leftHeader(SelectedPageProvider selectedPageProvider) {
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
            Center(
              child: CustomButton(
                buttonName: 'Create New Class',
                backgroundColorButton: checkCreateClass
                    ? const Color.fromARGB(62, 226, 240, 253)
                    : Colors.transparent,
                borderColor: Colors.black,
                textColor: AppColors.textName,
                function: () {
                  setState(() {
                    selectedPageProvider.setCheckHome(false);
                    selectedPageProvider.setCheckChart(false);
                    selectedPageProvider.setCheckCreateClass(true);
                  });
                },
                height: 40,
                width: 200,
                fontSize: 12,
                colorShadow: Colors.transparent,
                borderRadius: 5,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const CustomText(
                message: 'Main',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Manage Class', const Icon(Icons.home_outlined),
                selectedPageProvider.getCheckHome, selectedPageProvider),
            const CustomText(
                message: 'Analyze',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Dashboard', const Icon(Icons.notifications_outlined),
                selectedPageProvider.getcheckChart, selectedPageProvider),
          ],
        ),
      ),
    );
  }

  Widget selectedPage(SelectedPageProvider selectedPageProvider) {
    if (selectedPageProvider.getCheckHome) {
      return containerHome();
    } else if (selectedPageProvider.getcheckChart) {
      // html..history.pushState({}, 'Notification', '/Detail/Notification');
      return ChartInCourseScreen();
    } else if (selectedPageProvider.getcheckCreateClass) {
      return CreateNewClass(
        courseModel: widget.courseModel,
      );
    } else {
      return containerHome();
    }
  }

  Widget customClass(
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
                        style: TextStyle(
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
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Type: $typeClass',
                            style: TextStyle(
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
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Room: $room',
                            style: TextStyle(
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
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {},
                    itemBuilder: (BuildContext bc) {
                      return [
                        PopupMenuItem(
                          value: '/repository',
                          child: Text("Repository"),
                        ),
                        PopupMenuItem(
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
                icon: Icon(Icons.person_2_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.document_scanner_outlined),
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
                CustomText(
                    message:
                        'Course: ${widget.courseModel.courseName} - ID:${widget.courseModel.courseID} ',
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText),
                const SizedBox(
                  height: 15,
                ),
                FutureBuilder(
                  future: API(context).getClassesInsideCourse(
                      widget.courseModel.courseID ?? '', page),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        ClassData? classData = snapshot.data;
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
                                itemCount: classData?.classes?.length,
                                itemBuilder: (context, index) {
                                  ClassModel? data =
                                      classData?.classes?[index] ??
                                          ClassModel();
                                  var randomBanner = Random().nextInt(3);

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) => DetailPage(
                                                    classModel: data,
                                                  )));
                                    },
                                    mouseCursor: SystemMouseCursors.click,
                                    child: customClass(
                                        data.course?.courseName ?? '',
                                        data.classType ?? '',
                                        data.group ?? '',
                                        data.subGroup ?? '',
                                        data.shiftNumber ?? 0,
                                        data.roomNumber ?? '',
                                        'assets/images/banner$randomBanner.jpg',
                                        data.teacher?.teacherName ?? '',
                                        data.teacher?.teacherID ?? '',
                                        550),
                                  );
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildPaginationButtons(classData?.totalPage ?? 1)
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
