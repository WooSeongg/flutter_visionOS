import 'dart:convert';

import 'package:http/http.dart' as http;
import '../comm/Keys.dart';
import '../comm/constants.dart';

//////////////////////////
////////ebest API/////////
///////종목 멀티 조회////////
//////////////////////////
class TR8407Output{
  String code = "";      // 응답코드
  String msg = "";       // 응답메시지
  String? isNext;        // 연속거래 여부
  String? nextKey;       // 연속 거래 키
  List<TR8407Block1>? block1;

  TR8407Output({required this.code, required this.msg, required this.isNext, required this.nextKey, required this.block1});


  /// json -> TR8407
  factory TR8407Output.fromJson({required Map<String,dynamic> header,required Map<String,dynamic> body}){

    List<TR8407Block1> TR8407Block1List = [];
    List<dynamic> result = body["t8407OutBlock1"];

    result.forEach((item) {
      var result = TR8407Block1.fromJson(item);
      TR8407Block1List.add(result);
    });

    try{
      return TR8407Output(
        code: body["rsp_cd"],
        msg: body["rsp_msg"],
        isNext: header["tr_cont"],
        nextKey: header["tr_cont_key"],
        block1: TR8407Block1List,
      );
    }
    catch(e){
      print(e);
    }
    return TR8407Output(code:"", msg:"", isNext:"", nextKey: "", block1: null);

  }
}

class TR8407Block1{
  String code;    //종목코드
  String name;    //종목명
  String price;   //현재가
  String sign;    //전일대비구분
  String change;  //전일대비
  String diff;    //등락률
  String value;   //거래대금(백만단위)

  TR8407Block1({required this.code, required this.name, required this.price, required this.sign, required this.change, required this.diff, required this.value});

  factory TR8407Block1.fromJson(json){
    return TR8407Block1(
        code: json["shcode"],
        name: json["hname"],
        price: "${json["price"]}",
        sign: json["sign"],
        change: "${json["change"]}",
        diff: json["diff"],
        value: "${json["value"]}"
    );
  }
}

class TR8407{
  /// 종목 멀티 조회(TR8407) 데이터 요청
  Future<TR8407Output?> fetchTR8407({String? nextKey}) async{

    //리턴할 데이터
    //데이터 요청에 실패할 경우 null을 반환하기 위해 nullable로 선언
    TR8407Output? item;

    Uri uri = Uri(
      scheme: 'https',
      host: 'openapi.ebestsec.co.kr',
      port: 8080,
      path: '/stock/market-data',
    );
    Map<String, String> headers = {
      "content-type": "application/json;charset=utf-8",
      "authorization":  eBstRealServerToken, //발급받은 토큰 키
      "tr_cd": "t8407",                      //멀티조회 tr코드
      "tr_cont": (nextKey == null)? "N":"Y", //연속조회 여부
      "tr_cont_key":nextKey??"",             //연속조회 키값
    };
    String str = jmCodes.join("");
    var body = {
      "t8407InBlock":{
        "nrec":jmCodes.length,     //종목 건 수
        "shcode": str  //종목코드 구분자 없이 연속작성
      }
    };

    var encodedBody = json.encode(body);

    try{
      //http요청 및 결과값 저장
      http.Response response = await http.post(uri, headers: headers, body: encodedBody);
      //http 상태코드 저장
      final int statusCode = response.statusCode;
      // json으로 jdecode
      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);

      if(statusCode != 200){
        print("(TR8407)에러발생########");
        print("(TR8407)에러코드: ${decodedJson["rsp_cd"]}");
        print("(TR8407)에러메시지: ${decodedJson["rsp_msg"]}");
        return null;
      }

      //데이터 구조화
      if(decodedJson["t8407OutBlock1"] != null){
        print(response.headers);
        print(response.headers);
        print(decodedJson["t8407OutBlock1"]);
        print(decodedJson["t8407OutBlock1"]);
        item = await TR8407Output.fromJson(header:response.headers, body:decodedJson);
      }
    }
    catch (e) {
      print(e);
    }
    return item;
  }
}