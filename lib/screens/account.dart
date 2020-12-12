import 'dart:convert';

import 'package:bsrufoods/controller/auth_controller.dart';
import 'package:bsrufoods/controller/getphoto.dart';
import 'package:bsrufoods/screens/account/review.dart';
import 'package:bsrufoods/screens/login.dart';
import 'package:bsrufoods/screens/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

class Account extends StatefulWidget {
  Account({Key key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  FirebaseAuth firebase = FirebaseAuth.instance;

  final facebookLogin = FacebookLogin();
  String statusShop = "เปิด";
  int shop = 0;
  bool statusButton;
  @override
  void initState() { 
    super.initState();
    statusButton = false;
  }

  void alertConfirm(){
      Alert(
            context: context,
            title: "ออกจากระบบ?",
            buttons: [
              DialogButton(
                onPressed:statusButton == true ? (){} : (){
                  setState(() {
                    statusButton = true;
                  });
                  logout();
                },
                child: statusButton == true ? CircularProgressIndicator() : Text(
                  "ตกลง",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                color: Color.fromRGBO(255, 0, 0, 1),
              ),
              DialogButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "ยกเลิก",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ]).show();
  }

  Future<void> logout() async {
    await facebookLogin.logOut();
    await firebase.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    var user = firebase.currentUser;
    return Scaffold(
        appBar: AppBar(
          title: Text("บัญชีผู้ใช้", style: TextStyle(fontSize: 32.0)),
          leading: Text(""),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: user.photoURL == null? Text("adas") : Image.network(user.photoURL)),
                title: user.displayName == null ? Text("asd") :Text(
                  user.displayName,
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                  "แก้ไขข้อมูล",
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.store, size: 40),
                title: Text("สถานะของร้าน"),
                trailing: Text(statusShop),
                onTap: () {
                  setState(() {
                    if (shop == 0) {
                      statusShop = "ปิด";
                      shop--;
                    } else {
                      statusShop = "เปิด";
                      shop++;
                    }
                  });
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.leaderboard, size: 40),
                title: Text("การขาย"),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.comment, size: 40),
                title: Text("รีวิว"),
                onTap: (){
                  MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>Review());
                  Navigator.of(context).push(route);
                },
              ),
              // Divider(),
              // ListTile(
              //   leading: Icon(Icons.settings, size: 40),
              //   title: Text("ตั้งค่า"),
              //   onTap: () {},
              // ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, size: 40),
                title: Text("ออกจากระบบ"),
                onTap: () {
                  alertConfirm();
                },
              )
            ],
          ),
        ));
  }
}
