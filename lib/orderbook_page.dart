import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orderbook_viewer/model/v1/orderbookSnapshot.dart';
import 'package:orderbook_viewer/model/v1/transaction.dart';
import 'package:orderbook_viewer/model/v2/orderbook.dart';
import 'package:orderbook_viewer/model/v2/trade.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OrderBookPage extends StatefulWidget {
  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  late WebSocketChannel channelV1;
  List<PriceSize> orderbookAskListV1 = [];
  List<PriceSize> orderbookBidListV1 = [];
  Queue<Data> tradeQueueV1 = Queue<Data>();

  late WebSocketChannel channelV2;
  List<OrderbookUnit> orderbookUnitListV2 = [];
  Queue<Trade> tradeQueueV2 = Queue<Trade>();

  // 새로운 trade 추가 (최대 10개 유지)
  void addTradeV1(List<Data> dataList) {
    print('yeonseok, addTradeV1: size : ${dataList.length}');

    final addedSize = tradeQueueV1.length + dataList.length;
    final needToRemove = addedSize - 10;

    for (int i = needToRemove; i > 0; i--) {
      tradeQueueV1.removeFirst();
    }

    tradeQueueV1.addAll(dataList);
  }

  void addTradeV2(Trade trade) {
    if (tradeQueueV2.length >= 10) {
      tradeQueueV2.removeFirst(); // 가장 오래된 항목 제거
    }
    tradeQueueV2.addLast(trade); // 새로운 항목 추가
  }

  // trade 데이터를 역순으로 가져오기
  List<Data> getReversedTradesV1() {
    return tradeQueueV1.toList().reversed.toList();
  }

  List<Trade> getReversedTradesV2() {
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
      // Uint8List로 변환
      // Uint8List uint8Data = Uint8List.fromList(encodedData);
      //
      // // UTF-8 디코딩
      // String jsonString = utf8.decode(uint8Data);
      // print(encodedData);
      final jsonMap = jsonDecode(encodedData);

      if (jsonMap['type'] == 'orderbooksnapshot') {
        final orderbook = OrderbookSnapshot.fromJson(jsonMap);
        setState(() {
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
      },
      {
        'type': 'trade',
        'codes': ['KRW-ETH']
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
          orderbookUnitListV2 = orderbook.orderbookUnitList.sublist(0, 10);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Orderbook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(child: Text("v1")),
                Expanded(child: Text("v2")),
              ],
            ),
            Row(
              children: [
                Expanded(child: orderbookListViewV1()),
                Expanded(child: orderbookListViewV2()),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Flexible(child: tradeListViewV1()),
                  Flexible(child: tradeListViewV2()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ListView tradeListViewV1() {
    return ListView.builder(
      itemCount: getReversedTradesV1().length,
      itemBuilder: (context, index) {
        final trade = getReversedTradesV1()[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              trade.contPrice,
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            SizedBox(
              width: 100,
              child: Text(
                trade.contQty,
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  ListView tradeListViewV2() {
    return ListView.builder(
      itemCount: getReversedTradesV2().length,
      itemBuilder: (context, index) {
        final trade = getReversedTradesV2()[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${trade.tradePrice.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            SizedBox(
              width: 100,
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

  Column orderbookListViewV1() {
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
                  itemCount: orderbookAskListV1.length,
                  itemBuilder: (context, index) {
                    final unit = orderbookAskListV1[orderbookAskListV1.length - index - 1];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          unit.price,
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            unit.size,
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
                  itemCount: orderbookBidListV1.length,
                  itemBuilder: (context, index) {
                    final unit = orderbookBidListV1[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          unit.price,
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            unit.size,
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

  Column orderbookListViewV2() {
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
                  itemCount: orderbookUnitListV2.length,
                  itemBuilder: (context, index) {
                    final unit = orderbookUnitListV2[orderbookUnitListV2.length - index - 1];
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
                  itemCount: orderbookUnitListV2.length,
                  itemBuilder: (context, index) {
                    final unit = orderbookUnitListV2[index];
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
