import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:badges/badges.dart';
import 'package:http/http.dart' as http;
import 'mydata.dart';

class Homelist extends StatefulWidget {
  @override
  _HomelistState createState() => _HomelistState();
}

class _HomelistState extends State<Homelist> {
 
  dynamic url = "https://apibsrufood.000webhostapp.com/data.json";

  @override
  void initState() { 
    super.initState();
    loadData();
  }

  List<MyData> myAllData = [];

  void loadData()async{
       var response = await http.get(url);
       String stringjson = utf8.decode(response.bodyBytes);
      if(response.statusCode == 200){
        var data = json.decode(stringjson);
        //print(stringjson);

        myAllData = (data as List<dynamic>).map((item) => MyData.fromMap(item)).toList();
        
        setState(() {
          myAllData.forEach((orderdata) {
              // print(orderdata.orderids);
          });
        });
      }else{
        print('no where');
      }
  }

  Widget showText(MyData data, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Text((data.orderid).toString()),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.detail.map((order) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.name),
                    Checkbox(
                      value: order.status,
                      onChanged: (bool value) {
                        setState(() {
                          order.status = value;
                          print(order.name);
                        });
                      }),
                  ],
                );
              }).toList(),
            ),
          ),
          
        // Expanded(child: Center(child: Text("asxx"))),
        // 
        ]),
    );
  }

  Widget buttonmenu() {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () {
        Alert(
            context: context,
            title: "รับออเดอร์",
            content: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.restaurant_menu),
                    labelText: 'กรอกหมายเลขออเดอร์',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            buttons: [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "ตกลง",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                color: Color.fromRGBO(255, 51, 247, 1),
              ),
            ]).show();
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

  Widget listfood() {
    return Container(
      // padding: EdgeInsets.only(left: 12.0),
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Color.fromRGBO(255, 51, 247, 1),
        ),
        itemCount: myAllData.length,
        itemBuilder: (context, int index) => showText(myAllData[index], index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actionsIconTheme: IconThemeData(color: Colors.white, size: 28),
          leading: Badge(
            badgeContent: Text('3'),
            toAnimate: true,
            position: BadgePosition(top: -1,start: 33),
            child: IconButton(
                icon: Icon(
                  Icons.notifications,
                ),
                onPressed: (){},
            )
          ),
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
                          desc: "Flutter is awesome.")
                      .show();
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
                        text: "รับทันที",
                      ),
                      Tab(
                        text: "สั่งล่วงหน้า",
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
                      padding: const EdgeInsets.only(right:12.0,left: 12.0),
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
            myAllData.length == 0 
            ? Center(child: CircularProgressIndicator(),)
            : listfood(),
            listfood(),
            listfood(),
            listfood(),
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
