import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../comm/Keys.dart';
import '../../comm/constants.dart';
import '../../storeUtils/StoreUtils.dart';
  /// /////////////////////// ///
  ///한국투자증권 주식현재가 시세 API///
  /// ////////////////////// ///

  class FHKST01010100Output{
    String? shcode;       // 종목코드
    String? hname;        // 종목명
    String? price;        // 현재가
    String? sign;         // 전일대비구분
    String? change;       // 전일대비
    String? diff;         // 등락률
    String? volume;       // 누적거래량
    String? recprice;     // 기준가
    String? uplmtprice;   // 상한가
    String? dnlmtprice;   // 하한가
    String? jnilvolume;   // 전일거래량
    String? open;         // 시가
    String? high;         // 고가
    String? low;          // 저가
    String? high52w;      // 52주 최고가
    String? low52w;       // 52주 최저가
    String? per;          // PER
    String? pbrx;         // PBRX
    String? listing;      // 주식수
    String? value;        // 거래대금(백만)
    String? parprice;     // 액면가
    String? totla;        // 시가총액
    String? svi_uplmtprice; // 정적 상한가
    String? svi_dnlmtprice; // 정적 하한가

    FHKST01010100Output({this.shcode,
      this.hname,
      this.price,
      this.sign,
      this.change,
      this.diff,
      this.volume,
      this.recprice,
      this.uplmtprice,
      this.dnlmtprice,
      this.jnilvolume,
      this.open,
      this.high,
      this.low,
      this.high52w,
      this.low52w,
      this.per,
      this.pbrx,
      this.listing,
      this.value,
      this.parprice,
      this.totla,
      this.svi_uplmtprice,
      this.svi_dnlmtprice}
        );

    /// Json -> TR8434OutputItem
    factory FHKST01010100Output.fromJSON(Map<String, dynamic> json){
      return FHKST01010100Output(
        shcode: json['stck_shrn_iscd'],
        hname: jmName[json['stck_shrn_iscd']],
        price: json['stck_prpr'],
        sign: json['prdy_vrss_sign'],
        change: json['prdy_vrss'],
        diff: json['prdy_ctrt'],
        volume: json['acml_vol'],
        recprice: json['stck_sdpr'],
        uplmtprice: json['stck_mxpr'],
        dnlmtprice: json['stck_llam'],
        jnilvolume: json['prdy_vrss_vol_rate'],
        open: json['stck_oprc'],
        high: json['stck_hgpr'],
        low: json['stck_lwpr'],
        high52w: json['w52_hgpr'],
        low52w: json['w52_lwpr'],
        per: json['per'],
        pbrx: json['pbr'],
        listing: json['lstn_stcn'],
        value: json['acml_tr_pbmn'],
        parprice: json['stck_fcam'],
        totla: json['hts_avls'],
        svi_uplmtprice: json['stck_mxpr'],
        svi_dnlmtprice: json['stck_llam'],
      );
    }
    /// 차트 json 변환
    factory FHKST01010100Output.fromChartJSON(Map<String, dynamic> json){
      return FHKST01010100Output(
        shcode: json['shcode'],
        hname: json['hname'],
        price: json['price'],
        sign: json['sign'],
        change: json['change'],
        diff: json['diff'],
        volume: json['volume'],
        recprice: json['recprice'],
        uplmtprice: json['uplmtprice'],
        dnlmtprice: json['dnlmtprice'],
        jnilvolume: json['jnilvolume'],
        open: json['open'],
        high: json['high'],
        low: json['low'],
        high52w: json['high52w'],
        low52w: json['low52w'],
        per: json['per'],
        pbrx: json['pbrx'],
        listing: json['listing'],
        value: json['value'],
        parprice: json['parprice'],
        totla: json['totla'],
        svi_uplmtprice: json['svi_uplmtprice'],
        svi_dnlmtprice: json['svi_dnlmtprice'],
      );
    }
    // toJson 메서드 구현
    Map<String, dynamic> toJson() {
      return {
        'shcode': shcode,
        'hname': hname,
        'price': price,
        'sign': sign,
        'change': change,
        'diff': diff,
        'volume': volume,
        'recprice': recprice,
        'uplmtprice': uplmtprice,
        'dnlmtprice': dnlmtprice,
        'jnilvolume': jnilvolume,
        'open': open,
        'high': high,
        'low': low,
        'high52w': high52w,
        'low52w': low52w,
        'per': per,
        'pbrx': pbrx,
        'listing': listing,
        'value': value,
        'parprice': parprice,
        'totla': totla,
        'svi_uplmtprice': svi_uplmtprice,
        'svi_dnlmtprice': svi_dnlmtprice,
      };
    }

  }


  class FHKST01010100{
    ///주문,체결 조회 메서드,
    ///연속조회 여부를 반환함

    Future<List<dynamic>> fetchFHKST01010100(List<String> jmCode,{  bool oneJm = false,String oneJmCode = ''}) async {

      //모의투자여부 확인
      // bool isDemo = StoreUtils.instance.getisDemo();

      //토큰이 유효한지 확인 후 토큰값을 전역변수에 저장
      //유효하지 않은 경우 토큰 발급을 요청함
      //data


      List<dynamic> data = [];
      int jmLength = jmCodes.length;
      if(oneJm){
        Uri uri = Uri(
          scheme: 'https',
          host: 'openapivts.koreainvestment.com',
          port: 29443,
          path: '/uapi/domestic-stock/v1/quotations/inquire-price',
          queryParameters: {
            'fid_cond_mrkt_div_code': "J",
            'fid_input_iscd': oneJmCode,
          },
        );
        Map<String, String> headers = {
          "appkey":  Keys.HKT_DEMO_APP_KEY,
          "appsecret": Keys.HKT_DEMO_SECRET_KEY,
          "authorization": hktDemoServerToken,
          "tr_id":"FHKST01010100",
        };



        try {
          //////////////////////
          //////실전투자 1초당 20건, 모의투자 1초당 5건
          // 실전투자의 경우 time.sleep(0.05), 모의투자의 경우 time.sleep(0.2)
          //////////////////////
          await Future.delayed(Duration(milliseconds: 200));
          // http Get 요청
          http.Response response = await http.get(uri, headers: headers);
          final int statusCode = response.statusCode;
          // json으로 decode
          String decodedBody = utf8.decode(response.bodyBytes);
          var decodedJson = jsonDecode(decodedBody);

          // 데이터 요청 실패
          if (statusCode != 200) {
            print("@@@@@@@@@@@@@@@@@@@@@@@");
            print("@@@@@@데이터 없음@@@@@@@");
            print("@@@@@@@@@@@@@@@@@@@@@@@");
            print("(FHKST01010100) 현재가 시세 조회 :${decodedJson["msg1"]}");
            print("(FHKST01010100) 에러 코드:${decodedJson["msg_cd"]}");
          }

          // json으로 디코딩
          if(decodedJson["output"] != null){
            var item = await FHKST01010100Output.fromJSON(decodedJson["output"]);
            var parseItem = item.toJson();
            data.add(parseItem);
          }
        } catch (e) {
          print(e);
          return [];
        }
      }
      else{
        for(int i = 0; i < jmLength; i++){
          Uri uri = Uri(
            scheme: 'https',
            host: 'openapivts.koreainvestment.com',
            port: 29443,
            path: '/uapi/domestic-stock/v1/quotations/inquire-price',
            queryParameters: {
              'fid_cond_mrkt_div_code': "J",
              'fid_input_iscd': jmCodes[i],
            },
          );

          Map<String, String> headers = {
            "appkey": Keys.HKT_DEMO_APP_KEY,
            "appsecret": Keys.HKT_DEMO_SECRET_KEY,
            "authorization": hktDemoServerToken,
            "tr_id":"FHKST01010100",
          };



          try {
            //////////////////////
            //////실전투자 1초당 20건, 모의투자 1초당 5건
            // 실전투자의 경우 time.sleep(0.05), 모의투자의 경우 time.sleep(0.2)
            //////////////////////
            await Future.delayed(Duration(milliseconds: 200));
            // http Get 요청
            http.Response response = await http.get(uri, headers: headers);
            final int statusCode = response.statusCode;
            // json으로 decode
            String decodedBody = utf8.decode(response.bodyBytes);
            var decodedJson = jsonDecode(decodedBody);

            // 데이터 요청 실패
            if (statusCode != 200) {
              print("@@@@@@@@@@@@@@@@@@@@@@@");
              print("@@@@@@데이터 없음@@@@@@@");
              print("@@@@@@@@@@@@@@@@@@@@@@@");
              print("(FHKST01010100) 현재가 시세 조회 :${decodedJson["msg1"]}");
              print("(FHKST01010100) 에러 코드:${decodedJson["msg_cd"]}");
            }

            // json으로 디코딩
            if(decodedJson["output"] != null){
              var item = await FHKST01010100Output.fromJSON(decodedJson["output"]);
              var parseItem = item.toJson();
              data.add(parseItem);
            }
          } catch (e) {
            print(e);
            return [];
          }
        }
      }

      return data;
    }
  }