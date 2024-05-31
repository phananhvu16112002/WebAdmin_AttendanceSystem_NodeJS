import 'dart:io';
import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:admin_attendancesystem_nodejs/models/semester.dart';
import 'package:admin_attendancesystem_nodejs/services/API.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class PreviewExcel extends StatefulWidget {
  const PreviewExcel({super.key});

  @override
  State<PreviewExcel> createState() => _PreviewExcelState();
}

class _PreviewExcelState extends State<PreviewExcel> {
  List<List<String>> _excelData = [];
  bool _isEditMode = false;
  Map<List<int>, String> _editedCells = {};
  int _index = 1; // Thêm biến để theo dõi số thứ tự
  late ProgressDialog _progressDialog;
  Uint8List? _excelBytes;
  String fileName = '';

  List<Semester> semesters = [];
  String dropdownvalue = '';
  int selectedIndex = 0;
  late Future<List<Semester>> _fetchSemester;

  @override
  void initState() {
    super.initState();
    fetchSemester();
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
      return;
    }
    try {
      _progressDialog.show();
      var response = await API(context).uploadExcelCourses(_excelBytes!);
      print('response: $response');
      if (response!.isNotEmpty) {
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

  Future<void> pickAndReadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      _clearExcelData();
      _index = 1;
      List<int> excelBytes = result.files.single.bytes!;
      var excel = Excel.decodeBytes(excelBytes);

      var table = excel.tables.keys.first;
      var isFirstRow = true;
      for (var row in excel.tables[table]!.rows) {
        if (!isFirstRow) {
          List<String> rowData = [];
          for (var cell in row) {
            rowData.add(cell?.value.toString() ?? '');
          }
          _excelData.add(rowData);
        } else {
          isFirstRow = false;
        }
      }

      setState(() {});
    }
  }

  void _saveEditedCell(int rowIndex, int cellIndex, String newValue) {
    _editedCells[[rowIndex, cellIndex]] = newValue;
  }

  void saveChangesAndExitEditMode() {
    for (var entry in _editedCells.entries) {
      var rowIndex = entry.key[0];
      var cellIndex = entry.key[1];
      _excelData[rowIndex][cellIndex] = entry.value;
    }

    setState(() {
      _isEditMode = false;
      _editedCells.clear();
    });
  }

  Future<void> uploadData() async {
    _exportEditedDataToExcel();
  }

  // void _exportEditedDataToExcel() async {
  //   var excel = Excel.createExcel();
  //   var sheet = excel['Sheet1'];
  //   for (var i = 0; i < _excelData.length; i++) {
  //     for (var j = 0; j < _excelData[i].length; j++) {
  //       if (j == 0) {
  //         sheet
  //             .cell(CellIndex.indexByColumnRow(rowIndex: i, columnIndex: j))
  //             .value = TextCellValue(_index.toString());
  //       } else {
  //         sheet
  //             .cell(CellIndex.indexByColumnRow(rowIndex: i, columnIndex: j))
  //             .value = TextCellValue(_excelData[i][j]);
  //       }
  //     }
  //     _index++;
  //   }

  //   final List<int> excelBytes = excel.encode()!;
  //   const String fileName = 'edited_data.xlsx';

  //   await FileSaver.instance
  //       .saveFile(bytes: Uint8List.fromList(excelBytes), name: fileName);
  // }

  void _exportEditedDataToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    List<String> headers = [
      'TT',
      'Mã MH',
      'Nhóm',
      'Tổ',
      'Môn dạy',
      'Số SV',
      'Thứ',
      'Tuần học',
      'Tiết',
      'Số tiết',
      'Phòng học',
      'Ngày bắt đầu',
      'Ngày kết thúc',
      'Giảng viên',
      'Lớp ngôn ngữ',
      'Link classroom',
      'Ghi chú',
      'Email TDTU'
    ];

