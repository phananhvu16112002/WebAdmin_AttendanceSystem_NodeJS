import 'dart:io';
import 'dart:typed_data';

import 'package:admin_attendancesystem_nodejs/common/base/CustomText.dart';
import 'package:admin_attendancesystem_nodejs/common/colors/color.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PreviewStudentExcel extends StatefulWidget {
  const PreviewStudentExcel({super.key});

  @override
  State<PreviewStudentExcel> createState() => _PreviewStudentExcelState();
}

class _PreviewStudentExcelState extends State<PreviewStudentExcel> {
  List<List<String>> _excelData = [];
  List<List<String>> _filteredData = [];
  String _searchKeyword = '';
  bool _isEditMode = false;
  Map<List<int>, String> _editedCells = {};
  int _index = 1;
  int _maxColumns = 12;
  int _currentPage = 0;
  final int _rowsPerPage = 20;

  int getCurrentPage() {
    return _currentPage + 1;
  }

  int getTotalPages() {
    return (_excelData.length / _rowsPerPage).ceil();
  }

  void _filterData() {
    setState(() {
      _filteredData = _excelData.where((row) {
        for (var cell in row) {
          if (cell.toLowerCase().contains(_searchKeyword.toLowerCase())) {
            return true;
          }
        }
        return false;
      }).toList();
    });
  }

//v1
  // Future<void> pickAndReadExcel() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['xlsx', 'xls'],
  //   );

  //   if (result != null) {
  //     _clearExcelData();
  //     _index = 1;
  //     List<int> excelBytes = result.files.single.bytes!;
  //     var excel = Excel.decodeBytes(excelBytes);

  //     var table = excel.tables.keys.first;
  //     var isFirstRow = true;
  //     for (var row in excel.tables[table]!.rows) {
  //       if (!isFirstRow) {
  //         List<String> rowData = [];
  //         for (var cell in row) {
  //           rowData.add(cell?.value.toString() ?? '');
  //         }
  //         _excelData.add(rowData);
  //       } else {
  //         isFirstRow = false;
  //       }
  //     }

  //     _normalizeRowLengths();
  //     setState(() {});
  //   }
  // }

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
          for (var i = 0; i < _maxColumns; i++) {
            rowData.add(row[i]?.value.toString() ?? '');
          }
          _excelData.add(rowData);
        } else {
          isFirstRow = false;
        }
      }

      _normalizeRowLengths();
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

  void _exportEditedDataToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    List<String> headers = [
      'Mã số SV',
      'Họ lót',
      'Tên',
      'Phái',
      'Lớp',
      'Mã MH',
      'Tên MH',
      'Nhóm',
      'Tổ',
      'Tổ TH',
      'Cơ sở MH',
      'Hệ',
      'Email',
    ];

    for (var j = 0; j < headers.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: j))
          .value = TextCellValue(headers[j]);
    }

    for (var i = 0; i < _excelData.length; i++) {
      for (var j = 0; j < _excelData[i].length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: i + 1, columnIndex: j))
            .value = TextCellValue(_excelData[i][j]);
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

  void _normalizeRowLengths() {
    for (var row in _excelData) {
      while (row.length < _maxColumns) {
        row.add('');
      }
    }
  }

  List<List<String>> _getDataForCurrentPage() {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _excelData.sublist(startIndex,
        endIndex > _excelData.length ? _excelData.length : endIndex);
  }

  void _nextPage() {
    setState(() {
      if ((_currentPage + 1) * _rowsPerPage < _excelData.length) {
        _currentPage++;
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
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
              const CustomText(
                  message: 'Upload Class Excel',
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText),
              const SizedBox(
                height: 10,
              ),
              Center(child: tableAttendance()),
              const SizedBox(
                height: 10,
              ),
              _excelData.isEmpty
                  ? ElevatedButton(
                      onPressed: pickAndReadExcel,
                      child: const Text('Read Excel'))
                  : _isEditMode
                      ? ElevatedButton(
                          onPressed: saveChangesAndExitEditMode,
                          child: const Text('OK'))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  _currentPage > 0 ? _previousPage : null,
                              child: const Text('Previous'),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${getCurrentPage()} / ${getTotalPages()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _currentPage < getTotalPages() - 1
                                  ? _nextPage
                                  : null,
                              child: const Text('Next'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditMode = true;
                                  });
                                },
                                child: const Text('Edit')),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                onPressed: uploadData,
                                child: const Text('Upload')),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                onPressed: pickAndReadExcel,
                                child: const Text('Upload new excel'))
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableAttendance() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(100),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
          3: FixedColumnWidth(60),
          4: FixedColumnWidth(150),
          5: FixedColumnWidth(60),
          6: IntrinsicColumnWidth(),
          7: FixedColumnWidth(70),
          8: FixedColumnWidth(70),
          9: FixedColumnWidth(70),
          10: IntrinsicColumnWidth(),
          11: FixedColumnWidth(150),
          12: FixedColumnWidth(200),
        },
        border: TableBorder.all(color: AppColors.secondaryText),
        children: [
          TableRow(
            children: [
              _cell('Mã Số SV'),
              _cell('Họ lót'),
              _cell('Tên'),
              _cell('Phái'),
              _cell('Lớp'),
              _cell('Mã MH'),
              _cell('Tên MH'),
              _cell('Nhóm'),
              _cell('Tổ TH'),
              _cell('Cơ sở MH'),
              _cell('Hệ'),
              _cell('Email'),
            ],
          ),
          for (var row in _getDataForCurrentPage())
            TableRow(children: [
              for (var cell in row)
                _isEditMode
                    ? _editableCell(
                        cell, _excelData.indexOf(row), row.indexOf(cell))
                    : _cellData(cell),
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
        decoration: const InputDecoration(border: InputBorder.none),
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
                color: Colors.black),
          )),
    );
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}
