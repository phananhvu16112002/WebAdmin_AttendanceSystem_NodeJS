import 'dart:ui';

import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/screens/Authentication/WelcomePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/HomePage.dart';
import 'package:admin_attendancesystem_nodejs/screens/Home/Test/HomePageTest.dart';
import 'package:admin_attendancesystem_nodejs/screens/Test.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  //Navigator.pushNamed and create a routes in main
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        debugShowCheckedModeBanner: false,
        title: 'Attendance System Admin',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: AppColors.backgroundColor),
          useMaterial3: true,
        ),
        home: const WelcomePage());
  }
}