    for (var j = 0; j < headers.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: j))
          .value = TextCellValue(headers[j]);
    }

    for (var i = 0; i < _excelData.length; i++) {
      for (var j = 0; j < _excelData[i].length; j++) {
        if (j == 0) {
          sheet
              .cell(CellIndex.indexByColumnRow(rowIndex: i + 1, columnIndex: j))
              .value = TextCellValue((i + 1).toString());
        } else {
          sheet
              .cell(CellIndex.indexByColumnRow(rowIndex: i + 1, columnIndex: j))
              .value = TextCellValue(_excelData[i][j]);
        }
      }
    }

    final List<int> excelBytes = excel.encode()!;
    const String fileName = 'edited_data.xlsx';

    await FileSaver.instance
        .saveFile(bytes: Uint8List.fromList(excelBytes), name: fileName);
  }

  void _clearExcelData() {
    setState(() {
      _excelData.clear();
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
    return Container(
        width: MediaQuery.of(context).size.width - 250,
        height: MediaQuery.of(context).size.height,
        color: AppColors.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          color: Colors.white),
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
                const CustomText(
                    message: 'Upload Class Excel',
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText),
                const SizedBox(
                  height: 10,
                ),
                tableAttendance(),
                const SizedBox(
                  height: 10,
                ),
                _excelData.isEmpty
                    ? Row(
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      AppColors.primaryButton)),
                              onPressed: pickAndReadExcel,
                              child: Text('Read Excel')),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      AppColors.primaryButton)),
                              onPressed: _selectFile,
                              child: Text('Upload to server')),
                        ],
                      )
                    : _isEditMode
                        ? ElevatedButton(
                            onPressed: saveChangesAndExitEditMode,
                            child: Text('OK'))
                        : Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditMode = true;
                                    });
                                  },
                                  child: Text('Edit')),
                              SizedBox(width: 10),
                              ElevatedButton(
                                  onPressed: uploadData, child: Text('Upload')),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: pickAndReadExcel,
                                  child: Text('Upload new excel'))
                            ],
                          ),
              ],
            ),
          ),
        ));
  }

  List<TableRow> generateTableRows() {
    List<TableRow> rows = [];

    int index = 1; // Sử dụng biến địa phương để theo dõi số thứ tự
    for (var rowData in _excelData) {
      List<Widget> cells = [];
      cells.add(_cellData(index.toString())); // Thêm số thứ tự vào đây
      index++; // Tăng số thứ tự cho mỗi dòng
      for (var cellData in rowData) {
        cells.add(_cellData(cellData));
      }
      rows.add(TableRow(children: cells));
    }

    return rows;
  }

  Widget tableAttendance() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40), //tt
          1: FixedColumnWidth(65), //ma mh
          2: FixedColumnWidth(50), //nhom
          3: FixedColumnWidth(40), //to
          4: FixedColumnWidth(100), //mon day
          5: FixedColumnWidth(45), // sosv
          6: FixedColumnWidth(40), //thu
          7: FixedColumnWidth(100), //tuan hoc
          8: FixedColumnWidth(100), //tiet
          9: FixedColumnWidth(70), //sotiet
          10: FixedColumnWidth(80),
          11: FixedColumnWidth(100),
          12: FixedColumnWidth(100),
          13: FixedColumnWidth(100),
          14: FixedColumnWidth(100),
          15: FixedColumnWidth(150),
          16: FixedColumnWidth(100),
          17: FixedColumnWidth(80),
        },
        border: TableBorder.all(color: AppColors.secondaryText),
        children: [
          TableRow(
            children: [
              _cell('TT'),
              _cell('Mã MH'),
              _cell('Nhóm'),
              _cell('Tổ'),
              _cell('Môn dạy'),
              _cell('Số SV'),
              _cell('Thứ'),
              _cell('Tuần học'),
              _cell('Tiết'),
              _cell('Số tiết'),
              _cell('Phòng học'),
              _cell('Ngày bắt đầu'),
              _cell('Ngày kết thúc'),
              _cell('Giảng viên'),
              _cell('Lớp ngôn ngữ'),
              _cell('Link classroom'),
              _cell('Ghi chú'),
              _cell('Email TDTU'),
            ],
          ),
          //------------------------------------------
          for (var i = 0; i < _excelData.length; i++)
            TableRow(children: [
              for (var j = 0; j < _excelData[i].length; j++)
                _isEditMode
                    ? _editableCell(_excelData[i][j], i, j)
                    : _cellData(_excelData[i][j]),
            ]),
        ],
      ),
    );
  }

  Widget _editableCell(String data, int rowIndex, int cellIndex) {
    return Container(
      padding: const EdgeInsets.all(5),
      color: Colors.transparent,
      child: TextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(border: InputBorder.none),
        controller: TextEditingController(text: data),
        onChanged: (newValue) {
          _saveEditedCell(rowIndex, cellIndex, newValue);
        },
      ),
    );
  }

  TableCell _cell(String title) {
    return TableCell(
      child: Container(
          padding: const EdgeInsets.all(5),
          color: const Color(0xff1770f0).withOpacity(0.21),
          child: Center(
            child: CustomText(
                message: title,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          )),
    );
  }

  TableCell _cellData(String data) {
    String formattedDate = data;
    if (data.contains('T00:00:00.000Z')) {
      formattedDate = formatDate(data);
    }
    return TableCell(
      child: Container(
        padding: const EdgeInsets.all(5),
        color: Colors.transparent,
        child: Center(
            child: CustomText(
                message: formattedDate,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black)),
      ),
    );
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }
}
