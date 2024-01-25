// import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
//
// import '../comm/constants.dart';
//
// class StoreUtils {
//   static final StoreUtils _instance = StoreUtils._();
//
//   static StoreUtils get instance => _instance;
//
//   // late SharedPreferences _box;
//
//   StoreUtils._();
//
//   Future<void> init() async {
//     // _box = await SharedPreferences.getInstance();
//   }
//
//
//   bool getisDemo() {
//     // return pref.getBool('isDemo') ?? false;
//   }
//
//   Future<void> checkMode(String mode) async {
//     await init();
//
//     if (_box != null) {
//       var checkCurrentMode = _box.getString('mode');
//
//       if (checkCurrentMode == null || checkCurrentMode != mode) {
//         _box.setString('mode', mode);
//       }
//     } else {
//       print("Error: _box is null");
//     }
//   }
//
//   String getCurrentMode() {
//     return _box.getString('mode') ?? "light";
//   }
//
//   ThemeData getTheme() {
//     String currentMode = getCurrentMode();
//     return currentMode == "light"
//         ? ThemeData(primarySwatch: Colors.blue)
//         : ThemeData(primarySwatch: Colors.red);
//   }
//
//   Future<void> setAlarm(bool bool) async {
//     await init();
//
//     var getAlarm = _box.getBool('alarm');
//
//     if (getAlarm == null || getAlarm == true) {
//       _box.setBool('alarm', false);
//     } else {
//       _box.setBool('alarm', true);
//     }
//   }
//
//   bool getAlarm() {
//     return _box.getBool('alarm') ?? false;
//   }
//
//   Future<void> setBio(bool bool) async {
//     await init();
//       _box.setBool('biocheck', bool);
//
//   }
//
//   bool getBio() {
//     return _box.getBool('biocheck') ?? false;
//   }
//
//   Future<void> setAutoLogin(bool bool) async {
//     await init();
//
//     var getAutoLogin = _box.getBool('autoLogin');
//
//     // 오토로그인 저장 된게  저장된 값이 없거나 거짓이면  true 로 바꿔주고
//     if (getAutoLogin == null) {
//       _box.setBool('autoLogin', true);
//     } else if (getAutoLogin == false) {
//       _box.setBool('autoLogin', true);
//     } else if (bool == false) {
//       _box.setBool('autoLogin', false);
//     }
//   }
//
//   bool getAutoLogin() {
//     return _box.getBool('autoLogin') ?? false;
//   }
// }
