import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:orderbook_viewer/model/v1/transaction.dart';
import 'package:orderbook_viewer/model/v2/orderbook.dart';
import 'package:orderbook_viewer/model/v2/trade.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'v1/orderbookSnapshot.dart';

class SocketData {
  late WebSocketChannel channel;
  int orderbookTimestamp = 0;
  List<PriceSize> orderbookAskList = [];
  List<PriceSize> orderbookBidList = [];
  Queue<PriceSize> tradeQueue = Queue<PriceSize>();

  void Function()? onUpdate;

  SocketData({this.onUpdate});

  void connectToV1() {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://pubwss.bithumb.com/pub/ws'),
    );

    channel.sink.add(jsonEncode({
      'type': 'orderbooksnapshot',
      'symbols': ['ETH_KRW'],
    }));
    channel.sink.add(jsonEncode({
      'type': 'transaction',
      'symbols': ['ETH_KRW'],
    }));

    channel.stream.listen((encodedData) {
      // print(encodedData);
      final jsonMap = jsonDecode(encodedData);

      if (jsonMap['type'] == 'orderbooksnapshot') {
        final orderbook = OrderbookSnapshot.fromJson(jsonMap);

        orderbookTimestamp = orderbook.content.datetime ~/ 1000;

        orderbookAskList = orderbook.content.asks.sublist(0, 10);
        orderbookBidList = orderbook.content.bids.sublist(0, 10);

        onUpdate?.call();
      } else if (jsonMap['type'] == 'transaction') {
        final trade = Transaction.fromJson(jsonMap);
        addTrade(trade.content.list.map((data) => PriceSize(price: data.contPrice, size: data.contQty)).toList());

        onUpdate?.call();
      } else {
        print('Unknown type on V1: ${encodedData}');
      }
    });
  }

  void connectToV2() {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://ws-api.bithumb.com/websocket/v1'),
    );

    channel.sink.add(jsonEncode([
      {
        "ticket": "test example", // 티켓 정보
      },
      {
        'type': 'orderbook',
        'codes': ['KRW-ETH'],
        'isOnlyRealtime': true
      },
      {
        'type': 'trade',
        'codes': ['KRW-ETH'],
        'isOnlyRealtime': true
      },
    ]));

    // 데이터 수신
    channel.stream.listen((encodedData) {
      // Uint8List로 변환
      Uint8List uint8Data = Uint8List.fromList(encodedData);

      // UTF-8 디코딩
      String jsonString = utf8.decode(uint8Data);
      // print(jsonString);
      final jsonMap = jsonDecode(jsonString);

      if (jsonMap['type'] == 'orderbook') {
        final orderbook = Orderbook.fromJson(jsonMap);
        orderbookTimestamp = orderbook.timestamp;

        final orderbookUnitListV2 = orderbook.orderbookUnitList.sublist(0, 10);

        orderbookAskList =
            orderbookUnitListV2.map((unit) => PriceSize(price: unit.askPrice, size: unit.askSize)).toList();
        orderbookBidList =
            orderbookUnitListV2.map((unit) => PriceSize(price: unit.bidPrice, size: unit.bidSize)).toList();

        onUpdate?.call();
      } else if (jsonMap['type'] == 'trade') {
        final trade = Trade.fromJson(jsonMap);
        addTrade([PriceSize(price: trade.tradePrice, size: trade.tradeVolume)]);

        onUpdate?.call();
      } else {
        print('Unknown type: ${jsonString}');
      }
    });
  }

  // trade 데이터를 역순으로 가져오기
  List<PriceSize> getReversedTrades() {
    return tradeQueue.toList().reversed.toList();
  }

  // 새로운 trade 추가 (최대 10개 유지)
  void addTrade(List<PriceSize> dataList) {
    final addedSize = tradeQueue.length + dataList.length;
    final needToRemove = addedSize - 10;

    for (int i = needToRemove; i > 0; i--) {
      tradeQueue.removeFirst();
    }

    tradeQueue.addAll(dataList);
  }
}
