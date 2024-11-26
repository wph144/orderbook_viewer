class Orderbook {
  final String type;
  final String code;
  final double totalAskSize;
  final double totalBidSize;
  final List<OrderbookUnit> orderbookUnitList;
  final int level;
  final int timestamp;
  final String streamType;

  Orderbook({
    required this.type,
    required this.code,
    required this.totalAskSize,
    required this.totalBidSize,
    required this.orderbookUnitList,
    required this.level,
    required this.timestamp,
    required this.streamType,
  });

  // JSON 데이터를 OrderBook 객체로 변환
  factory Orderbook.fromJson(Map<String, dynamic> json) {
    return Orderbook(
      type: json['type'],
      code: json['code'],
      totalAskSize: json['total_ask_size'].toDouble(),
      totalBidSize: json['total_bid_size'].toDouble(),
      orderbookUnitList: (json['orderbook_units'] as List).map((e) => OrderbookUnit.fromJson(e)).toList(),
      level: json['level'],
      timestamp: json['timestamp'],
      streamType: json['stream_type'],
    );
  }

  // OrderBook 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'code': code,
      'total_ask_size': totalAskSize,
      'total_bid_size': totalBidSize,
      'orderbook_units': orderbookUnitList.map((e) => e.toJson()).toList(),
      'level': level,
      'timestamp': timestamp,
      'stream_type': streamType,
    };
  }
}

class OrderbookUnit {
  final double askPrice;
  final double bidPrice;
  final double askSize;
  final double bidSize;

  OrderbookUnit({
    required this.askPrice,
    required this.bidPrice,
    required this.askSize,
    required this.bidSize,
  });

  // JSON 데이터를 OrderBookUnit 객체로 변환
  factory OrderbookUnit.fromJson(Map<String, dynamic> json) {
    return OrderbookUnit(
      askPrice: json['ask_price'].toDouble(),
      bidPrice: json['bid_price'].toDouble(),
      askSize: json['ask_size'].toDouble(),
      bidSize: json['bid_size'].toDouble(),
    );
  }

  // OrderBookUnit 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'ask_price': askPrice,
      'bid_price': bidPrice,
      'ask_size': askSize,
      'bid_size': bidSize,
    };
  }
}
