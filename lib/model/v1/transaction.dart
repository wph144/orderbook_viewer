class Transaction {
  final String type;
  final Content content;

  Transaction({
    required this.type,
    required this.content,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(type: json['type'], content: Content.fromJson(json['content']));
  }
}

class Content {
  final List<Data> list;

  Content({
    required this.list,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(list: (json['list'] as List).map((e) => Data.fromJson(e)).toList());
  }
}

class Data {
  final String symbol;
  final String buySellGb;
  final String contPrice;
  final String contQty;
  final String contAmt;
  final String contDtm;
  final String updn;

  Data({
    required this.symbol,
    required this.buySellGb,
    required this.contPrice,
    required this.contQty,
    required this.contAmt,
    required this.contDtm,
    required this.updn,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      symbol: json['symbol'],
      buySellGb: json['buySellGb'],
      contPrice: json['contPrice'],
      contQty: json['contQty'],
      contAmt: json['contAmt'],
      contDtm: json['contDtm'],
      updn: json['updn'],
    );
  }
}
