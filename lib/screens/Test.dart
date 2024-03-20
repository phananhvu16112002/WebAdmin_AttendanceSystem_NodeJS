// import 'dart:typed_data';

// import 'package:admin_attendancesystem_nodejs/services/API.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;

// class TestPage extends StatefulWidget {
//   @override
//   _TestPageState createState() => _TestPageState();
// }

// class _TestPageState extends State<TestPage> {
//   Uint8List? _excelBytes;

//   Future<void> _selectFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx', 'xls'],
//     );

//     if (result != null) {
//       setState(() {
//         _excelBytes = result.files.single.bytes;
//       });
//     }
//   }

//   Future<void> _uploadFile() async {
//     if (_excelBytes == null) {
//       Fluttertoast.showToast(msg: 'Please select a file to upload');
//       return;
//     }

//     try {
//       var response = await API().uploadExcelClasses(_excelBytes!);

//       if (response != null && response == 'OK') {
//         print('ok');
//       } else {
//         print('failed');
//       }
//     } catch (e) {
//       print('error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Excel Upload'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: _selectFile,
//               child: Text('Select Excel File'),
//             ),
//             SizedBox(height: 20),
//             _excelBytes != null
//                 ? Text('Selected File: Excel File')
//                 : Container(),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _uploadFile,
//               child: Text('Upload Excel File'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
