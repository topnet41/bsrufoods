import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, child: Scaffold(
      appBar: AppBar(
      centerTitle: true,
      leading: Text(""),
      bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Material(
                color: Color.fromRGBO(196, 196, 196, 1.0),
                              child: TabBar(
          indicatorColor: Color.fromRGBO(255, 54, 247, 1.0),
          labelStyle: TextStyle(fontSize: 18.0),
          unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(text: "ตัวเลือกเมนู",),
                    Tab(text: "เมนูที่ปิด",),
                  ],
                ),
              ),
      ),
      title:  Text(
        "BSRU FOOD",
        style: TextStyle(fontSize: 32.0),
      ),
    ),
    body: TabBarView(
            children: [
              Icon(Icons.history),
              Icon(Icons.directions_transit),
      ],)
    ,)
    ,);
  }
}