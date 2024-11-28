import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orderbook_viewer/model/v1/orderbookSnapshot.dart';

class OrderbookListView extends StatelessWidget {
  final List<PriceSize> askList;
  final List<PriceSize> bidList;

  OrderbookListView(this.askList, this.bidList);

  @override
  Widget build(BuildContext context) {
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
                  itemCount: askList.length,
                  itemBuilder: (context, index) {
                    final unit = askList[askList.length - index - 1];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          unit.price.toStringAsFixed(0),
                          style: const TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            unit.size.toStringAsFixed(4),
                            textAlign: TextAlign.end,
                            style: const TextStyle(color: Colors.black, fontSize: 18),
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
                  itemCount: bidList.length,
                  itemBuilder: (context, index) {
                    final unit = bidList[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          unit.price.toStringAsFixed(0),
                          style: const TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            unit.size.toStringAsFixed(4),
                            textAlign: TextAlign.end,
                            style: const TextStyle(color: Colors.black, fontSize: 18),
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
