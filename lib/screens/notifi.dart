import 'package:bsrufoods/screens/order/noti_menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notifi extends StatefulWidget {
  final String shopid;
  Notifi(this.shopid);
  @override
  _NotifiState createState() => _NotifiState();
}

class _NotifiState extends State<Notifi> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot orderDetail;
  String orderpath;
  List<Map> noti = [];
  void getnoti() async {
    await firestore
        .collection("orders")
        .orderBy("orderList",descending: true)
        .where("shopId", isEqualTo: widget.shopid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        getorders(element.data(),element.id);
      });
    });
  }

  void getorders(final data,String id) async {
    Map<String, dynamic> order = Map();
    orderDetail = await data["detail"].get();
    order["orderId"] = data["orderId"];
    order["orderList"] = data["orderList"];
    order["orderDate"] = data["orderDate"];
    order["status"] = {
      "staOrder":data["staOrder"],
      "history":data["history"],
      "staComent":data["staComent"],
      };
    order["cash"] = data["cash"];
    order["time"] = data["time"];
    order["image"] = data["image"];
    order["profile"] = data["profile"];
    order["userId"] = data["userId"];
    order["orderList"] = data["orderList"];
    order["detail"] = orderDetail["detail"];
    order["orderpath"] = id;
    setState(() {
      noti.add(order);
      noti.sort((m1,m2)=>m2["orderList"].compareTo(m1["orderList"]));
      noti.forEach((element) {
        print(element["orderList"]);
      });
    });
    print(order);
  }

  @override
  void initState() {
    super.initState();
    getnoti();
  }

  Future refres()async{
      setState(() {
        noti =[];
      });
      getnoti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("การแจ้งเตือน"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
            onRefresh: refres,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.all(
                  Radius.circular(30.0)
                )),
                width: 50,height: 50
                ,child: Center(child: Icon(Icons.store,color: Colors.white,)),
                ),
              title: Text("Order-${noti[index]["orderId"]}"),
              trailing: noti[index]["status"]["staOrder"]
                  ? Text(
                      "รับแล้ว",
                      style: TextStyle(color: Colors.green),
                    )
                  : Text("รอการยืนยัน", style: TextStyle(color: Colors.red)),
              tileColor: noti[index]["status"]["staOrder"] ? Colors.white : Color.fromRGBO(255, 0, 0, 0.3),            
              subtitle: Text("วันที่ ${noti[index]["orderDate"]}"),
              onTap: (){
                MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>NotiMenu(noti[index]["userId"],noti[index]["orderpath"], noti[index]));
                Navigator.push(context, route).then((value){setState(() {
                  noti = [];
                  getnoti();
                });});
                // print(noti[index]["userId"]);
              },
            );
          },
          
          itemCount: noti.length,
        ),
      ),
    );
  }
}
