import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_visionos/page/BuyPage.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 웹빌드 확인
import 'color/Colors.dart';
import 'comm/RequestApi.dart';
import 'comm/constants.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  //이베스트 토큰 발급
  var eBstToken = await getEBSTToken();
  if(eBstToken != null){
    eBstRealServerToken = "${eBstToken.tokenType} ${eBstToken.token}";
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      // color: Color(0x0FDFDFD).withOpacity(0.0),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BuyPage(),
    );
  }
}
