import 'dart:math';

import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomTextField.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/Class.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewLectuer.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/CreateNewStudent.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/ClassTestPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/CourseTestPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/CreateNewClass.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/LectuerTestPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/LectuersPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/NotificationPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/SettingPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/StudentsPage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/StudentTestPage.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

class HomePageTest extends StatefulWidget {
  const HomePageTest({Key? key}) : super(key: key);

  @override
  State<HomePageTest> createState() => _HomePageTestState();
}

class _HomePageTestState extends State<HomePageTest> {
  TextEditingController searchController = TextEditingController();
  bool checkHome = true;
  bool checkNotification = false;
  bool checkLectuers = false;
  bool checkStudents = false;
  bool checkSettings = false;

  OverlayEntry? overlayEntry;

  bool isCollapsedOpen = true;

  void toggleDrawer() {
    setState(() {
      isCollapsedOpen = !isCollapsedOpen;
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
                  onTap: () {},
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
          if (title == 'Lectuers') {
            checkHome = true;
          } else if (title == 'Course') {
            checkNotification = true;
          }  else if (title == 'Students') {
            checkStudents = true;
          } else if (title == 'Classes') {
            checkSettings = true;
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
              height: 5,
            ),
            const CustomText(
                message: 'Main',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText),
            itemHeader('Lectuers', const Icon(Icons.home_outlined), checkHome),

            itemHeader('Course',
                const Icon(Icons.notifications_outlined), checkNotification),
            // const CustomText(
            //     message: 'Manage',
            //     fontSize: 12,
            //     fontWeight: FontWeight.bold,
            //     color: AppColors.secondaryText),

            itemHeader('Students', const Icon(Icons.calendar_month_outlined),
                checkStudents),
            // const CustomText(
            //     message: 'Personal',
            //     fontSize: 12,
            //     fontWeight: FontWeight.bold,
            //     color: AppColors.secondaryText),
            itemHeader(
                'Classes', const Icon(Icons.settings_outlined), checkSettings),
          ],
        ),
      ),
    );
  }

  Widget selectedPage() {
    if (checkHome) {
      return CreateNewClass();
    } else if (checkNotification) {
      // html.window.history.pushState({}, 'Notification', '/Detail/Notification');
      return const CourseTestPage();
    } else if (checkStudents) {
      return const StudentTestPage();
    } else if (checkSettings) {
      return const CreateNewClass();
    } else {
      return CreateNewClass();
    }
  }

  Widget customClass(String className, String typeClass, String group,
      String subGroup, int shiftNumber, String room, String imgPath) {
    return Container(
        width: 380,
        height: 200,
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Container(
                  width: 380,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.asset(
                      imgPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                                message: className,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                CustomText(
                                    message:
                                        'Group: $group - Sub: $subGroup | ',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                                CustomText(
                                    message: 'Type: $typeClass',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                CustomText(
                                    message: 'Shift: $shiftNumber | ',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                                CustomText(
                                    message: 'Room: $room',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ],
                            )
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        iconColor: Colors.white,
                        onSelected: (value) {},
                        itemBuilder: (BuildContext bc) {
                          return const [
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
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 225, right: 10),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person_2_outlined)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.analytics_outlined))
                ],
              ),
            )
          ],
        )));
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

  Container containerHome() {
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
                message: 'Home',
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 250,
              height: 130,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customBoxInformation(
                      'Classes', 'assets/icons/class.png', 1000),
                  const SizedBox(
                    width: 40,
                  ), // Show ben duoi theo class
                  customBoxInformation(
                      'Students', 'assets/icons/student.png', 1000),
                  const SizedBox(
                    width: 40,
                  ), //show ben duoi theo list students
                  customBoxInformation('Lectuers', 'assets/icons/lectuer.png',
                      1000), // show ben duoi theo lsit lectuers
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder(
                future: API().getClassForTeacher('222h333'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data != null) {
                      List<Class>? classes = snapshot.data;
                      // Future.delayed(Duration.zero, () {
                      //   classDataProvider.setAttendanceFormData(classes!);
                      // });
                      return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 2.1,
                                  mainAxisSpacing: 10),
                          itemCount: classes!.length,
                          itemBuilder: (context, index) {
                            Class data = classes[index];
                            var randomBanner = Random().nextInt(3);

                            return InkWell(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (builder) =>
                                //             const DetailPage()));
                              },
                              mouseCursor: SystemMouseCursors.click,
                              child: Container(
                                child: customClass(
                                    data.course.courseName,
                                    data.classType,
                                    data.group,
                                    data.subGroup,
                                    data.shiftNumber,
                                    data.roomNumber,
                                    'assets/images/banner$randomBanner.jpg'),
                              ),
                            );
                          });
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
            ),
          ],
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
