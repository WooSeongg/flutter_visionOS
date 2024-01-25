import 'dart:convert';

import 'package:http/http.dart' as http;

//데이터구조 임시, 옮겨야함
import 'Keys.dart';

class EBSTToken{
  String token;     //토큰
  int expired;      //유효기간 (초)
  String tokenType; //Bearer
  String scop;      //oob 고정

  EBSTToken(this.token, this.expired, this.tokenType, this.scop);

  factory EBSTToken.fromJson(Map<String,dynamic> json){
    return EBSTToken(json["access_token"], json["expires_in"], json["token_type"], json["scope"]);
  }
}

Future<EBSTToken?> getEBSTToken() async{

  Uri uri = Uri(
    scheme: 'https',
    host: 'openapi.ebestsec.co.kr',
    port: 8080,
    path: 'oauth2/token',
    queryParameters: {
      'grant_type':'client_credentials',
      'appkey':'${Keys.EBST_REAL_APP_KEY}',
      'appsecretkey':'${Keys.EBST_REAL_SECRET_KEY}',
      'scope':'oob'
    },
  );


  Map<String,String> headers = {
    'content-type':'application/x-www-form-urlencoded'
  };

  try{
    //http Post 요청
    http.Response response = await http.post(uri, headers: headers);
    final int statusCode = response.statusCode;

    Map<String, dynamic> jsonData = json.decode(response.body);
    String decodedBody = utf8.decode(response.bodyBytes);
    var decodedJson = jsonDecode(decodedBody);

    //데이터 요청 실패
    if(statusCode != 200){
      print("######################");
      print("(EBSTToken)이베스트토큰요청에러:${decodedJson["mgs1"]}");
      print("(EBSTToken)에러코드:${decodedJson["msg_cd"]}");
    }

    return EBSTToken.fromJson(jsonData);
  }
  catch(e){
    print(e);
    return null;
  }


}