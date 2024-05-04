import 'package:flutter/material.dart';

class SelectedPageProvider with ChangeNotifier {
  bool checkHome = true;
  bool checkChart = false;
  bool checkCreateClass = false;

  bool get getCheckHome => checkHome;
  bool get getcheckChart => checkChart;
  bool get getcheckCreateClass => checkCreateClass;

  void setCheckHome(bool check) {
    checkHome = check;
    notifyListeners();
  }

  void setCheckChart(bool check) {
    checkChart = check;
    notifyListeners();
  }

  void setCheckCreateClass(bool check) {
    checkCreateClass = check;
    notifyListeners();
  }
}
