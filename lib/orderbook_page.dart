import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orderbook_viewer/orderbook.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'trade.dart';

class OrderBookPage extends StatefulWidget {
  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  late WebSocketChannel channel;
  List<OrderbookUnit> orderbookUnitList = [];
  List<Trade> tradeList = [];

  Queue<Trade> tradeQueue = Queue<Trade>();

  // 새로운 trade 추가 (최대 10개 유지)
  void addTrade(Trade trade) {
    if (tradeQueue.length >= 10) {
      tradeQueue.removeFirst(); // 가장 오래된 항목 제거
    }
    tradeQueue.addLast(trade); // 새로운 항목 추가
  }

  // trade 데이터를 역순으로 가져오기
  List<Trade> getReversedTrades() {
    return tradeQueue.toList().reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    // WebSocket 연결

    resubscribe();
  }

  void resubscribe() {
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
      },
      {
        'type': 'trade',
        'codes': ['KRW-ETH']
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
        setState(() {
          orderbookUnitList = orderbook.orderbookUnitList.sublist(0, 10);
        });
      } else if (jsonMap['type'] == 'trade') {
        final trade = Trade.fromJson(jsonMap);
        setState(() {
          addTrade(trade);
        });
      } else {
        print('Unknown type: ${jsonString}');
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orderbook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 190,
              child: orderbookListView(),
            ),
            SizedBox(
              width: 130,
              child: tradeListView(),
            ),
          ],
        ),
      ),
    );
  }

  ListView tradeListView() {
    return ListView.builder(
      itemCount: getReversedTrades().length,
      itemBuilder: (context, index) {
        final trade = getReversedTrades()[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${trade.tradePrice.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${trade.tradeVolume.toStringAsFixed(4)}',
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  Column orderbookListView() {
    return Column(
      children: [
        // 매도 리스트
        Container(
          color: Colors.blue.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 260, // 매도 리스트의 고정 높이
                child: ListView.builder(
                  itemCount: orderbookUnitList.length,
                  itemBuilder: (context, index) {
                    final unit = orderbookUnitList[orderbookUnitList.length - index - 1];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${unit.askPrice.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${unit.askSize.toStringAsFixed(4)}',
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 매수 리스트
        Container(
          color: Colors.red.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 260, // 매수 리스트의 고정 높이
                child: ListView.builder(
                  itemCount: orderbookUnitList.length,
                  itemBuilder: (context, index) {
                    final unit = orderbookUnitList[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${unit.bidPrice.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${unit.bidSize.toStringAsFixed(4)}',
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderBookPage(),
  ));
}
