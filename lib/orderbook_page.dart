import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orderbook_viewer/model/v1/orderbookSnapshot.dart';
import 'package:orderbook_viewer/model/v1/transaction.dart';
import 'package:orderbook_viewer/model/v2/orderbook.dart';
import 'package:orderbook_viewer/model/v2/trade.dart';
import 'package:orderbook_viewer/ui/flashing_orderbook_listview.dart';
import 'package:orderbook_viewer/ui/orderbook_listview.dart';
import 'package:orderbook_viewer/ui/trade_listview.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OrderBookPage extends StatefulWidget {
  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  late WebSocketChannel channelV1;
  int orderbookTimestampV1 = 0;
  List<PriceSize> orderbookAskListV1 = [];
  List<PriceSize> orderbookBidListV1 = [];
  Queue<PriceSize> tradeQueueV1 = Queue<PriceSize>();

  late WebSocketChannel channelV2;
  int orderbookTimestampV2 = 0;
  List<PriceSize> orderbookAskListV2 = [];
  List<PriceSize> orderbookBidListV2 = [];
  Queue<PriceSize> tradeQueueV2 = Queue<PriceSize>();

  // 새로운 trade 추가 (최대 10개 유지)
  void addTradeV1(List<Data> dataList) {
    final addedSize = tradeQueueV1.length + dataList.length;
    final needToRemove = addedSize - 10;

    for (int i = needToRemove; i > 0; i--) {
      tradeQueueV1.removeFirst();
    }

    tradeQueueV1.addAll(dataList.map((data) => PriceSize(price: data.contPrice, size: data.contQty)));
  }

  void addTradeV2(Trade trade) {
    if (tradeQueueV2.length >= 10) {
      tradeQueueV2.removeFirst(); // 가장 오래된 항목 제거
    }
    tradeQueueV2.addLast(PriceSize(price: trade.tradePrice, size: trade.tradeVolume)); // 새로운 항목 추가
  }

  // trade 데이터를 역순으로 가져오기
  List<PriceSize> getReversedTradesV1() {
    return tradeQueueV1.toList().reversed.toList();
  }

  List<PriceSize> getReversedTradesV2() {
    return tradeQueueV2.toList().reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    // WebSocket 연결

    resubscribe();
  }

  void resubscribe() {
    resubscribeV1();
    resubscribeV2();
  }

  void resubscribeV1() {
    channelV1 = WebSocketChannel.connect(
      Uri.parse('wss://pubwss.bithumb.com/pub/ws'),
    );

    channelV1.sink.add(jsonEncode({
      'type': 'orderbooksnapshot',
      'symbols': ['ETH_KRW'],
    }));
    channelV1.sink.add(jsonEncode({
      'type': 'transaction',
      'symbols': ['ETH_KRW'],
    }));

    channelV1.stream.listen((encodedData) {
      // print(encodedData);
      final jsonMap = jsonDecode(encodedData);

      if (jsonMap['type'] == 'orderbooksnapshot') {
        final orderbook = OrderbookSnapshot.fromJson(jsonMap);
        setState(() {
          orderbookTimestampV1 = orderbook.content.datetime ~/ 1000;

          orderbookAskListV1 = orderbook.content.asks.sublist(0, 10);
          orderbookBidListV1 = orderbook.content.bids.sublist(0, 10);
        });
      } else if (jsonMap['type'] == 'transaction') {
        final trade = Transaction.fromJson(jsonMap);
        setState(() {
          addTradeV1(trade.content.list);
        });
      } else {
        print('Unknown type on V1: ${encodedData}');
      }
    });
  }

  void resubscribeV2() {
    channelV2 = WebSocketChannel.connect(
      Uri.parse('wss://ws-api.bithumb.com/websocket/v1'),
    );

    channelV2.sink.add(jsonEncode([
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
    channelV2.stream.listen((encodedData) {
      // Uint8List로 변환
      Uint8List uint8Data = Uint8List.fromList(encodedData);

      // UTF-8 디코딩
      String jsonString = utf8.decode(uint8Data);
      // print(jsonString);
      final jsonMap = jsonDecode(jsonString);

      if (jsonMap['type'] == 'orderbook') {
        final orderbook = Orderbook.fromJson(jsonMap);
        setState(() {
          orderbookTimestampV2 = orderbook.timestamp;

          final orderbookUnitListV2 = orderbook.orderbookUnitList.sublist(0, 10);

          orderbookAskListV2 = orderbookUnitListV2.map((unit) => PriceSize(price: unit.askPrice, size: unit.askSize)).toList();
          orderbookBidListV2 = orderbookUnitListV2.map((unit) => PriceSize(price: unit.bidPrice, size: unit.bidSize)).toList();
        });
      } else if (jsonMap['type'] == 'trade') {
        final trade = Trade.fromJson(jsonMap);
        setState(() {
          addTradeV2(trade);
        });
      } else {
        print('Unknown type: ${jsonString}');
      }
    });
  }

  @override
  void dispose() {
    channelV2.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('yeonseok, v1: $orderbookTimestampV1');
    print('yeonseok, v2: $orderbookTimestampV2');

    return Scaffold(
      appBar: AppBar(
        title: Text('Orderbook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('v1 ${(orderbookTimestampV1 > orderbookTimestampV2 ? '️' : '+${orderbookTimestampV2 - orderbookTimestampV1}ms')}')),
                Expanded(child: Text('v2 ${(orderbookTimestampV1 < orderbookTimestampV2 ? '️' : '+${orderbookTimestampV1 - orderbookTimestampV2}ms')}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: OrderbookListView(orderbookAskListV1, orderbookBidListV1)),
                Expanded(child: OrderbookListView(orderbookAskListV2, orderbookBidListV2)),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Flexible(child: TradeListView(getReversedTradesV1())),
                  Flexible(child: TradeListView(getReversedTradesV2())),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderBookPage(),
  ));
}
