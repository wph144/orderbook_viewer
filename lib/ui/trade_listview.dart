import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orderbook_viewer/model/v1/orderbookSnapshot.dart';

class TradeListView extends StatelessWidget {
  List<PriceSize> tradeList;

  TradeListView(this.tradeList);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        itemCount: tradeList.length,
        itemBuilder: (context, index) {
          final trade = tradeList[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trade.price.toStringAsFixed(0),
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                trade.size.toStringAsFixed(4),
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
  }
}
