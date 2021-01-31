import 'dart:convert';

import 'package:bsrufoods/screens/menus/addmenu.dart';
import 'package:bsrufoods/screens/menus/editmenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot snapshot,menu;
  int a = 0;

  void getdata() async {
    final document = await firestore
        .collection("member")
        .doc(_firebaseAuth.currentUser.uid)
        .get();
    snapshot = document;
    final data = await snapshot["menus"].get();
    menu = data;
    a = menu["menudetail"].length;
    if(menu.exists){
        setState(() {});
    }else{
      menu = null;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  Widget showAllMenu(bool statusFood) {
    return menu == null
        ? Center(
            child: Text(
            "ยังไม่มีเมนู",
            style: TextStyle(fontSize: 24),
          ))
        : ListView.separated(
            itemCount: a,
            separatorBuilder: (context, index) => menu["menudetail"][(a-1)-index]["status"] == statusFood ? Divider() :Container(),
            itemBuilder: (context, index) {
              return menu["menudetail"][(a-1)-index]["status"] == statusFood ? ListTile(
                title: Text(menu["menudetail"][(a-1)-index]["name"]),
                trailing: menu["menudetail"][(a-1)-index]["status"] ? Text("เปิด") : Text("ปิด"),
                onTap: () { 
                  MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>Editmenu((a-1)-index, menu["menudetail"],menu["menudetail"]),);
                  Navigator.push(context, route).then((value) => setState(() {getdata();}));
                },
              ) : Container();
            });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                  Tab(
                    text: "ตัวเลือกเมนู",
                  ),
                  Tab(
                    text: "เมนูที่ปิดการขาย",
                  ),
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
            showAllMenu(true),
            showAllMenu(false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Color.fromRGBO(255, 54, 247, 1.0),
            onPressed: () {
              MaterialPageRoute route = MaterialPageRoute(
                  builder: (BuildContext context) => AddMenu());
              Navigator.push(context, route).then((value) => setState(() {getdata();}));
            }),
      ),
    );
  }
}
