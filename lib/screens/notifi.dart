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
  List<Map> noti = [];
  void getnoti() async {
    await firestore
        .collection("orders")
        .where("shopId", isEqualTo: widget.shopid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        getorders(element.data());
      });
    });
  }

  void getorders(final data) async {
    Map<String, dynamic> order = Map();
    orderDetail = await data["detail"].get();
    order["orderId"] = data["orderId"];
    order["orderDate"] = data["orderDate"];
    order["staOrder"] = data["staOrder"];
    order["profile"] = data["profile"];
    order["userId"] = data["userId"];
    order["detail"] = orderDetail["detail"];
    setState(() {
      noti.add(order);
    });
    print(order);
  }

  @override
  void initState() {
    super.initState();
    getnoti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("การแจ้งเตือน"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              padding: EdgeInsets.all(5.0),
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60.0),
                    image: DecorationImage(
                      image: NetworkImage(noti[index]["profile"]),
                      fit: BoxFit.cover,
                    )),
              ),
            ),
            title: Text("Order-${noti[index]["orderId"]}"),
            trailing: noti[index]["staOrder"]
                ? Text(
                    "รับแล้ว",
                    style: TextStyle(color: Colors.green),
                  )
                : Text("รอการยืนยัน", style: TextStyle(color: Colors.red)),
            tileColor: noti[index]["staOrder"] ? Colors.white : Color.fromRGBO(255, 0, 0, 0.3),            
            subtitle: Text("วันที่ ${noti[index]["orderDate"]}"),
          );
        },
        
        itemCount: noti.length,
      ),
    );
  }
}
