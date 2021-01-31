import 'package:flutter/material.dart';


class History extends StatefulWidget {
  final List orderAll;
  History(this.orderAll);
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  Widget showOrder() {
    return  ListView.separated(
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.orderAll[index]["orderId"],
                            style: TextStyle(fontSize: 18.0),
                          ),
                          widget.orderAll[index]["time"] == null
                              ? Text("")
                              : Text(
                                  "เวลารับ ${widget.orderAll[index]["time"].toString()}"),
                        ],
                      ),
                      Container(
                          width: 200,
                          child: Column(
                              children: List.generate(
                                  widget.orderAll[index]["detail"].length, (numa) {
                            return !widget.orderAll[index]["detailSta"][numa]["status"]
                                ? Container()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            widget.orderAll[index]["detail"][numa]
                                                ["name"],
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "X${widget.orderAll[index]["detail"][numa]["count"]}",
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                          }))),
                    ],
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: widget.orderAll.length);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ประวัติการส่ง"),),
      body: showOrder(),
    );
  }
}