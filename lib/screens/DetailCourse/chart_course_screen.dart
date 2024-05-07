import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:flutter/material.dart';

class ChartInCourseScreen extends StatefulWidget {
  const ChartInCourseScreen({super.key});

  @override
  State<ChartInCourseScreen> createState() => _ChartInCourseScreenState();
}

class _ChartInCourseScreenState extends State<ChartInCourseScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 250,
      height: MediaQuery.of(context).size.height,
      color: Colors.tealAccent,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const CustomText(
                message: 'Chart',
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText),
            const SizedBox(
              height: 10,
            ),
            Container()
          ],
        ),
      ),
    );
  }
}
