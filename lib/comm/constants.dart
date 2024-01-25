import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/Master.dart';
import '../storeUtils/StoreUtils.dart';

const String serverUrl = 'http://203.109.30.210:9000';
const int apiMaxCount = 30; // 통신 최대 건수
//임시 날짜
String StringDateee = "2024-01-23 15:10";





// FToast fToast = FToast();

/// 화면 분기처리를 위한 변수
bool isBigScreen = false;
///빌드 정보
String platForm = "AOS";
/// 사용자 정보
String userSaveId = '';
String userSavePw= '';
Map<String, dynamic> userAccPw = Map();
bool isDemoCheck = true; // 모의 서버 사용 여부
bool isBioCheck = false; // 생체인증 로그인 사용 여부
bool isAccCheck = false; // 계좌 비밀번호 저장 여부

bool isScreenOn = false; // 화면켜짐 유지 여부
bool isBadge = true; // 하단탭 뱃지 표시 여부

int orderCount = 1; // 주문수량 (기본)

/// 모의투자용
String hktDemoServerToken = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0b2tlbiIsImF1ZCI6IjMyNDRkYmZmLWIyNzItNDdiYi05ZWUwLWUxNzk2OWM3YzM0MyIsImlzcyI6InVub2d3IiwiZXhwIjoxNzA2MDc4ODc5LCJpYXQiOjE3MDU5OTI0NzksImp0aSI6IlBTcnptb09MempLQmkwUFljZEpTSUtuTEllVkk3bk9jT3ZkTyJ9.G9nlRxs86-xZxDTxcMNNx0YRKIqEA7cy7KnBJJxD-HbO8ucsrNpXZGExtbTA3YZNJpmOldnB9RDq_jviGVAzPg';     //한국투자증권 모의투자용 API 토큰 값
String hktDemoServerSocketKey = '54e68e82-56e0-4366-8ddb-020cddd5e499'; //한국투자증권 모의투자용 웹소켓 접속 키
/// 실전투자용
String hktRealServerToken = '';     //한국투자증권 실전투자용 API 토큰 값
String hktRealServerSocketKey = ''; //한국투자증권 실전투자용 웹소켓 접속 키

/// 이베스트 토큰
String eBstRealServerToken = '';

/// 공통색상
const Color mBaseColor = Color.fromRGBO(252, 200, 10, 1.0);
const Color mBaseColor2 = Color.fromRGBO(252, 180, 10, 1.0);
const Color mBGColor = Color.fromRGBO(255, 255, 255, 1.0);
const Color mLightGray = Color.fromRGBO(230, 230, 230, 1.0);
const Color mBGColor2 = Color.fromRGBO(243, 243, 243, 1.0);
const Color mMediumGray = Color.fromRGBO(176, 176, 176, 1.0);
const Color mIntroColor = Color.fromRGBO(232, 231, 210, 1.0);
const Color mBaseTextColor = Color(0Xff333333);

///다크 공통 색상
const Color dBtnColor = Color(0Xff9E9E9E); //버튼컬러
const Color dBtnTxtColor = Color(0XffD4D4D4); //버튼 텍스트 컬러
const Color dDividerColor = Color(0Xff999999); //divider 컬러

/// 공통텍스트 크기
const double textSizeTitle = 25;
const double textSizeNormal = 20;
const double textSizeSmall = 15;
const double textSizeSmall2 = 17;
const double textSizeChartPrice = 40;
const double textSizePrice = 30;

/// 공통버튼 높이
const double bottomButtonHeight = 60; // 하단 버튼

const double spacing = 10; // 줄간격

/// 디바이스 타입
const int KEY_ANDROID_PHONE = 0;
const int KEY_ANDROID_TABLET = 1;
const int KEY_IOS = 2;
const int KEY_IPAD = 3;
const int KEY_FUCHSIA = 4;
const int KEY_LINUX = 5;
const int KEY_WINDOWS = 6;
const int KEY_MACOS = 7;

/// 주문 타입
const int TRADE_BUY = 2; // 매수
const int TRADE_SELL = 1; // 매도
const int MAX_COUNT = 999999999; // 주문 최대수량

/// 키보드 타입
const int KEY_PRICE = 0; // 가격
const int KEY_COUNT = 1; // 수량

const int KEY_TICK_PLS = 0; // 틱 더하기
const int KEY_TICK_MIN = 1; // 틱 빼기

