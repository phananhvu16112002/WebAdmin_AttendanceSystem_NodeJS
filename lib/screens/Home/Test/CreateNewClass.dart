import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/common/base/CustomButton.dart';
import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';

import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/CoursePage/CourseModel.dart';
import 'package:admin_attendancesystem_nodejs/providers/selected_detail_provider.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class CreateNewClass extends StatefulWidget {
  const CreateNewClass({super.key, required this.courseModel});
  final CourseModel courseModel;

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

  var items = [
    'Theory',
    'Laboratory',
  ];
  String dropdownvalue = 'Theory';
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
  TimeOfDay? timeStart;
  TimeOfDay? timeEnd;
  bool isStartTimeSelected = false;
  bool isEndTimeSelected = false;

  Future<void> selectTimeStart(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        barrierColor: Colors.black.withOpacity(0.2),
        helpText: 'Select Start Time For Attendance',
        builder: (context, child) {
          return Theme(
            data: ThemeData.light(useMaterial3: false)
                .copyWith(primaryColor: Colors.white),
            child: child!,
          );
        },
        context: context,
        initialTime: timeStart ?? TimeOfDay.now());
    if (time != null && time != timeStart) {
      setState(() {
        timeStart = time;
        isStartTimeSelected = true;
        startTimeController.text =
            formatTime(formatTimeOfDate(timeStart!).toString());
        print('TimeStart: ${formatTimeOfDate(timeStart!)}');
        checkDuplicateTime();
      });
    }
  }

  Future<void> selectTimeEnd(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        barrierColor: Colors.black.withOpacity(0.2),
        helpText: 'Select Start Time For Attendance',
        builder: (context, child) {
          return Theme(
            data: ThemeData.light(useMaterial3: false)
                .copyWith(primaryColor: Colors.white),
            child: child!,
          );
        },
        context: context,
        initialTime: timeEnd ?? TimeOfDay.now());
    if (time != null && time != timeEnd) {
      setState(() {
        timeEnd = time;
        isEndTimeSelected = true;
        endTimeController.text =
            formatTime(formatTimeOfDate(timeEnd!).toString());
        print('TimeEnd: ${formatTimeOfDate(timeEnd!)}');
        checkDuplicateTime();
      });
    }
  }

  bool checkDuplicateTime() {
    if (isStartTimeSelected && isEndTimeSelected) {
      if (timeStart!.hour > timeEnd!.hour ||
          (timeStart!.hour == timeEnd!.hour &&
              timeStart!.minute >= timeEnd!.minute)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Error'),
              content: const Text('Start Time must be before End Time.'),
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
      }
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    courseIDController.text = widget.courseModel.courseID;
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
      String subGroup,
      SelectedPageProvider selectedPageProvider) async {
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
                      // setState(() {
                      //   fileName = '';
                      // });
                      selectedPageProvider.setCheckHome(true);
                      selectedPageProvider.setCheckChart(false);
                      selectedPageProvider.setCheckCreateClass(false);
                      // Navigator.of(context).pop();
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
    final selectedPageProvider = Provider.of<SelectedPageProvider>(context);
    return Container(
      width: MediaQuery.of(context).size.width - 250,
      height: MediaQuery.of(context).size.height,
      child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [infoForm(context, selectedPageProvider)],
          )),
    );
  }

  Widget infoForm(
      BuildContext context, SelectedPageProvider selectedPageProvider) {
    return Container(
      width: (MediaQuery.of(context).size.width - 250) / 2 - 20,
      // height: 600,
      padding: EdgeInsets.symmetric(vertical: 10),
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
                          height: 30,
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
                        double.infinity,
                        40,
                        true,
                        courseIDController,
                        TextInputType.text,
                        IconButton(
                            onPressed: null,
                            icon: Icon(Icons.person_2_outlined,
                                color: Colors.black.withOpacity(0.5))),
                        'Ex: 5200033',
                        true, (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is not empty';
                      }
                      return null;
                    })
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
                    double.infinity,
                    40,
                    false,
                    lecturerIDController,
                    TextInputType.phone,
                    IconButton(
                        onPressed: null,
                        icon: Icon(Icons.card_membership_outlined,
                            color: Colors.black.withOpacity(0.5))),
                    'Ex: 520H0696',
                    true, (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is not empty';
                  }
                  return null;
                }),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              message: 'Room',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                              null,
                              40,
                              false,
                              roomController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.room_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex:A0505',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          })
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              message: 'Shift',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                              null,
                              40,
                              false,
                              shiftController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.filter_tilt_shift_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex: 3',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          })
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              message: 'StartTime',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                              null,
                              40,
                              true,
                              startTimeController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: () => selectTimeStart(context),
                                  icon: Icon(Icons.watch_later_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex:11:11:00',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          })
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              message: 'EndTime',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                              null,
                              40,
                              true,
                              endTimeController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: () => selectTimeEnd(context),
                                  icon: Icon(Icons.lock_clock_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex: 15:15:00',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          })
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              message: 'Group',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                              null,
                              40,
                              false,
                              groupController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.group_work_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex:10',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          })
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              message: 'subGroup',
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.primaryText),
                          const SizedBox(height: 5),
                          customTextField(
                              null,
                              40,
                              false,
                              subGroupController,
                              TextInputType.text,
                              IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.group_work_outlined,
                                      color: Colors.black.withOpacity(0.5))),
                              'Ex: 3',
                              true, (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is not empty';
                            }
                            return null;
                          })
                        ],
                      ),
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
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1,
                      color: AppColors.primaryText.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DropdownButton(
                            underline: Container(),
                            value: dropdownvalue,
                            icon: const Icon(null), // Loại bỏ icon ở đây
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: SizedBox(
                                  // width: 450,
                                  child: Text(
                                    items,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryText
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedIndex = items.indexOf(newValue!);
                                dropdownvalue = newValue;
                                typeController.text = newValue;
                              });
                              print("Selected index: $selectedIndex");
                            },
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_outlined),
                      ],
                    ),
                  ),
                ),
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
                        bool check = checkDuplicateTime();
                        if (formkey.currentState!.validate() &&
                            check &&
                            _excelBytes != null) {
                          _uploadFile(
                              courseIDController.text,
                              lecturerIDController.text,
                              roomController.text,
                              shiftController.text,
                              formatTimeOfDate(timeStart!).toString(),
                              formatTimeOfDate(timeEnd!).toString(),
                              typeController.text,
                              groupController.text,
                              subGroupController.text,
                              selectedPageProvider);
                        } else {
                          if (courseIDController.text.isEmpty) {
                            _customDialog(context, 'Field Course',
                                "CourseID is required");
                          } else if (lecturerIDController.text.isEmpty) {
                            _customDialog(context, 'Field Lecturer',
                                "LecturerID is required");
                          } else if (roomController.text.isEmpty) {
                            _customDialog(
                                context, 'Field Room', "Room is required");
                          } else if (_excelBytes == null) {
                            _customDialog(context, 'Field excel students',
                                "Excel students is required");
                          } else if (shiftController.text.isEmpty) {
                            _customDialog(
                                context, 'Field shift', "Shift is required");
                          } else if (startTimeController.text.isEmpty) {
                            _customDialog(context, 'Field StartTime',
                                "StartTime is required");
                          } else if (endTimeController.text.isEmpty) {
                            _customDialog(context, 'Field EndTime',
                                "EndTime is required");
                          } else if (groupController.text.isEmpty) {
                            _customDialog(
                                context, 'Field Group', "Group is required");
                          } else if (subGroupController.text.isEmpty) {
                            _customDialog(context, 'Field SubGroup',
                                "SubGroup is required");
                          }
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

  Widget customTextField(
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
}
