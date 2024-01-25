
enum Market{ KOSPI, KOSDAQ }

class Master {
  /// 시장구분(1:코스피, 2:코스닥)
  String gubun;
  /// 종목명
  String jmName;
  /// 단축코드
  String jmCode;
  /// 확장코드
  String fullCode;
  /// 전일거래량
  String preDayVolume;
  /// 시간외 시장 매매수량단위
  String ordQUnit;
  /// 기준가
  String basePrice;
  /// 거래정지
  String tradeHalt;
  /// 영업이익
  String operatingProfit;
  /// 경상이익
  String ordinaryProfit;
  /// ROE(자기자본이익률)
  String roe;
  /// 전일기준 시가총액 (억)
  String marketCap;

  Master({required this.gubun, required this.jmName, required this.jmCode, required this.fullCode, required this.preDayVolume,
          required this.tradeHalt, required this.ordQUnit, required this.operatingProfit, required this.ordinaryProfit,
          required this.basePrice, required this.roe, required this.marketCap});

  // /// json(Map) -> Master
  // factory Master.fromJson(Map<String, dynamic> json) {
  //   return Master(
  //       jmName: (json['hname'] as String).trim(),
  //       jmCode: (json['shcode'] as String).trim(),
  //       fullCode: (json['expcode'] as String).trim(),
  //       etfGubun: (json['etfgubun'] as String).trim(),
  //       maxPrice: (json['uplmtprice'] as String).trim(),
  //       minPrice: (json['dnlmtprice'] as String).trim(),
  //       close: (json['jnilclose'] as String).trim(),
  //       ordQUnit: (json['memedan'] as String).trim(),
  //       basePrice: (json['recprice'] as String).trim(),
  //       gubun: (json['gubun']as String).trim(),
  //   );
  // }

  ///map -> Master
  factory Master.fromMst(Map<String, dynamic>map){
    return Master(
      gubun: (map['시장구분'] as String).trim(),
      jmName: (map['한글명'] as String).trim(),
      jmCode: (map['단축코드'] as String).trim(),
      fullCode: (map['표준코드'] as String).trim(),
      preDayVolume: (map['전일거래량'] as String).trim(),
      ordQUnit: (map['매매수량단위'] as String).trim(),
      basePrice: (map['기준가'] as String).trim(),
      tradeHalt: (map['거래정지 여부']as String).trim(),
      operatingProfit: (map['영업이익']as String).trim(),
      ordinaryProfit: (map['경상이익']as String).trim(),
      roe: (map['ROE']as String).trim(),
      marketCap: (map['시가총액']as String).trim()
    );
  }

  // /// Master -> Map
  // static Map<String, dynamic> toMap(Master master) => {
  //   'gubun': master.gubun,
  //   'hname': master.jmName,
  //   'shcode': master.jmCode,
  //   'expcode': master.fullCode,
  //   'memedan': master.ordQUnit,
  //   'recprice': master.basePrice,
  //
  // };
  //
  // /// List -> Json string (데이터 저장)
  // static String encodeMasters(List<Master> masters) => json.encode(
  //   masters.map<Map<String, dynamic>>((master) => toMap(master)).toList(),
  // );
  //
  // /// Json string -> List (데이터 불러오기)
  // static List<Master> decodeMasters(String masters) =>
  //     (json.decode(masters) as List<dynamic>)
  //         .map<Master>((cafe) => Master.fromJson(cafe))
  //         .toList();
}