/// 살래 리스트 표기 타입
const int KEY_GRID = 0; // 그리드형태
const int KEY_LIST1 = 1; // 리스트형태
const int KEY_LIST2 = 2; // 미사용

/// 종목리스트 타입
const int AFTER_LIST = 0; // 살래 리스트에서 왔을 때
const int AFTER_TM = 1; // 테마선택 리스트 다음으로 왔을 때
const int AFTER_INFO = 2; // 상세화면에서 왔을 때

/// 애니메이션
const int animationDuration = 600; // 숫자 애니메이션 지속시간
const double animationOffset = 50.0; // 숫자 애니메이션 Offset

bool checkFavorite = false; // 상세화면에서 넘어왔을 때 관심종목 체크 플래그

int sellBadge = 0; // 판매 탭 뱃지
int cancelBadge = 0; // 취소 탭 뱃지

bool reqReal = false; // 리얼데이터 요청 여부

showSnackBar(String msg,
    {Color color = mLightGray, Color textColor = Colors.black}) {
  // fToast.removeCustomToast();

  //사용자가 저장한 토스트메시지 출력 여부를 가져옴
  // var isAlarm = StoreUtils.instance.getAlarm();

  if (true) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: color,
      ),
      child: AutoSizeText(msg,
          style: TextStyle(fontSize: textSizeSmall2, color: textColor)),
    );

    // fToast.showToast(
    //   child: toast,
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 2),
    // );
  }
}

/// ////// 공통데이터 ///////////////////
// 종목마스터
Map<String, Master> master = Map();
List<String> jmCodes = [
  "005930",
  "035720",
  "035420",
  "051910",
  "096770",
  "005380",
  "005490",
  "030200",
  "078930",
  "001040",
  "066570",
  "000660",
  "096530",
  "035760",
  "035900",
  "067160",
  "053800"
];
Map<String, String> jmName = {
  "005930": "삼성전자",
  "035720": "카카오",
  "035420": "NAVER",
  "051910": "LG화학",
  "096770": "SK이노베이션",
  "005380": "현대차",
  "005490": "POSCO",
  "030200": "KT",
  "078930": "GS",
  "001040": "CJ",
  "066570": "LG전자",
  "000660": "SK하이닉스",
  "096530": "씨젠",
  "035760": "CJ ENM",
  "035900": "JYP Ent.",
  "067160": "아프리카TV",
  "053800": "안랩",
};
//마스터 영역 1
var part1Columns = ['시장구분','단축코드', '표준코드', '한글명'];
//코스피 마스터 영역2
//영역2 필드 길이 정의
var kospiFieldSpecs =  [
  2, 1, 4, 4, 4,
  1, 1, 1, 1, 1,
  1, 1, 1, 1, 1,
  1, 1, 1, 1, 1,
  1, 1, 1, 1, 1,
  1, 1, 1, 1, 1,
  1, 9, 5, 5, 1,
  1, 1, 2, 1, 1,
  1, 2, 2, 2, 3,
  1, 3, 12, 12, 8,
  15, 21, 2, 7, 1,
  1, 1, 1, 1, 9,
  9, 9, 5, 9, 8,
  9, 3, 1, 1, 1
];

var kosdaqFieldSpecs = [
  2, 1, 4, 4, 4,
  1, 1, 1, 1, 1,
  1, 1, 1, 1, 1,
  1, 1, 1, 1, 1,
  1, 1, 1, 1, 1,
  1, 9, 5, 5, 1,
  1, 1, 2, 1, 1,
  1, 2, 2, 2, 3,
  1, 3, 12, 12, 8,
  15, 21, 2, 7, 1,
  1, 1, 1, 9, 9,
  9, 5, 9, 8, 9,
  3, 1, 1, 1
];

