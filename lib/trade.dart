class Trade {
  final String type;
  final String code;
  final double tradePrice;
  final double tradeVolume;
  final String askBid;
  final double prevClosingPrice;
  final String change;
  final double changePrice;
  final String tradeDate;
  final String tradeTime;
  final int tradeTimestamp;
  final int sequentialId;
  final int timestamp;
  final String streamType;

  Trade({
    required this.type,
    required this.code,
    required this.tradePrice,
    required this.tradeVolume,
    required this.askBid,
    required this.prevClosingPrice,
    required this.change,
    required this.changePrice,
    required this.tradeDate,
    required this.tradeTime,
    required this.tradeTimestamp,
    required this.sequentialId,
    required this.timestamp,
    required this.streamType,
  });

  // JSON 데이터를 Trade 객체로 변환
  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      type: json['type'],
      code: json['code'],
      tradePrice: json['trade_price'].toDouble(),
      tradeVolume: json['trade_volume'].toDouble(),
      askBid: json['ask_bid'],
      prevClosingPrice: json['prev_closing_price'].toDouble(),
      change: json['change'],
      changePrice: json['change_price'].toDouble(),
      tradeDate: json['trade_date'],
      tradeTime: json['trade_time'],
      tradeTimestamp: json['trade_timestamp'],
      sequentialId: json['sequential_id'],
      timestamp: json['timestamp'],
      streamType: json['stream_type'],
    );
  }

  // Trade 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'code': code,
      'trade_price': tradePrice,
      'trade_volume': tradeVolume,
      'ask_bid': askBid,
      'prev_closing_price': prevClosingPrice,
      'change': change,
      'change_price': changePrice,
      'trade_date': tradeDate,
      'trade_time': tradeTime,
      'trade_timestamp': tradeTimestamp,
      'sequential_id': sequentialId,
      'timestamp': timestamp,
      'stream_type': streamType,
    };
  }
}
