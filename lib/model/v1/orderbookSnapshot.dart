class OrderbookSnapshot {
  final String type;
  final Content content;

  OrderbookSnapshot({
    required this.type,
    required this.content,
  });

  factory OrderbookSnapshot.fromJson(Map<String, dynamic> json) {
    return OrderbookSnapshot(
      type: json['type'],
      content: Content.fromJson(json['content']),
    );
  }
}

class Content {
  final String symbol;
  final int datetime;
  final List<PriceSize> asks;
  final List<PriceSize> bids;

  Content({
    required this.symbol,
    required this.datetime,
    required this.asks,
    required this.bids,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      symbol: json['symbol'],
      datetime: json['datetime'] is String ? int.parse(json['datetime']) : json['datetime'] as int,
      asks: (json['asks'] as List).map((ask) => PriceSize.fromJsonList(ask as List)).toList(),
      bids: (json['bids'] as List).map((bid) => PriceSize.fromJsonList(bid as List)).toList(),
    );
  }
}

class PriceSize {
  final double price;
  final double size;

  PriceSize({required this.price, required this.size});

  factory PriceSize.fromJsonList(List<dynamic> jsonList) {
    return PriceSize(
      price: jsonList[0] is String ? double.parse(jsonList[0]) : jsonList[0] as double,
      size: jsonList[1] is String ? double.parse(jsonList[1]) : jsonList[1] as double,
    );
  }
}