//영역2 필드명 정의
var kospiPart2Columns = [
  '그룹코드', '시가총액규모', '지수업종대분류', '지수업종중분류', '지수업종소분류',
  '제조업', '저유동성', '지배구조지수종목', 'KOSPI200섹터업종', 'KOSPI100',
  'KOSPI50', 'KRX', 'ETP', 'ELW발행', 'KRX100',
  'KRX자동차', 'KRX반도체', 'KRX바이오', 'KRX은행', 'SPAC',
  'KRX에너지화학', 'KRX철강', '단기과열', 'KRX미디어통신', 'KRX건설',
  'Non1', 'KRX증권', 'KRX선박', 'KRX섹터_보험', 'KRX섹터_운송',
  'SRI', '기준가', '매매수량단위', '시간외수량단위', '거래정지 여부',
  '정리매매', '관리종목', '시장경고', '경고예고', '불성실공시',
  '우회상장', '락구분', '액면변경', '증자구분', '증거금비율',
  '신용가능', '신용기간', '전일거래량', '액면가', '상장일자',
  '상장주수', '자본금', '결산월', '공모가', '우선주',
  '공매도과열', '이상급등', 'KRX300', 'KOSPI', '매출액',
  '영업이익', '경상이익', '당기순이익', 'ROE', '기준년월',
  '시가총액', '그룹사코드', '회사신용한도초과', '담보대출가능', '대주가능'
];

var kosdaqPart2Columns = [
  '증권그룹구분코드','시가총액 규모 구분 코드 유가',
  '지수업종 대분류 코드','지수 업종 중분류 코드','지수업종 소분류 코드','벤처기업 여부 (Y/N)',
  '저유동성종목 여부','KRX 종목 여부','ETP 상품구분코드','KRX100 종목 여부 (Y/N)',
  'KRX 자동차 여부','KRX 반도체 여부','KRX 바이오 여부','KRX 은행 여부','기업인수목적회사여부',
  'KRX 에너지 화학 여부','KRX 철강 여부','단기과열종목구분코드','KRX 미디어 통신 여부',
  'KRX 건설 여부','(코스닥)투자주의환기종목여부','KRX 증권 구분','KRX 선박 구분',
  'KRX섹터지수 보험여부','KRX섹터지수 운송여부','KOSDAQ150지수여부 (Y,N)','기준가',
  '정규 시장 매매 수량 단위','매매수량단위','거래정지 여부','정리매매 여부',
  '관리 종목 여부','시장 경고 구분 코드','시장 경고위험 예고 여부','불성실 공시 여부',
  '우회 상장 여부','락구분 코드','액면가 변경 구분 코드','증자 구분 코드','증거금 비율',
  '신용주문 가능 여부','신용기간','전일거래량','주식 액면가','주식 상장 일자','상장 주수(천)',
  '자본금','결산 월','공모 가격','우선주 구분 코드','공매도과열종목여부','이상급등종목여부',
  'KRX300 종목 여부 (Y/N)','매출액','영업이익','경상이익','단기순이익','ROE',
  '기준년월','시가총액','그룹사 코드','회사신용한도초과여부','담보대출가능여부','대주가능여부'
];


// 계좌
int mainAccount = 0; // 주계좌 포지션


// 로그인 히스토리
List<String> loginHistory = [];

