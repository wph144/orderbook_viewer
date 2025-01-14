import 'package:flutter/material.dart';
import 'package:orderbook_viewer/model/common_data.dart';
import 'package:orderbook_viewer/ui/orderbook_listview.dart';
import 'package:orderbook_viewer/ui/trade_listview.dart';

class OrderBookPage extends StatefulWidget {
  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  SocketData socketDataLeft = SocketData();
  SocketData socketDataRight = SocketData();

  @override
  void initState() {
    super.initState();

    socketDataLeft = SocketData(onUpdate: () => setState(() {}));
    socketDataRight = SocketData(onUpdate: () => setState(() {}));

    resubscribe();
  }

  void resubscribe() {
    socketDataLeft.connectToV1();
    socketDataRight.connectToV2();
  }

  @override
  void dispose() {
    socketDataLeft.channel.sink.close();
    socketDataRight.channel.sink.close();
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
            Row(
              children: [
                Expanded(
                    child: Text(
                        '${socketDataLeft.displayVersionString} ${(socketDataLeft.orderbookTimestamp > socketDataRight.orderbookTimestamp ? '️' : '+${socketDataRight.orderbookTimestamp - socketDataLeft.orderbookTimestamp}ms')}')),
                Expanded(
                    child: Text(
                        '${socketDataRight.displayVersionString} ${(socketDataLeft.orderbookTimestamp < socketDataRight.orderbookTimestamp ? '️' : '+${socketDataLeft.orderbookTimestamp - socketDataRight.orderbookTimestamp}ms')}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: OrderbookListView(socketDataLeft.orderbookAskList, socketDataLeft.orderbookBidList)),
                Expanded(child: OrderbookListView(socketDataRight.orderbookAskList, socketDataRight.orderbookBidList)),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Flexible(child: TradeListView(socketDataLeft.getReversedTrades())),
                  Flexible(child: TradeListView(socketDataRight.getReversedTrades())),
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
