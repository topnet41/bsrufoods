import 'package:bsrufoods/screens/home/order.dart';
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
  List orderAll = [];
  Map<String, dynamic> myOrder = Map();

  bool statusBtnSend;
  @override
  void initState() {
    super.initState();
    getUser();
    statusBtnSend = false;
  }

  void sendNotification() async {
    await http.get(
        "https://apibsrufood.000webhostapp.com/apiNotification.php?isAdd=true&token=esV46vSMS2uSXFdQ_H7kX3:APA91bFYLbR4jn1yp3N7ASJLa8a5g2J3ahGQ2lc3KfnwBPgwI-FHcaGCTVPM-5W2WgCF2mW65u3Zaf3Ab930kYZ-O43OpVdffgT8PzPlhgcB3DkwHN_W49z3GE0CmHGgJKcrKhLRH0Dq&title=ร้านยายหลา&body=อาหารได้แล้วครับ");
    setState(() {
      statusBtnSend = false;
    });
  }

  void getUser() async {
    await firestore
        .collection("member")
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        shopid = value["userId"];
        getdata();
      });
    });
  }

  void getdata() async {
    await firestore
        .collection("orders")
        .where("shopId", isEqualTo: shopid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        getrefer(element.data(),element.id);
      });
    });
  }

  void getrefer(final refer,String orderid) async {
    Map<String, dynamic> myOrder = Map();
    snapshot = await refer["detail"].get();
    myOrder["orderid"] = orderid;
    myOrder["detail"] = snapshot["detail"].toList();
    for (var detail in myOrder["detail"]) {
      String options = "";
      if (detail["option"] != null) {
        for (var option in detail["option"]) {
          options = "$options ${option["name"]}";
        }
      }
      detail["option"] = options;
    }
    myOrder["history"] = refer["history"];
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
      onPressed: () {
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

  Widget showOrder() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderAll[index]["orderid"]),
                Container(
                    width: 200,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            orderAll[index]["detail"].length, (numa) {
                          return orderAll[index]["detail"][numa]["option"] == ""
                              ? Text(orderAll[index]["detail"][numa]["name"])
                               : Text(orderAll[index]["detail"][numa]["name"] +
                                  "\n (${orderAll[index]["detail"][numa]["option"]})");
                        }))),
                Text("sefse")
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
                onPressed: () {
                  Alert(
                    context: context,
                    title: "ต้องการเสิร์ฟทั้งหมด",
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
                                "เสิร์ฟ",
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
              onPressed: () {},
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
            Text("asd"),
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