//
// /// ///////////////// SharedPreferences //////////////////////
// var pref;
//
// Future<SharedPreferences> setPref() async {
//   if (pref == null) {
//     // pref = await SharedPreferences.getInstance();
//   }
//   return pref;
// }
//
// /// 관심종목 로컬저장
// Future<bool> saveFavoriteJmList() async {
//   await setPref();
//   return pref.setStringList('FavoriteJmList', jmCodes);
// }
//
// /// 관심종목 불러오기
// Future<List<String>?> loadFavoriteJmList() async {
//   await setPref();
//   if (pref.getStringList('FavoriteJmList') != null) {
//     return pref.getStringList('FavoriteJmList');
//   } else {
//     return null;
//   }
// }
//
// /// 리스트 타입 로컬저장
// Future<bool> saveUserListType(int type) async {
//   await setPref();
//   return pref.setInt('userListType', type);
// }
//
// /// 리스트 타입 불러오기
// Future<int?> loadUserListType() async {
//   await setPref();
//   if (pref.getInt('userListType') != null) {
//     return pref.getInt('userListType');
//   } else {
//     return -1;
//   }
// }
//
// /// 로그인 히스토리 로컬저장
// Future<bool> saveLoginHistory() async {
//   await setPref();
//   return pref.setStringList('${userSaveId}_history', loginHistory);
// }
//
// /// 로그인 히스토리 불러오기
// Future<List<String>?> loadLoginHistory() async {
//   await setPref();
//   if (pref.getStringList('${userSaveId}_history') != null) {
//     return pref.getStringList('${userSaveId}_history');
//   } else {
//     return null;
//   }
// }
//
// /// 차트 데이터 카운트 로컬저장
// Future<bool> saveChartDataCount(int type) async {
//   await setPref();
//   return pref.setInt('chartDataCount', type);
// }
//
// /// 차트 데이터 카운트 불러오기
// Future<int?> loadChartDataCount() async {
//   await setPref();
//   if (pref.getInt('chartDataCount') != null) {
//     return pref.getInt('chartDataCount');
//   } else {
//     return 50;
//   }
// }
//
// /// 차트 데이터 시간 로컬저장
// Future<bool> saveChartDataTime(int type) async {
//   await setPref();
//   return pref.setInt('chartDataTime', type);
// }
//
// /// 차트 데이터 시간 불러오기
// Future<int?> loadChartDataTime() async {
//   await setPref();
//   if (pref.getInt('chartDataTime') != null) {
//     return pref.getInt('chartDataTime');
//   } else {
//     return 2;
//   }
// }
//
// /// 모의 서버 사용여부 저장
// Future<bool> saveIsDemo({required bool isDemo}) async {
//   await setPref();
//   return pref.setBool('isDemo', isDemo);
// }
//
// /// 모의 서버 사용여부 불러오기
// Future<bool> loadIsDemo() async {
//   await setPref();
//   if (pref.getBool('isDemo') != null) {
//     return pref.getBool('isDemo');
//   } else {
//     return false;
//   }
// }
//
//
//
//
// /// 생체인증 로그인 사용여부 로컬저장
// Future<bool> saveUseBioLogin() async {
//   await setPref();
//   return pref.setBool('useBioLogin', isBioCheck);
// }
//
// /// 생체인증 로그인 사용여부 불러오기
// Future<bool> loadUseBioLogin() async {
//   await setPref();
//   if (pref.getBool('useBioLogin') != null) {
//     return pref.getBool('useBioLogin');
//   } else {
//     return false;
//   }
// }
//
// /// 사용자 ID 로컬저장
// Future<bool> saveUserId(String id) async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   // return pref.setString('${type}_userID', getEncryptString(id));
//   return true;
// }
//
// /// 사용자 ID 불러오기
// Future<String> loadUserId() async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//
//   // return getDecryptString(pref.getString('${type}_userID')??'');
//   return "-";
// }
//
// /// 사용자 PW 로컬저장
// Future<bool> saveUserPw(String pw) async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   // return pref.setString('${type}_userPW', getEncryptString(pw));
//   return true;
// }
//
// /// 사용자 PW 불러오기
// Future<String> loadUserPw() async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   // return getDecryptString(pref.getString('${type}_userPW')??'');
//   return "-";
// }
//
// /// 인증서 ID 로컬저장
// Future<bool> saveAuthId(String id) async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   // return pref.setString('${type}_authID', getEncryptString(id));
//   return true;
// }
//
// /// 인증서 ID 불러오기
// Future<String> loadAuthId() async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   // return getDecryptString(pref.getString('${type}_authID')!!);
//   return "-";
// }
//
// /// 계좌비밀번호 저장여부 로컬저장
// Future<bool> saveUsePwSave() async {
//   await setPref();
//   return pref.setBool('usePwSave', isAccCheck);
// }
//
// /// 계좌비밀번호 저장여부 불러오기
// Future<bool> loadUsePwSave() async {
//   await setPref();
//   if (pref.getBool('usePwSave') != null) {
//     return pref.getBool('usePwSave');
//   } else {
//     return false;
//   }
// }
//
// /// 사용자 계좌 비밃번호 로컬저장
// Future<bool> saveUserAccPw(Map<String, dynamic> accPw) async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   return pref.setString('${type}_userAccPW', json.encode(accPw));
// }
//
// /// 사용자 계좌 비밃번호 불러오기
// Future<Map<String, dynamic>> loadUserAccPw() async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   if (pref.getString('${type}_userAccPW') != null) {
//     String data = pref.getString('${type}_userAccPW')!!;
//     return json.decode(data);
//   } else {
//     return Map();
//   }
// }
//
// /// 화면켜짐유지 로컬저장
// Future<bool> saveScreenOn() async {
//   await setPref();
//   return pref.setBool('screenOn', isScreenOn);
// }
//
// /// 화면켜짐유지 불러오기
// Future<bool> loadScreenOn() async {
//   await setPref();
//   if (pref.getBool('screenOn') != null) {
//     return pref.getBool('screenOn');
//   } else {
//     return false;
//   }
// }
//
// /// 주문수량 로컬저장
// Future<bool> saveOrderCnt(int cnt) async {
//   await setPref();
//   return pref.setInt('orderCount', cnt);
// }
//
// /// 주문수량 불러오기
// Future<int> loadOrderCnt() async {
//   await setPref();
//   if (pref.getInt('orderCount') != null) {
//     return pref.getInt('orderCount');
//   } else {
//     return 1;
//   }
// }
//
// /// 하단탭 뱃지 표시 여부 로컬저장
// Future<bool> saveBadgeOn() async {
//   await setPref();
//   return pref.setBool('badgeOn', isBadge);
// }
//
// /// 하단탭 뱃지 표시 여부 불러오기
// Future<bool> loadBadgeOn() async {
//   await setPref();
//   if (pref.getBool('badgeOn') != null) {
//     return pref.getBool('badgeOn');
//   } else {
//     return true;
//   }
// }
//
// /// 첫화면 로컬저장
// Future<bool> saveMainTab(int mainTab) async {
//   await setPref();
//   return pref.setInt('MainTab', mainTab);
//
// }
//
// /// 첫화면 불러오기
// Future<int> loadMainTab() async {
//
//   await setPref();
//   int? mainTabValue = pref.getInt('MainTab');
//
//
//   if (mainTabValue != null) {
//     return mainTabValue;
//
//   } else {
//     return 1;
//   }
// }
//
//
// /// 주계좌 저장
// Future<bool> saveMainAccount() async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   return pref.setInt('${type}_MainAccount', mainAccount);
// }
//
// /// 주계좌 불러오기
// Future<int> loadMainAccount() async {
//   await setPref();
//
//   String type = isDemoCheck ? 'Demo' : 'Real';
//   if (pref.getInt('MainAccount') != null) {
//     return pref.getInt('${type}_MainAccount');
//   } else {
//     return 0;
//   }
// }
//
//
// /// 종목 이름으로 종목 코드 찾기
// String findJmCode(String jmName) {
//   String jmCode = '';
//
//   master.forEach((key, value) {
//     if (value.jmName == jmName) {
//       jmCode = key;
//       return;
//     }
//   });
//
//   return jmCode;
// }
// /// 현재시간 HHMMSS 형태로 변환
// String getCurrentTimeString() {
//   DateTime now = DateTime.now();
//
//   String hour = _twoDigits(now.hour);
//   String minute = _twoDigits(now.minute);
//   String second = _twoDigits(now.second);
//
//   String currentTimeString = '$hour$minute$second';
//
//   return currentTimeString;
// }
// /// 현재날짜 YYMMDD 형태로 변환
// String getCurrentDateString() {
//   DateTime now = DateTime.now();
//
//   String year = _twoDigits(now.year);
//   String month = _twoDigits(now.month);
//   String day = _twoDigits(now.day);
//
//   String currentDateString = '$year$month$day';
//
//   return currentDateString;
// }
// /// 기준 날짜보다 N일전 날짜 YYMMDD반환
// String getNDaysAgo(int n, String dayGubun) {
//   DateTime currentDate = DateTime.now();
//   int days = n;
//
//   switch (dayGubun) {
//     case "D":
//       break;
//     case "W":
//       days *= 7;
//       break;
//     case "M":
//       currentDate = DateTime(currentDate.year, currentDate.month - n, currentDate.day);
//       days = 0;
//       break;
//     case "Y":
//       currentDate = DateTime(currentDate.year - n, currentDate.month, currentDate.day);
//       days = 0;
//       break;
//     default:
//       throw ArgumentError("Invalid dayGubun: $dayGubun");
//   }
//
//   DateTime targetDate = currentDate.subtract(Duration(days: days));
//
//   String year = targetDate.year.toString();
//   String month = _twoDigits(targetDate.month);
//   String day = _twoDigits(targetDate.day);
//
//   return '$year$month$day';
// }
// String _twoDigits(int n) {
//   return n.toString().padLeft(2, '0');
// }
// /// 계좌 번호 포맷팅
// /// 전역변수에 저장된 계좌번호 정보를 조합해 반환하는 함수
// String getAccountString({int? index}) {
//   // String accountNo = '';
//   // int accountIndex = index == null ? mainAccount : index;
//   //
//   //
//   // RegExp account = RegExp(r'(\d{3})(\d{2})(\d{6})');
//   // var matches = account.allMatches(accountList[mainAccount].acctNo);
//   // var match = matches.elementAt(0);
//   // accountNo = '${match.group(1)}-${match.group(2)}-${match.group(3)}';
//   // String accountNo = "${accountList[mainAccount].acctNo}-${accountList[mainAccount].type}";
//   String accountNo = "123-01";
//   return accountNo;
// }
//
//
// /// 한투 토큰 발행 함수,
// /// 토큰발급 23시간 이내는 로컬에 저장된 값을 반환화며
// /// 23시간이 경과한 경우 API서버에 재요청함
// Future<bool> requestHKTToken({required bool isDemo}) async{
//
//   //기존에 발행된 토큰 확인
//   var Stringtoken = await _loadHKTToken(isDemo: isDemo);
//
//   //기존 토큰이 존재/유효한 경우
//   if(Stringtoken != null){
//     //토큰을 전역변수에 저장후 종료
//     if(isDemo){
//       hktDemoServerToken = Stringtoken;
//     }
//     else{
//       hktRealServerToken = Stringtoken;
//     }
//     return true;
//   }
//   ////////////------////////////
//   //토큰이 없거나 만료된 경우
//   //한투API 토큰 발행 요청
//   // var token = await getHKTToken(isDemo: isDemo);
//   var token = "";
//
//   //통신에러 발생, 예외처리 구간
//   if(token == null){
//     return false;
//   }
//
//   //토큰을 전역변수에 저장
//   if(isDemo){
//     // hktDemoServerToken = "${token.tokenType} ${token.accessToken}";
//     hktDemoServerToken = "fakeDemoToken";
//
//   }
//   else{
//     // hktRealServerToken = "${token.tokenType} ${token.accessToken}";
//     hktRealServerToken = "fakeToken";
//
//   }
//
//   //로컬 저장소에 토큰 저장
//   await _saveHKTToken(token as HKTToken, isDemo: isDemo);
//
//   return true;
// }
// /// 한투 실시간키 발행
// Future<bool> requestHKTSocketKey({bool isDemo = true}) async {
//   //기존에 발행된 키 확인
//   var socketKey = await loadHKTSocketKey(isDemo: isDemo);
//
//   //기존 키가 존재/유효한 경우
//   if(socketKey != null){
//
//     //키를 전역변수에 저장후 종료
//     if(isDemo){
//       hktDemoServerSocketKey = socketKey;
//     }
//     else{
//       hktRealServerSocketKey = socketKey;
//     }
//
//     return true;
//   }
//   ////////////------////////////
//   //키가 없거나 만료된 경우
//   //한투API 키 발행 요청
//   // socketKey = await getHKTSocketKey(isDemo: isDemo);
//   socketKey = "";
//
//   //통신에러 발생, 예외처리 구간
//   if (socketKey == null) {
//     return false;
//   }
//
//   //키를 전역변수에 저장
//   if(isDemo){
//     hktDemoServerSocketKey = socketKey;
//   }
//   else{
//     hktRealServerSocketKey = socketKey;
//   }
//
//   //로컬 저장소에 토큰 저장
//   await saveHKTSocketKey(socketKey, isDemo: isDemoCheck);
//
//   return true;
// }
//
// class HKTToken{
//   String accessToken;
//   String tokenType;
//   String expiredDate;
//   int expireInt;
//
//   HKTToken(this.accessToken, this.tokenType, this.expiredDate, this.expireInt);
//
//   setHKTToken(HKTToken item){
//     this.accessToken = item.accessToken;
//     this.tokenType = item.tokenType;
//     this.expiredDate = item.expiredDate;
//     this.expireInt = item.expireInt;
//   }
//
//   //json -> HKTToken
//   factory HKTToken.fromJson(Map<String, dynamic> json){
//     return HKTToken(
//       (json["access_token"] as String).trim(),
//       (json["token_type"] as String).trim(),
//       (json["access_token_token_expired"] as String).trim(),
//       json["expires_in"] ,
//     );
//
//   }
// }
//
//
// /// 한국투자증권 토큰 저장
// /// 토큰값과 유효기간을 저장
// Future<bool> _saveHKTToken(HKTToken token, {required bool isDemo}) async {
//   await setPref();
//
//   String tokenString = isDemo? "HKTDemoServerToken":"HKTRealServerToken";
//   String expiredString = isDemo? "HKTDemoServerTokenExpire":"HKTRealServerTokenExpire";
//
//   //토큰 만료시간 계산
//   //토큰 발급시 유효기간이 seconds 값으로 반환되기 때문에 seconds로 연산
//   //토큰 만료 60분 전을 저장하도록 함
//   DateTime expiredDate = DateTime.parse(token.expiredDate);
//   expiredDate = expiredDate.add(Duration(hours: -1));
//   // String StringDate = DateFormat('yyyy-MM-dd HH:mm').format(expiredDate);
//   String StringDate = "2024-01-23 15:10";
//
//   //토큰과 토큰 만료시간을 저장
//   //토큰저장시 타입과 토큰사이 공백이 필요
//   //토큰저장 실패시 값을 지우는 remove함수 호출
//   if( !await pref.setString(tokenString, "${token.tokenType} ${token.accessToken}") ||
//       !await pref.setString(expiredString, StringDate)){
//     pref.remove(tokenString);
//     pref.remove(expiredString);
//     return false;
//   }
//   return true;
// }
//
// /// 한국투자증권 실시간 키 저장
// /// 키값과 유효기간을 저장
// Future<bool> saveHKTSocketKey(String key, {required bool isDemo}) async {
//   await setPref();
//
//   String tokenString = isDemo? "HKTDemoServerSocketKey":"HKTRealServerSocketKey";
//   String expiredString = isDemo? "HKTDemoServerSocketKeyExpire":"HKTRealServerSocketKeyExpire";
//
//   //실시간 키 만료시간 생성(24시간)
//   //키 만료 60분 전을 저장하도록 함
//   DateTime now = DateTime.now().add(Duration(hours: 23));
//   String StringDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
//
//   //암호화한 키와 토큰 만료시간을 저장
//   //키저장 실패시 값을 지우는 remove함수 호출
//   if( !await pref.setString(tokenString, key) ||
//       !await pref.setString(expiredString, StringDate)){
//     pref.remove(tokenString);
//     pref.remove(expiredString);
//     return false;
//   }
//   return true;
// }
//
//
// /// 한국투자증권 토큰을 반환하는 함수
// /// 토큰이 만료된 경우 토큰을 지우고 null값을 반환
// Future<String?> _loadHKTToken({required bool isDemo}) async {
//   await setPref();
//
//   String tokenString = isDemo? "HKTDemoServerToken":"HKTRealServerToken";
//   String expiredString = isDemo? "HKTDemoServerTokenExpire":"HKTRealServerTokenExpire";
//
//   //로그인 값이 없는 경우 예외처리
//   if(pref.getString(tokenString) == null || pref.getString(expiredString) == null){
//     return null;
//   }
//
//   //토큰(암호화된 값)
//   String token = pref.getString(tokenString);
//   //토큰 만료일
//   String expire = pref.getString(expiredString);
//
//   //String -> date
//   DateTime expireDate = DateFormat('yyyy-MM-dd HH:mm').parse(expire);
//
//   //토큰 만료일이 지난경우 remove함수 실행 후 null 반환
//   if(DateTime.now().isAfter(expireDate) ||
//       pref.getString(tokenString) == null){
//     pref.remove(tokenString);
//     pref.remove(expiredString);
//     return null;
//   }
//   //복호화하여 값을 반환
//   return token;
// }
//
//
// /// 한국투자증권 실시간 키를 반환하는 함수
// /// 키가 만료된 경우 토큰을 지우고 null값을 반환
// Future<String?> loadHKTSocketKey({required bool isDemo}) async {
//   await setPref();
//
//   String tokenString = isDemo? "HKTDemoServerSocketKey":"HKTRealServerSocketKey";
//   String expiredString = isDemo? "HKTDemoServerSocketKeyExpire":"HKTRealServerSocketKeyExpire";
//
//   //로그인 값이 없는 경우 예외처리
//   if(pref.getString(tokenString) == null || pref.getString(expiredString) == null){
//     return null;
//   }
//
//   //키 값(암호화된 값)
//   String key = pref.getString(tokenString);
//   //토큰 만료일
//   String expire = pref.getString(expiredString);
//
//   //String -> date
//   DateTime expireDate = DateFormat('yyyy-MM-dd HH:mm').parse(expire);
//
//   //토큰 만료일이 지난경우 remove함수 실행 후 null 반환
//   if(DateTime.now().isAfter(expireDate) ||
//       pref.getString(tokenString) == null){
//     pref.remove(tokenString);
//     pref.remove(expiredString);
//     return null;
//   }
//   //복호화하여 값을 반환
//   return key;
// }