import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bsrufoods/screens/order/kbank.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotiMenu extends StatefulWidget {
  final String shopId;
  final String orderpath;
  final Map<String, dynamic> order;
  NotiMenu(this.shopId, this.orderpath, this.order);

  @override
  _NotiMenuState createState() => _NotiMenuState();
}

class _NotiMenuState extends State<NotiMenu> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic> dataShop = Map();
  int total = 0;
  void getShop() async {
    await firestore
        .collection("member")
        .where("userId", isEqualTo: widget.shopId)
        .get()
        .then((value) {
      setState(() {
        value.docs
            .map((QueryDocumentSnapshot e) => dataShop.addAll(e.data()))
            .toList();
        print(dataShop);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    widget.order["detail"].map((pice) {
      total = total + pice["price"] * pice["count"];
      setState(() {});
    }).toList();
    getShop();
    print("id = ${widget.order}");
  }

  confirmOrder() async {
    await firestore
        .collection("orders")
        .doc(widget.orderpath)
        .update({"staOrder": true});
    dataShop["tokenUser"].forEach((value) {
      http.get(
          "https://apibsrufood.000webhostapp.com/apiNotification.php?isAdd=true&token=$value&title=${dataShop["username"]}&body=ออเดอร์ยืนยันแล้ว");
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ข้อมูลออเดอร์"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: dataShop.length < 1
                    ? CircularProgressIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${dataShop['username']}",
                                style: TextStyle(fontSize: 24),
                              ),
                              Text("${widget.order["cash"]}"),
                            ],
                          ),
                          Text("เบอร์โทรลูกค้า ${dataShop['phone']}"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("หมายเลขออเดอร์ ${widget.order["orderId"]}"),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: widget.order["cash"] == "โอนเงิน"
                                    ? RaisedButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          "ดูสลิป",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>Kbank(widget.order["image"]));
                                          Navigator.push(context, route);
                                        })
                                    : Container(),
                              )
                            ],
                          ),
                        ],
                      ),
              ),
              Container(
                width: double.infinity,
                height: 40,
                color: Color.fromRGBO(196, 196, 196, 1),
                child: Center(
                    child: Text(
                        "เวลารับ : ${widget.order["time"] == null ? 'ไม่ระบุ' : widget.order["time"]}  สถานะ : " +
                            "${widget.order["status"]["staOrder"] ? widget.order["status"]["history"] ? widget.order["status"]["staComent"] ? 'เรียบร้อย' : 'อาหารครบแล้วรอรีวิว' : 'กำลังทำอาหาร' : 'รอการยืนยัน'}")),
              ),
              Text(
                "รายการอาหาร",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.order["detail"].length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 135,
                                child: Text(
                                    "${index + 1}. ${widget.order["detail"][index]["name"]}")),
                            Text("x${widget.order["detail"][index]["count"]}"),
                            Text(
                                "${widget.order["detail"][index]["price"] * widget.order["detail"][index]["count"]} บาท")
                          ],
                        ),
                      );
                    }),
              ),
              Container(
                padding: EdgeInsets.all(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "รวมเป็นเงิน",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "$total",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              !widget.order["status"]["staOrder"]
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 50,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            "ยืนยันออเดอร์",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            confirmOrder();
                          }),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
