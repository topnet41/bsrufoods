import 'dart:convert';

import 'package:bsrufoods/controller/getphoto.dart';
import 'package:bsrufoods/screens/account/review.dart';
import 'package:bsrufoods/screens/login.dart';
import 'package:bsrufoods/screens/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class Account extends StatefulWidget {
  Account({Key key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {

  FirebaseAuth firebase = FirebaseAuth.instance;

  final facebookLogin = FacebookLogin();

  var photo;

  @override
  void initState() { 
    super.initState();
       login();
  }

void login()async{
  final result = await facebookLogin.logIn(["email", "public_profile"]);
  final token = result.accessToken.token;
final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${token}');
final profile = json.decode(graphResponse.body);

  var dataphoto = Getphoto.fromJson(profile);
    setState(() {
        photo = dataphoto.picture.data.url;
    });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("บัญชีผู้ใช้", style: TextStyle(fontSize: 32.0)),
        centerTitle: true,
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            var name = [
              firebase.currentUser.displayName,
              "สถานะของร้าน",
              "การขาย",
              "รีวิว",
              "ตั้งค่า"
            ];
            var status = ["", "เปิด", "", "", ""];
            var icon = <Widget>[
              ClipOval(
                  child: photo == null ? CircularProgressIndicator() : Image.network(
                    photo,
                    width: 50,height: 50,fit: BoxFit.fill,
                  )),
              Icon(
                Icons.store,
                size: 36,
                color: Color.fromRGBO(196, 196, 196, 1.0),
              ),
              Icon(
                Icons.insert_chart,
                size: 36,
                color: Color.fromRGBO(196, 196, 196, 1.0),
              ),
              Icon(
                Icons.comment,
                size: 36,
                color: Color.fromRGBO(196, 196, 196, 1.0),
              ),
              Icon(
                Icons.settings,
                size: 36,
                color: Color.fromRGBO(196, 196, 196, 1.0),
              ),
            ];
            var subtitle = <Widget>[
              Text(
                "แก้ไขข้อูมล",
                style: TextStyle(color: Colors.green),
              ),
              null,
              null,
              null,
              null
            ];
            var page = [null, null, null, Review(), Setting()];
            return ListTile(
              leading: icon[index],
              title: Text(
                name[index],
                style: TextStyle(fontSize: 20),
              ),
              subtitle: subtitle[index],
              trailing: Text(status[index]),
              onTap: () {
                if (index == 1) {
                  
                } else {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (BuildContext context) => page[index]);
                  Navigator.push(context, route);
                }
              },
            );
          },
          separatorBuilder: (context, index) => Divider(
                color: Color.fromRGBO(196, 196, 196, 1.0),
              ),
          itemCount: 5),
    );
  }
}
