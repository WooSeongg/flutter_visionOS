import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../comm/constants.dart';

class BuyPageController extends GetxController {
  /// 시세 리스트
  bool isFirst = true;
  var siseList = [].obs;
  // var siseList = <Sise>[].obs;


  /// 통신 플래그
  var isRequest = false.obs;

  /// 통신 플래그 한국투자증권
  var isRequestHkt = false.obs;

  //정렬리스트
  List<String> dropDownList = ['이름(오름차순)', '이름(내림차순)', '금액(높은순)', '금액(낮은순)'];

  var selected =''.obs;

  void setSelected(String value){
    selected.value = value;
  }

  void sortSiseList() {
      switch (selected.value) {
        case '이름(오름차순)':
         siseList.sort((a, b) => (a.jmName ?? '').compareTo(b.jmName ?? ''));
         break;
        case '이름(내림차순)':
          siseList.sort((a, b) => (b.jmName ?? '').compareTo(a.jmName ?? ''));
          break;

        case '금액(높은순)':
      siseList.sort((a, b) => (b.price ?? '').compareTo(a.price ?? ''));
          break;
        case '금액(낮은순)':
          siseList.sort((a, b) => (a.price ?? '').compareTo(b.price ?? ''));
          break;
        default:
          return null;
      }

  }
  /// 종목 코드
  String shCode = '';
  int shCount = 0;
  int shCountHkt = 0;

  /// 테마 히스토리
  var historyList = [].obs;

  /// 리스트 타입
  var listType = 0.obs;

  void updateUI() {
    update();
  }


  void init() {
    isFirst = true;
    siseList.clear();
    selected.value = '';
    isRequest.value = false;

    shCode = '';
    shCount = 0;

    historyList.clear();

    if(platForm == "AOS"||platForm=="IOS"){
      listType.value = 0;
    }
    else{
      listType.value = 1;
    }
  }
}
