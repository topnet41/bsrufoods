import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderGetQr extends StatefulWidget {
  final String qrString;
  final String shopid;
  OrderGetQr(this.qrString, this.shopid);
  @override
  _OrderGetQrState createState() => _OrderGetQrState();
}

class _OrderGetQrState extends State<OrderGetQr> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map documents;
  int total = 0;
  var now = DateTime.now();
  Future getcart() async {
    var data = await firestore.collection("qrcode").doc(widget.qrString).get();
    setState(() {
      documents = data.data();
      data["detail"].map((e) {
        total = total + e["price"] * e["count"];
      }).toList();
    });
  }

  Future addmenu(Map cart, String shopid) async {
    final documents = await firestore.collection("orders").get();
    int orders = documents.docChanges.length + 1;
    String orderId = orders.toString();
    Random random = Random();
    int i = random.nextInt(1000);
    List detail = [];
    DocumentReference ref =
        firestore.collection('orderDetail').doc("O$orderId");
    cart["detail"].forEach((element) {
      Map<String, dynamic> detailMap = Map();
      detailMap["name"] = element["name"];
      detailMap["price"] = element["price"];
      detailMap["count"] = element["count"];
      detailMap["name"] = element["name"];
      detailMap["status"] = element["status"];
      detailMap["option"] = [];
      detail.add(detailMap);
    });
    Map<String, dynamic> order = Map();
    order["cash"] = "จ่ายเงินหน้าร้าน";
    order["detail"] = ref;
    order["history"] = false;
    order["orderDate"] = "${now.day}/${now.month}/${now.year}";
    order["orderList"] = int.parse(orderId) ;
    order["orderId"] = "$i";
    order["shopId"] = "$shopid";
    order["staComent"] = false;
    order["staOrder"] = true;
    order["image"] = null;
    order["time"] = null;
    order["userId"] = "${cart["userId"]}";
    await firestore.collection("orders").doc("O$orderId").set(order);
    await firestore.collection("qrcode").doc("${widget.qrString}").update({"status":true});
    await firestore
        .collection("orderDetail")
        .doc("O$orderId")
        .set({"detail": FieldValue.arrayUnion(detail)});
    print(order);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    getcart();
  }

  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ข้อมูลออเดอร์"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "รายการอาหาร",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: documents == null ? 0 : documents["detail"].length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 135,
                                child: Text(
                                    "${index + 1}. ${documents["detail"][index]["name"]}")),
                            Text("x${documents["detail"][index]["count"]}"),
                            Text(
                                "${documents["detail"][index]["price"] * documents["detail"][index]["count"]} บาท")
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
              SizedBox(
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
                      addmenu(documents, widget.shopid);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
