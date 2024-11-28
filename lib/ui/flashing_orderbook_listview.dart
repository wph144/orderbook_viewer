import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orderbook_viewer/model/v1/orderbookSnapshot.dart';

class FlashingOrderbookListView extends StatefulWidget {
  final List<PriceSize> askList;
  final List<PriceSize> bidList;

  FlashingOrderbookListView(this.askList, this.bidList);

  @override
  _FlashingOrderbookListViewState createState() => _FlashingOrderbookListViewState();
}

class _FlashingOrderbookListViewState extends State<FlashingOrderbookListView> {
  Map<double, double> prevAskMap = {};
  Map<double, double> prevBidMap = {};

  @override
  void didUpdateWidget(covariant FlashingOrderbookListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.askList.forEach((element) {
      prevAskMap[element.price] = element.size;
    });
    oldWidget.bidList.forEach((element) {
      prevBidMap[element.price] = element.size;
    });
  }

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
                height: 260, // 매도 리스트의 고정 높이
                child: ListView.builder(
                  itemCount: widget.askList.length,
                  itemBuilder: (context, index) {
                    final unit = widget.askList[widget.askList.length - index - 1];
                    final flashing = prevAskMap.containsKey(unit.price) && prevAskMap[unit.price] != unit.size;

                    final view = Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          unit.price.toStringAsFixed(0),
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        Text(
                          unit.size.toStringAsFixed(4),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    );

                    if (flashing) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        color: Colors.blue.withOpacity(0.5),
                        child: view,
                      );
                    } else {
                      return view;
                    }
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
                height: 260, // 매수 리스트의 고정 높이
                child: ListView.builder(
                  itemCount: widget.bidList.length,
                  itemBuilder: (context, index) {
                    final unit = widget.bidList[index];
                    final flashing = prevBidMap.containsKey(unit.price) && prevBidMap[unit.price] != unit.size;

                    final view = Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          unit.price.toStringAsFixed(0),
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        Text(
                          unit.size.toStringAsFixed(4),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    );

                    if (flashing) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 100),
                        color: Colors.red.withOpacity(0.3),
                        child: view,
                      );
                    } else {
                      return view;
                    }
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
