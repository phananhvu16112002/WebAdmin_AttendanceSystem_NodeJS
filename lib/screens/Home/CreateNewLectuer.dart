import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomTextField.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateNewLectuer extends StatefulWidget {
  const CreateNewLectuer({super.key});

  @override
  State<CreateNewLectuer> createState() => _CreateAttendanceFormPageState();
}

class _CreateAttendanceFormPageState extends State<CreateNewLectuer> {
  TextEditingController searchController = TextEditingController();
  OverlayEntry? overlayEntry;
  TextEditingController fistnameController = TextEditingController();
  TextEditingController lastnameControlelr = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController lectuerIDController = TextEditingController();
  String dropdownMenu = 'None';
  List<String> faculties = [
    'None',
    'Information Technology',
    'Business administration',
    'Design Furniture',
    'Accounting',
    'Biotechnology',
    'Marketing'
  ];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 250,
      height: MediaQuery.of(context).size.height,
      child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [infoForm(context)],
          )),
    );
  }

  Widget infoForm(
    BuildContext context,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 250) / 2 - 20,
      height: 550,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.black.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: CustomText(
                  message: 'Create New Lectuer',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryButton),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                        message: 'Firstname',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.primaryText),
                    const SizedBox(height: 5),
                    customTextField(
                        200,
                        40,
                        false,
                        fistnameController,
                        TextInputType.text,
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.person_2_outlined,
                                color: Colors.black.withOpacity(0.5))),
                        'Ex: Anh Vu',
                        true)
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                        message: 'Lastname',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.primaryText),
                    const SizedBox(height: 5),
                    customTextField(
                        200,
                        40,
                        false,
                        lastnameControlelr,
                        TextInputType.text,
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.person_2_outlined,
                                color: Colors.black.withOpacity(0.5))),
                        'Ex: Phan',
                        true)
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const CustomText(
                message: 'LectuerID',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.primaryText),
            const SizedBox(height: 5),
            customTextField(
                450,
                40,
                false,
                lectuerIDController,
                TextInputType.phone,
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.card_membership_outlined,
                        color: Colors.blue)),
                'Ex: 520H0696',
                true),
            const SizedBox(
              height: 10,
            ),
            const CustomText(
                message: 'Email',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.primaryText),
            const SizedBox(height: 5),
            customTextField(
                450,
                40,
                false,
                emailController,
                TextInputType.phone,
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.email_outlined,
                        color: Color.fromARGB(255, 230, 107, 98))),
                'Ex: tuankiet@tdtu.edu.vn',
                true),
            const SizedBox(
              height: 10,
            ),
            const CustomText(
                message: 'Phone Number',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.primaryText),
            const SizedBox(height: 5),
            customTextField(
                450,
                40,
                false,
                phonenumberController,
                TextInputType.phone,
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_android_outlined,
                        color: Colors.green)),
                'Ex: 082922...',
                true),
            const SizedBox(
              height: 10,
            ),
            const CustomText(
                message: 'Faculty',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.primaryText),
            const SizedBox(
              height: 5,
            ),
            Container(
              width: 560,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    width: 1, color: AppColors.primaryText.withOpacity(0.2)),
              ),
              child: DropdownButton(
                menuMaxHeight: 150,
                underline: Container(),
                value: dropdownMenu,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primaryText.withOpacity(0.5),
                ),
                items: faculties.map((String items) {
                  return DropdownMenuItem(
                      value: items,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          width: 380,
                          child: Text(
                            items,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryText.withOpacity(0.5),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedIndex = faculties.indexOf(newValue!);
                    dropdownMenu = newValue;
                  });
                  print("Selected index: $selectedIndex");
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: CustomButton(
                  buttonName: 'Create',
                  backgroundColorButton: AppColors.primaryButton,
                  borderColor: Colors.white,
                  textColor: Colors.white,
                  function: () {},
                  height: 50,
                  width: 250,
                  fontSize: 20,
                  colorShadow: Colors.transparent,
                  borderRadius: 10),
            )
          ],
        ),
      ),
    );
  }

  Widget customTextField(
      double width,
      double height,
      bool readOnly,
      TextEditingController controller,
      TextInputType textInputType,
      IconButton iconSuffix,
      String hintText,
      bool enabled) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: Colors.black.withOpacity(0.2)),
              left: BorderSide(color: Colors.black.withOpacity(0.2)),
              right: BorderSide(color: Colors.black.withOpacity(0.2)),
              bottom: BorderSide(color: Colors.black.withOpacity(0.2))),
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
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(width: 1, color: Colors.transparent)),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              borderSide: BorderSide(width: 1, color: AppColors.primaryButton),
            )),
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
}
