import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';

import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class CreateNewClass extends StatefulWidget {
  const CreateNewClass({super.key});

  @override
  State<CreateNewClass> createState() => _CreateAttendanceFormPageState();
}

class _CreateAttendanceFormPageState extends State<CreateNewClass> {
  OverlayEntry? overlayEntry;
  TextEditingController courseIDController = TextEditingController();
  TextEditingController lecturerIDController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController shiftController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController groupController = TextEditingController();
  TextEditingController subGroupController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  late ProgressDialog _progressDialog;
  Uint8List? _excelBytes;
  String fileName = '';
  final formkey = GlobalKey<FormState>();

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

  Future<void> _uploadFile(
      String courseID,
      String teacherID,
      String roomNumber,
      String shiftNumber,
      String startTime,
      String endTime,
      String classType,
      String group,
      String subGroup) async {
    if (_excelBytes == null) {
      // Fluttertoast.showToast(msg: 'Please select a file to upload');
      print('null');
      return;
    }
    try {
      _progressDialog.show();
      var response = await API(context).uploadExcelClasses(
          _excelBytes!,
          courseID,
          teacherID,
          roomNumber,
          shiftNumber,
          startTime,
          endTime,
          classType,
          group,
          subGroup);
      if (response != null && response == 'OK') {
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
      height: 600,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.black.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Center(
                  child: CustomText(
                      message: 'Create New Class',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryButton),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                          buttonName: 'Import File',
                          backgroundColorButton: Colors.white,
                          borderColor: const Color.fromARGB(255, 205, 203, 203),
                          textColor: AppColors.primaryButton,
                          function: _selectFile,
                          height: 20,
                          width: 100,
                          fontSize: 12,
                          colorShadow: Colors.transparent,
                          borderRadius: 5),
                      const SizedBox(
                        width: 5,
                      ),
                      Center(
                        child: _excelBytes != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('File Excel: ${fileName}'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  // CustomButton(
                                  //     buttonName: 'Upload',
                                  //     backgroundColorButton:
                                  //         const Color(0xff2d71b1),
                                  //     borderColor: Colors.white,
                                  //     textColor: Colors.white,
                                  //     function: () => _uploadFile(
                                  //         courseIDController.text,
                                  //         lecturerIDController.text,
                                  //         roomController.text,
                                  //         shiftController.text,
                                  //         startTimeController.text,
                                  //         endTimeController.text,
                                  //         typeController.text,
                                  //         groupController.text,
                                  //         subGroupController.text),
                                  //     height: 20,
                                  //     width: 100,
                                  //     fontSize: 12,
                                  //     colorShadow: Colors.transparent,
                                  //     borderRadius: 5)
                                ],
                              )
                            : const Text(''),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                        message: 'CourseID',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.primaryText),
                    const SizedBox(height: 5),
                    customTextField(
                        450,
                        40,
                        false,
                        courseIDController,
                        TextInputType.text,
                        IconButton(
                            onPressed: null,
                            icon: Icon(Icons.person_2_outlined,
                                color: Colors.black.withOpacity(0.5))),
                        'Ex: 5200033',
                        true)
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
                    lecturerIDController,
                    TextInputType.phone,
                    IconButton(
                        onPressed: null,
                        icon: Icon(Icons.card_membership_outlined,
                            color: Colors.black.withOpacity(0.5))),
                    'Ex: 520H0696',
                    true),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                            message: 'Room',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            200,
                            40,
                            false,
                            roomController,
                            TextInputType.text,
                            IconButton(
                                onPressed: null,
                                icon: Icon(Icons.room_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex:A0505',
                            true)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                            message: 'Shift',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            200,
                            40,
                            false,
                            shiftController,
                            TextInputType.text,
                            IconButton(
                                onPressed: null,
                                icon: Icon(Icons.filter_tilt_shift_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex: 3',
                            true)
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                            message: 'StartTime',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            200,
                            40,
                            false,
                            startTimeController,
                            TextInputType.text,
                            IconButton(
                                onPressed: null,
                                icon: Icon(Icons.lock_clock_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex:11:11:00',
                            true)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                            message: 'EndTime',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            200,
                            40,
                            false,
                            endTimeController,
                            TextInputType.text,
                            IconButton(
                                onPressed: null,
                                icon: Icon(Icons.lock_clock_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex: 15:15:00',
                            true)
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                            message: 'Group',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            200,
                            40,
                            false,
                            groupController,
                            TextInputType.text,
                            IconButton(
                                onPressed: null,
                                icon: Icon(Icons.group_work_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex:10',
                            true)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                            message: 'subGroup',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primaryText),
                        const SizedBox(height: 5),
                        customTextField(
                            200,
                            40,
                            false,
                            subGroupController,
                            TextInputType.text,
                            IconButton(
                                onPressed: null,
                                icon: Icon(Icons.group_work_outlined,
                                    color: Colors.black.withOpacity(0.5))),
                            'Ex: 3',
                            true)
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const CustomText(
                    message: 'Type',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.primaryText),
                const SizedBox(
                  height: 5,
                ),
                customTextField(
                    450,
                    40,
                    false,
                    typeController,
                    TextInputType.text,
                    IconButton(
                        onPressed: null,
                        icon: Icon(Icons.group_work_outlined,
                            color: Colors.black.withOpacity(0.5))),
                    'Ex: thesis',
                    true),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: CustomButton(
                      buttonName: 'Create',
                      backgroundColorButton: AppColors.primaryButton,
                      borderColor: Colors.white,
                      textColor: Colors.white,
                      function: () {
                        if (formkey.currentState!.validate()) {
                          _uploadFile(
                              courseIDController.text,
                              lecturerIDController.text,
                              roomController.text,
                              shiftController.text,
                              startTimeController.text,
                              endTimeController.text,
                              typeController.text,
                              groupController.text,
                              subGroupController.text);
                        }
                      },
                      height: 50,
                      width: 250,
                      fontSize: 20,
                      colorShadow: Colors.transparent,
                      borderRadius: 10),
                )
              ],
            ),
          ),
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
