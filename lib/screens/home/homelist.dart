import 'dart:convert';

import 'package:bsrufoods/screens/home/order.dart';
import 'package:bsrufoods/screens/order/send_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class Homelist extends StatefulWidget {
  @override
  _HomelistState createState() => _HomelistState();
}

class _HomelistState extends State<Homelist> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot snapshot;
  String shopid;
  String username;
  List orderAll = [];
  List orderSend = [];
  SendOrder sendOrder;
  bool statusBtnSend;
  @override
  void initState() {
    super.initState();
    getUser();
    sendOrder = SendOrder(context);
    statusBtnSend = false;
  }

  void sendNotification() async {
    sendOrder.sendOrder(orderSend,username);
    setState(() {
      statusBtnSend = false;
    });
  }

  void claer() async {
    sendOrder.claerOrder(orderSend,username);
    setState(() {
       orderAll = [];
       orderSend = [];
      statusBtnSend = false;
    });
      await getdata();
  }

  void getUser() async {
    await firestore
        .collection("member")
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        shopid = value["userId"];
        username = value["username"];
        getdata();
      });
    });
  }

  Future getdata() async {
    await firestore
        .collection("orders")
        .where("shopId", isEqualTo: shopid)
        .where("staOrder", isEqualTo: true)
        .where("history", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        getrefer(element.data(), element.id);
      });
    });
  }

  void getrefer(final refer, String orderid) async {
    Map<String, dynamic> myOrder = Map();
    snapshot = await refer["detail"].get();
    myOrder["orderId"] = refer["orderId"];
    myOrder["userId"] = refer["userId"];
    myOrder["orderPath"] = orderid;
    myOrder["detail"] = snapshot["detail"].toList();
    myOrder["detailSta"] = snapshot["detail"].toList();
    myOrder["history"] = refer["history"];
    myOrder["time"] = refer["time"];
    myOrder["staComent"] = refer["staComent"];
    myOrder["staOrder"] = refer["staOrder"];
    myOrder["time"] = refer["time"];
    setState(() {
      orderAll.add(myOrder);
    });
    print(orderAll);
  }

  Widget buttonmenu() {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed:  () {
        MaterialPageRoute route =
            MaterialPageRoute(builder: (BuildContext context) => Order());
        Navigator.push(context, route);
      },
      tooltip: 'increment',
      label: Text("รับออเดอร์"),
      backgroundColor: Color.fromRGBO(255, 51, 247, 1),
    );
  }

  Widget buttonlist() {
    return FloatingActionButton.extended(
      onPressed: null,
      heroTag: null,
      tooltip: 'increment',
      label: Text("ประวัติการส่ง"),
      backgroundColor: Color.fromRGBO(255, 51, 247, 1),
    );
  }

  Widget showOrderTime() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return orderAll[index]["time"] == null ? Container(): Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(orderAll[index]["orderId"],style: TextStyle(fontSize: 18.0),),
                   orderAll[index]["time"] == null ? Text("") :Text("เวลารับ ${orderAll[index]["time"].toString()}"),
                  ],
                ),
                Container(
                    width: 200,
                    child: Column(
                        children: List.generate(
                            orderAll[index]["detail"].length, (numa) {
                      return orderAll[index]["detailSta"][numa]["status"] ? Container() : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(orderAll[index]["detail"][numa]["name"],style: TextStyle(fontSize: 18.0),),
                          Row(
                            children: [
                          Text("X${orderAll[index]["detail"][numa]["count"]}",style: TextStyle(fontSize: 18.0),),
                              Checkbox(
                    value: orderAll[index]["detail"][numa]["status"],
                    onChanged: (bool value) {
                      setState(() {
                        orderAll[index]["detail"][numa]["status"] = value;
                        if(value){
                          var check = orderSend.indexWhere((element) => element["userId"] == orderAll[index]["userId"]);
                          orderSend.add(orderAll[index]);
                          
                        }else{
                          orderSend.remove(orderAll[index]);
                        }
                        
                        print(jsonEncode(orderSend));
                      });
                    },
                  ),
                            ],
                          )
                        ],
                      );
                    }))),
                
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => orderAll[index]["time"] == null ? Container() : Divider(),
        itemCount: orderAll.length);
  }

  Widget showOrder() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(orderAll[index]["orderId"],style: TextStyle(fontSize: 18.0),),
                   orderAll[index]["time"] == null ? Text("") :Text("เวลารับ ${orderAll[index]["time"].toString()}"),
                  ],
                ),
                Container(
                    width: 200,
                    child: Column(
                        children: List.generate(
                            orderAll[index]["detail"].length, (numa) {
                      return orderAll[index]["detailSta"][numa]["status"] ? Container() : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(orderAll[index]["detail"][numa]["name"],style: TextStyle(fontSize: 18.0),),
                          Row(
                            children: [
                          Text("X${orderAll[index]["detail"][numa]["count"]}",style: TextStyle(fontSize: 18.0),),
                              Checkbox(
                    value: orderAll[index]["detail"][numa]["status"],
                    onChanged: (bool value) {
                      setState(() {
                        orderAll[index]["detail"][numa]["status"] = value;
                        if(value){
                          var check = orderSend.indexWhere((element) => element["userId"] == orderAll[index]["userId"]);
                          orderSend.add(orderAll[index]);
                          
                        }else{
                          orderSend.remove(orderAll[index]);
                        }
                        
                        print(jsonEncode(orderSend));
                      });
                    },
                  ),
                            ],
                          )
                        ],
                      );
                    }))),
                
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: orderAll.length);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actionsIconTheme: IconThemeData(color: Colors.white, size: 28),
          leading: Text(""),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.send,
                ),
                onPressed: orderSend.length == 0 ? null : () {
                  Alert(
                    context: context,
                    title: "ต้องการส่ง",
                    buttons: [
                      DialogButton(
                        onPressed: statusBtnSend
                            ? () {}
                            : () {
                                setState(() {
                                  statusBtnSend = true;
                                });
                                sendNotification();
                                Navigator.pop(context);
                              },
                        child: statusBtnSend
                            ? CircularProgressIndicator()
                            : Text(
                                "ส่ง",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                        color: Color.fromRGBO(255, 51, 247, 1),
                      ),
                    ],
                  ).show();
                }),
            IconButton(
              icon: Icon(
                Icons.cancel,
              ),
              onPressed: orderSend.length == 0 ? null : () {
                Alert(
                    context: context,
                    title: "ต้องการเคลียรายการ",
                    buttons: [
                      DialogButton(
                        onPressed: statusBtnSend
                            ? () {}
                            : () {
                                setState(() {
                                  statusBtnSend = true;
                                });
                                claer();
                                Navigator.pop(context);
                              },
                        child: statusBtnSend
                            ? CircularProgressIndicator()
                            : Text(
                                "เคลีย",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                        color: Color.fromRGBO(255, 51, 247, 1),
                      ),
                    ],
                  ).show();
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(65),
            child: Material(
              color: Color.fromRGBO(196, 196, 196, 1),
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Color.fromRGBO(255, 51, 247, 1.0),
                    labelStyle: TextStyle(fontSize: 18.0),
                    isScrollable: true,
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      Tab(
                        text: "ทั้งหมด",
                      ),
                      Tab(
                        text: "มีเวลารับ",
                      ),
                      Tab(
                        text: "รายการที่ซ้ำกัน",
                      ),
                    ],
                  ),
                  Material(
                    color: Color.fromRGBO(210, 210, 210, 1.0),
                    textStyle: TextStyle(fontSize: 16.0, color: Colors.black),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0, left: 12.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ลำดับคิว"),
                            Text("รายการอาหาร"),
                            Text("จำนวน"),
                          ]),
                    ),
                  )
                ],
              ),
            ),
          ),
          title: Text(
            "BSRU FOOD",
            style: TextStyle(fontSize: 32.0),
          ),
        ),
        body: TabBarView(
          children: [
            showOrder(),
            showOrderTime(),
            Text("asd"),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buttonmenu(),
            Padding(padding: EdgeInsets.only(right: 8)),
            buttonlist(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
