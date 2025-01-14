import 'package:flutter/material.dart';
import 'package:orderbook_viewer/model/v1/orderbookSnapshot.dart';

class OrderbookListView extends StatelessWidget {
  final List<PriceSize> askList;
  final List<PriceSize> bidList;

  var fontSize = 16.0;
  var heightOfList = 230.0;

  OrderbookListView(this.askList, this.bidList);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 매도 리스트
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.blue.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: heightOfList, // 매도 리스트의 고정 높이
                child: ListView.builder(
                  itemCount: askList.length,
                  itemBuilder: (context, index) {
                    final unit = askList[askList.length - index - 1];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          unit.price.toStringAsFixed(0),
                          style: TextStyle(color: Colors.blue, fontSize: fontSize),
                        ),
                        Text(
                          unit.size.toStringAsFixed(4),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.black, fontSize: fontSize),
                        )
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.red.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: heightOfList, // 매수 리스트의 고정 높이
                child: ListView.builder(
                  itemCount: bidList.length,
                  itemBuilder: (context, index) {
                    final unit = bidList[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          unit.price.toStringAsFixed(0),
                          style: TextStyle(color: Colors.blue, fontSize: fontSize),
                        ),
                        Text(
                          unit.size.toStringAsFixed(4),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.black, fontSize: fontSize),
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
