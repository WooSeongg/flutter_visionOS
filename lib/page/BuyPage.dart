import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_visionos/page/BuyPageController.dart';
// import 'package:ebest/pages/SearchPage.dart';
// import 'package:ebest/utils/LogCat.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_visionos/comm/constants.dart';
// import 'package:ebest/data/Sise.dart';
// import 'package:ebest/pages/ItemInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../comm/constants.dart';
import '../data/FHKST01010100.dart';
import '../data/Sise.dart';
import '../data/TR8407.dart';
import '../number/AnimatedFlipCounter.dart';
import 'BuyPageController.dart';

/// //////////////////////////
/// 살래화면 (매수리스트)   ///
/// //////////////////////////
class BuyPage extends StatelessWidget {
  /// 스테이트
  final BuyPageController _controller = Get.put(BuyPageController());

  /// 재조회 컨트롤러
  final RefreshController gridRefreshController = RefreshController();
  final RefreshController emptyRefreshController = RefreshController();

  /// 포맷팅
  final NumberFormat format = new NumberFormat("###,###");

  /// 텍스트 필드 컨트롤러
  final TextEditingController _editingController = new TextEditingController();

  ///웹소켓 연결
  WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('ws://ops.koreainvestment.com:31000/tryitout/H0STCNT0'));

  //테마
  final isDarkMode = Get.isDarkMode;

  /// 생성자
  BuyPage() {
    _controller.init();

    /// 리스트 타입 불러오기
    _loadListType();

    for (int i = 0; i < jmCodes.length; i++) {
      if (i < 50) {
        _controller.shCode += jmCodes[i];
        _controller.shCount = i + 1;
      } else {
        break;
      }
    }
  }

  @override
  Future<void> initializeReal() async {
    _controller.isRequest.value = true;
    requestHOSTCNTO();
  }

  @override
  void releaseReal() {
    //한투 API 실시간 현재가 닫기
    stopHOSTCNTO();
  }

  @override
  Widget build(BuildContext context) {
    if(platForm == "AOS"||platForm=="IOS"){
      _controller.listType.value = 0;
    }
    else{
      _controller.listType.value = 1;
    }
    return Scaffold(
        // backgroundColor: Color(0x0ffffff).withOpacity(0.3),
        body: SafeArea(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //종목검색 영역
                Container(
                  padding: EdgeInsets.fromLTRB(15, 10, 0, 0),
                  height: 60,
                  // color: Color(0x0FFFFFF).withOpacity(0.1),
                  child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: mMediumGray,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 11),
                                      child: TextField(
                                        controller: _editingController,
                                        decoration: InputDecoration(
                                          hintText: "종목검색",
                                          hintStyle:
                                          TextStyle(fontSize: textSizeNormal),
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.transparent)),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.transparent)),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.transparent)),
                                        ),
                                        style: TextStyle(fontSize: textSizeNormal),
                                        autofocus: false,
                                        enabled: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _goSearchPage('', '');
                              },
                            ),
                          ),
                          Obx(() {
                            Icon icon = Icon(Icons.access_time_filled);
                            if (_controller.listType.value == KEY_GRID) {
                              icon = Icon(Icons.dashboard);
                            } else if (_controller.listType.value == KEY_LIST1) {
                              icon = Icon(Icons.format_align_justify);
                            }

                            return Container(
                              child: platForm == "AOS" || platForm == "IOS"
                                  ? IconButton(
                                icon: icon,
                                onPressed: () {
                                  _saveListType();
                                },
                              )
                                  : SizedBox(width: 40, height: 40),
                            );
                          }),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              // color: Colors.black,
                            ),
                            onPressed: () {
                              _goJmEditPage();
                            },
                          )
                        ],
                      )),
                ),

                ///필터적용
                Container(
                  height: 60,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 15),
                  child: Obx(() => DropdownButton(
                    hint : Text('필터적용'),
                    alignment: Alignment.centerRight,
                    borderRadius: BorderRadius.circular(20),
                    onChanged: (dynamic newValue) async {
                      await Future.delayed(Duration.zero);
                      _controller.setSelected(newValue as String);

                      _controller.sortSiseList();
                    },
                    value: _controller.selected.value.isEmpty
                        ? null
                        : _controller.selected.value,
                    items: _controller.dropDownList.map((String item) {
                      IconData? icon;
                      switch (item) {
                        case '이름(오름차순)':
                          icon = Icons.sort_by_alpha;
                          break;
                        case '이름(내림차순)':
                          icon = Icons.sort_by_alpha_sharp;
                          break;
                        case '금액(높은순)':
                          icon = Icons.attach_money;
                          break;
                        case '금액(낮은순)':
                          icon = Icons.money_off;
                          break;
                        default:
                          icon = null;
                      }

                      return DropdownMenuItem(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (icon != null) Icon(icon),
                            if (icon != null) SizedBox(width: 8),
                            // 아이콘과 텍스트 사이의 간격 조절
                            Text(item,
                                style: TextStyle(fontSize: textSizeSmall)),
                          ],
                        ),
                        value: item,
                      );
                    }).toList(),
                    underline: Container(),
                  )),
                ),

                //리스트 그리드
                Expanded(
                  child: FutureBuilder(
                    future: fetchData(),
                    builder: (context, snapshot) {
                      //로딩 중 애니메이션
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        );
                        //에러 발생
                      } else if (snapshot.hasError) {

                        return Center(
                          child: Text('Error loading data'),
                        );
                      }
                      else {
                        return Obx(() {
                          if (_controller.siseList.length == 0 || _controller.isRequest.value) {
                            return SmartRefresher(
                                controller: emptyRefreshController,
                                header: WaterDropMaterialHeader(
                                  backgroundColor: isDarkMode ? mMediumGray : Colors.red,
                                  color: Colors.white,
                                ),
                                onRefresh: () async {
                                  await fetchData();
                                  emptyRefreshController.refreshCompleted();
                                },
                                child: Center(
                                  child: AutoSizeText(
                                    '데이터가 없습니다.',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: textSizeSmall2),
                                  ),
                                ),
                              );
                          } else {
                            return AnimationLimiter(
                              child: SmartRefresher(
                                controller: gridRefreshController,
                                header: WaterDropMaterialHeader(
                                  backgroundColor: isDarkMode ? mMediumGray : Colors.red,
                                  color: Colors.white,
                                ),
                                onRefresh: () async {
                                  await fetchData();
                                  gridRefreshController.refreshCompleted();
                                },
                                child: _controller.listType.value == KEY_GRID
                                    ? listGrid(columnCount:3, isRefresh: _controller.isRequest.value)
                                    : listList()
                                // _controller.isRequest.value? Container(height: 300, width:100, color:Colors.green): _controller.listType.value == KEY_GRID? listGrid(columnCount:3): listList()
                                // Container(child: Obx((){
                                //   if(_controller.isRequest.value){
                                //     return Container(height: 300, width:100, color:Colors.green);
                                //   }
                                //   else{
                                //     // return Container(height: 100, width:500, color:Colors.pink);
                                //     if(_controller.listType.value == KEY_GRID){
                                //       return listGrid(columnCount:3); // 그리드 형식
                                //     }
                                //     else{
                                //       return listList();
                                //     }
                                //   }
                                // }))
                              ),
                            );
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
  Future<void> fetchData () async {
    try {
      _controller.isRequest.value = true; // Set loading state

      await requestTR8407();
    } finally {
      _controller.isRequest.value = false; // Reset loading state
    }
  }
  /// 그리드 아이템 생성
  Widget setGridItem(BuildContext context, int index) {
    var item = _controller.siseList[index];

    Color cardColor = isDarkMode ? Colors.black54 : Colors.black12;
    Color textColor = isDarkMode ? Color(0xFFDCDCDC) : Colors.black;

    if (!item.diff.contains('.')) {
      item.diff = item.diff.replaceFirstMapped(
          RegExp(".{2}\$"), (match) => ".${match.group(0)}");
    }

    double price = double.parse(item.price);
    double change = double.parse(item.change);
    double diff = double.parse(item.diff);
    var format = new NumberFormat("###,###");

    String txtChange = "";
    if (diff != 0) {
      if (diff < 0) {
        if (!isDarkMode) {
          cardColor = Colors.blue.withAlpha(25);
          textColor = Colors.blue;
        } else if (isDarkMode) {
          cardColor = Color(0Xff242424);
          textColor = Colors.white;
        }
        txtChange += "▼";
      } else {
        if (!isDarkMode) {
          cardColor = Colors.red.withAlpha(25);
          textColor = Colors.red;
        } else if (isDarkMode) {
          textColor = Colors.white;
          cardColor = Color(0Xff4d4d4d);
        }
        txtChange += "▲";
      }
    }

    txtChange += " ${format.format(change)} (${diff.toString()}%)";

    return InkWell(
      child: Card(
          elevation: 0,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  item.jmName,
                  style: TextStyle(fontSize: textSizeNormal),
                  maxLines: 1,
                  minFontSize: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                AnimatedFlipCounter(
                  duration: Duration(milliseconds: animationDuration),
                  value: price,
                  thousandSeparator: ',',
                  textStyle: TextStyle(
                    fontSize: textSizeTitle,
                    color: textColor,
                  ),
                ),
                AutoSizeText(
                  txtChange,
                  style: TextStyle(fontSize: textSizeSmall, color: textColor),
                  maxLines: 1,
                ),
              ],
            ),
          )),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _goInfoPage(index);
      },
    );
  }
  /// eBEST 시세 통신 요청
  requestTR8407() async {

    // if (!_controller.isRequest.value) {
    if (true) {
      _controller.isRequest.value = true;
      if (_controller.shCode == "") {
        for (int i = 0; i < jmCodes.length; i++) {
          if (i < 50) {
            _controller.shCode += jmCodes[i];
            _controller.shCountHkt = i + 1;
          } else {
            break;
          }
        }
      }
      TR8407Output? jsonData;
      try {
        // for (int i = 0; i < jmCodes.length; i++) {
        jsonData = await TR8407().fetchTR8407();

        if (jsonData?.block1 != null) {
          var block1 = jsonData?.block1;
          _controller.siseList.clear();

          setMakeResponse(block1!);
          _controller.isRequest.value = false;
        }
        // TR조회 후 실시간 웹소켓 연결
        // Future.delayed(Duration(seconds: 1), () =>
        //     requestHOSTCNTO());
      } catch (e) {
        print(e);
      }
    }
  }
  //
  // /// 한국투자증권 시세 통신 요청
  // requestFHKST01010100() async {
  //
  //   // if (!_controller.isRequest.value) {
  //   if (true) {
  //     _controller.isRequest.value = true;
  //     if (_controller.shCode == "") {
  //       for (int i = 0; i < jmCodes.length; i++) {
  //         if (i < 50) {
  //           _controller.shCode += jmCodes[i];
  //           _controller.shCountHkt = i + 1;
  //         } else {
  //           break;
  //         }
  //       }
  //     }
  //     var jsonData;
  //     try {
  //       List<dynamic> data = [];
  //       // for (int i = 0; i < jmCodes.length; i++) {
  //       jsonData = await FHKST01010100().fetchFHKST01010100(jmCodes);
  //       if (jsonData != null || jsonData != false) {
  //         data = jsonData;
  //       }
  //       // }
  //       if (jsonData != null) {
  //         //setMakeResponse(data);
  //         _controller.isRequest.value = false;
  //       }
  //       // TR조회 후 실시간 웹소켓 연결
  //       Future.delayed(Duration(seconds: 1), () =>
  //            requestHOSTCNTO());
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  // }


  //한투 API 리얼 데이터
  void onRealDataEbst(dynamic message) async {
    try {
      //받은 데이터
      Map<String, dynamic> jmData = {};
      // 서버로부터 수신된 데이터 처리
      var receivedData = jsonDecode(message.toString());
      if (receivedData['header']['tr_id'] != "PINGPONG") {
        // JSON 디코딩
        // var decodedMessage = jsonDecode(message);
        List<String> decodedMessage = message.split('|');

        // 필요에 따라 Map에 저장
        Map<String, dynamic> resultMap = {
          'success': decodedMessage[0],
          'tr_id': decodedMessage[1],
          'code': decodedMessage[2],
          'data': decodedMessage[3],
        };
        List<String> JmMg = resultMap['data'].split('^');
        jmData = {
          'jmName': JmMg[0],
          'price': JmMg[2],
          'gubun': JmMg[3],
          'change': JmMg[4],
          'change_rate': JmMg[5],
        };
        _controller.siseList.forEach((item) {
          if (item.jmCode == jmData['jmName']) {
            item.price = jmData["price"];
            item.change = jmData["change"];
            item.diff = jmData["change_rate"];
          }
        });
        _controller.siseList.refresh();
        print("***************************");
        print('Received: ${decodedMessage[1]}');
        print("***************************");
      }
      else{
      }

    } catch (e) {
      print(e);
    }
  }

  //한투 API 리얼 데이터
  void onRealDataHkt(dynamic message) async {
    try {
      //받은 데이터
      Map<String, dynamic> jmData = {};
      // 서버로부터 수신된 데이터 처리
      var receivedData = jsonDecode(message.toString());
      if (receivedData['header']['tr_id'] != "PINGPONG") {
        // JSON 디코딩
        // var decodedMessage = jsonDecode(message);
        List<String> decodedMessage = message.split('|');

        // 필요에 따라 Map에 저장
        Map<String, dynamic> resultMap = {
          'success': decodedMessage[0],
          'tr_id': decodedMessage[1],
          'code': decodedMessage[2],
          'data': decodedMessage[3],
        };
        List<String> JmMg = resultMap['data'].split('^');
        jmData = {
          'jmName': JmMg[0],
          'price': JmMg[2],
          'gubun': JmMg[3],
          'change': JmMg[4],
          'change_rate': JmMg[5],
        };
        _controller.siseList.forEach((item) {
          if (item.jmCode == jmData['jmName']) {
            item.price = jmData["price"];
            item.change = jmData["change"];
            item.diff = jmData["change_rate"];
          }
        });
        _controller.siseList.refresh();
        print("***************************");
        print('Received: ${decodedMessage[1]}');
        print("***************************");
      }
      else{
      }

    } catch (e) {
      print(e);
    }
  }

  /// 그리드 3단계 나누기
  setMakeResponse(List<TR8407Block1> response) {
    int minValue = 0;
    int maxValue = 0;

    _controller.siseList.clear();
    for (int i = 0; i < response.length; i++) {
      TR8407Block1 data = response[i];
      Sise sise = Sise(jmCode:data.code, jmName:data.name, price:data.price, sign:data.sign, change: data.change, diff: data.diff, value: data.value);
      _controller.siseList.add(sise);

      if (int.parse(_controller.siseList[i].value) < minValue) {
        minValue = int.parse(_controller.siseList[i].value);
      }

      if (maxValue == 0 ||
          int.parse(_controller.siseList[i].value) > maxValue) {
        maxValue = int.parse(_controller.siseList[i].value);
      }
    }

    int cha = maxValue - minValue;
    int step = (cha / 3).round();

    int step1 = minValue + step;
    int step2 = step1 + step;

    bool isVertical = false;
    for (int i = 0; i < _controller.siseList.length; i++) {
      if (int.parse(_controller.siseList[i].value) < step1) {
        _controller.siseList[i].step = 1;
      } else if (int.parse(_controller.siseList[i].value) < step2) {
        _controller.siseList[i].step = 2;
        _controller.siseList[i].isVertical = isVertical;
        isVertical = !isVertical;
      } else {
        _controller.siseList[i].step = 3;
      }
    }
  }

  /// 검색화면으로 이동
  _goSearchPage(String tmCode, String tmName) async {
    releaseReal();

    // bool result = await Get.to(
    //     SearchPage('', AFTER_LIST, tmCode, tmName, false),
    //     transition: Transition.fade);
    bool result = false;
    // bool jmSave = await saveFavoriteJmList();
    bool jmSave = false;

    _controller.shCode = '';
    _controller.shCount = 0;
    _controller.historyList.clear();

    if (result && jmSave) {
      initializeReal();
      //한국투자증권 현재가 TR 조회
      requestTR8407();
    }
  }

  /// 상세화면으로 이동
  _goInfoPage(int index) async {
    releaseReal();

    // bool result = await Get.to(
    //     ItemInfoPage(
    //         _controller.siseList[index].jmCode, TRADE_BUY, MAX_COUNT, 1),
    //    transition: Transition.fade);
    bool result = false;
    // bool jmSave = await saveFavoriteJmList();
    bool jmSave = false;

    _controller.shCode = '';
    _controller.shCount = 0;
    _controller.historyList.clear();

    if (result && jmSave) {
      initializeReal();
      //한국투자증권 현재가 TR 조회
      requestTR8407();
    }
  }

  /// 관심종목 편집화면으로 이동
  _goJmEditPage() async {
    releaseReal();
    //
    // final result = await Get.to(JmListEditPage(), transition: Transition.fade);
    // bool jmSave = await saveFavoriteJmList();

    _controller.shCode = '';
    _controller.shCount = 0;
    _controller.historyList.clear();

    // if (result && jmSave) {
    if (true) {
      initializeReal();
      //한국투자증권 현재가 TR 조회
      requestTR8407();
    }
  }

  /// 테마 검색 히스토리 불러오기
  setTmHistory() async {
    if (_controller.historyList.isEmpty) {
      // _controller.historyList.addAll(await loadTmHistoryList());
    }
  }

  /// 실시간 현재가 채널 연결
  requestHOSTCNTO() async {
    //토큰이 유효한지 확인 후 토큰값을 전역변수에 저장
    //유효하지 않은 경우 토큰 발급을 요청함

    Future<void> setupWebSocket() async {
      try {
        //연결
        channel = WebSocketChannel.connect(Uri.parse(
            'ws://ops.koreainvestment.com:31000/tryitout/H0STCNT0'));

        await channel.ready;

        for (int i = 0; i < jmCodes.length; i++) {
          if (i < 50) {
            Future.delayed(Duration(seconds: 1),(){            //전송할 데이터
              var requestData = {
                "header": {
                  "approval_key": hktDemoServerSocketKey,
                  "custtype": "P",
                  "tr_type": "1",
                  "content-type": "utf-8"
                },
                "body": {
                  "input": {"tr_id": "H0STCNT0", "tr_key": jmCodes[i]}
                }
              };
              // JSON 데이터로 변환 후 WebSocket으로 전송
              channel.sink.add(jsonEncode(requestData));});

          } else {
            break;
          }
        }
        // WebSocket으로부터 데이터 수신
        channel.stream.listen((message) {
          try {
            //받은 데이터 처리
            Future.delayed(Duration(seconds: 1), () {onRealDataHkt(message);});
          } catch (e) {
            //오류 및 맨 처음 성공 여부 헤더
            print("***************************");
            print('Error decoding JSON: $e');
            print("***************************");
          }
        }, onDone: () {
          //웹소켓 닫힘
          print("***************************");
          print('socket closed: reason=[${channel.closeReason}], code:[${channel.closeCode}]');
          print("***************************");
          channel.sink.close();
          ///TODO : 연결 종료 시 재연결
          // Future.delayed(Duration(seconds: 2), () {setupWebSocket();});
        }, onError: (error) {
          //웹소켓 에러
          print("***************************");
          print('Error: $error');
          print("***************************");
        });
      } catch (e) {
        print(e);
      }
    }
    setupWebSocket();
  }
  /// 실시간 현재가 채널 닫기
  void stopHOSTCNTO() {
    channel.sink.close();
  }
  /// 리스트 타입 저장하기
  _saveListType() async {
    int listType =
    _controller.listType.value == KEY_GRID ? KEY_LIST1 : KEY_GRID;
    // bool result = await saveUserListType(listType);
    bool result = true;

    if (result) {
      _controller.listType.value = listType;
    }
  }

  /// 리스트 타입 불러오기
  _loadListType() async {
    // _controller.listType.value = (await loadUserListType())!;
    //@@ Grid타입 고정
    _controller.listType.value = KEY_GRID;
    if (_controller.listType.value == -1) {
      _controller.listType.value = KEY_GRID;
    }
  }

  Widget listGrid({required int columnCount, required bool isRefresh}) {
    return StaggeredGridView.countBuilder(
      //그리드의 총 항목 수
      itemCount: isRefresh? 0:_controller.siseList.length + 1,
      //그리드 열 수
      crossAxisCount: columnCount,
      //주축(수직 간격)을 따라 항목 간의 간격
      mainAxisSpacing: 0,
      //교차 축을 따라 항목 간의 간격
      crossAxisSpacing: 0,
      padding: const EdgeInsets.all(2),
      // 각 그리드 항목에 대해 호출되며 인덱스에 따라 표시할 내용을 결정
      itemBuilder: (context, index) {
        //인덱스가 _controller.siseList.length와 같으면 빈 컨테이너가 반환됩니다(그리드의 끝에 갭을 만듬)
        if (index == _controller.siseList.length) {
          return Container();
        } else {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: animationDuration),
            columnCount: 3,
            child: ScaleAnimation(
              child: FadeInAnimation(
                duration:Duration(milliseconds: animationDuration + 300),
                child: Obx(() {
                  //데이터를 가져오는 동안 빈 컨테이너를 반환
                  if(_controller.isRequest.value){
                    return Container();
                  }
                  else{
                    return setGridItem(context, index);
                  }
                }),
              ),
            ),
          );
        }
      },
      //  각 그리드 항목의 크기를 결정
      staggeredTileBuilder: (index) {
        if (index == _controller.siseList.length) {
          // 마지막 공백
          return StaggeredTile.extent(3, 30);
        } else {
          if (_controller.siseList[index].step == 1) {
            return StaggeredTile.count(1, 1);
          } else if (_controller.siseList[index].step == 2) {
            if (_controller.siseList[index].isVertical) {
              return StaggeredTile.count(2, 1);
            } else {
              return StaggeredTile.count(1, 2);
            }
          } else if (_controller.siseList[index].step == 3) {
            return StaggeredTile.count(2, 2);
          } else {
            return StaggeredTile.count(1, 1);
          }
        }
      },
    );
  }

  /// 리스트 리스트 형태
  Widget listList() {
    return ListView.builder(
      itemCount: _controller.siseList.length + 1,
      itemBuilder: (context, index) {
        if (index == _controller.siseList.length) {
          return Padding(padding: EdgeInsets.only(bottom: 30));
        } else {
          Color textColor = isDarkMode ? Color(0xFFDCDCDC) : Colors.black;

          var item = _controller.siseList[
          index]; //HotReload 시 RangeError (index): Invalid value: Valid value range is empty: 12

          if (!item.diff.contains('.')) {
            item.diff = item.diff.replaceFirstMapped(
                RegExp(".{2}\$"), (match) => ".${match.group(0)}");
          }

          double price = double.parse(item.price);
          double change = double.parse(item.change);
          double diff = double.parse(item.diff);
          var format = new NumberFormat("###,###");

          String txtChange = "";
          if (diff != 0) {
            if (diff < 0) {
              if (!isDarkMode) {
                textColor = Colors.blue;
              } else if (isDarkMode) {
                textColor = Colors.grey;
              }
              txtChange += "▼";
            } else {
              if (!isDarkMode) {
                textColor = Colors.red;
              }
              txtChange += "▲";
            }
          }

          txtChange += " ${format.format(change)}";

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: animationDuration),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    height: 70,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  item.jmName,
                                  style: TextStyle(
                                    fontSize: textSizeNormal,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: AnimatedFlipCounter(
                                    duration: Duration(
                                        milliseconds: animationDuration),
                                    value: price,
                                    thousandSeparator: ',',
                                    textStyle: TextStyle(
                                        fontSize: textSizeTitle,
                                        color: textColor,
                                        fontWeight: FontWeight.bold),
                                    key: key,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    AutoSizeText(
                                      txtChange,
                                      style: TextStyle(
                                          fontSize: textSizeSmall,
                                          color: textColor),
                                      maxLines: 1,
                                      textAlign: TextAlign.right,
                                    ),
                                    AutoSizeText(
                                      '${diff.toString()}%',
                                      style: TextStyle(
                                          fontSize: textSizeSmall,
                                          color: textColor),
                                      maxLines: 1,
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _goInfoPage(index);
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
