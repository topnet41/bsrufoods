import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool cash = true;
  final count = TextEditingController();

  void getCash() async {
       await firestore
        .collection("member")
        .doc(firebaseAuth.currentUser.uid)
        .get().then((value){
          setState(() {
            cash = value["cash"];
            count.text = value["orderCount"].toString();
          });
          
        });
  }

  void alertNotfould() {
    Alert(context: context, title: "กรุณาเพิ่มจำนวน", buttons: [
      DialogButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "ตกลง",
          style: TextStyle(color: Colors.white),
        ),
        color: Color.fromRGBO(255, 51, 247, 1),
      ),
    ]).show();
  }

  void changecash()async{
    Map<String,dynamic> map = Map();
    num countNum = int.parse(count.text);
    map["cash"]= cash;
    map["orderCount"] = countNum;
      if(count.text=="" || count.text=="0"){
        alertNotfould();
      }else{
        await firestore
        .collection("member")
        .doc(firebaseAuth.currentUser.uid)
        .update(map).then((value){
          Navigator.pop(context);
        });
      }
  }

  @override
  void initState() {
    super.initState();
    getCash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 242, 245, 1.0),
      appBar: AppBar(
        title: Text("ตั้งค่า"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(right: 5.0, left: 5.0),
        child: Column(
          children: [
            Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "เปิดรับเงินสด",
                      style: TextStyle(fontSize: 18),
                    ),
                    Switch(value: cash, onChanged: (value){
                        setState(() {
                          value ? cash = true : cash = false ;
                        });
                    })
                  ],
                ),
              ),
            ),
            !cash ? Text("") : Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                    controller: count,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "ระบุราคาสั่งซื้อ")),
              ),
            ),
            Text("การเปิดรับเงินสดกรุณาจำกัดราคาในการสั่ง \n ตัวอย่างสั่งได้ไม่เกิน 200 บาท",textAlign: TextAlign.center,),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(child: Row(mainAxisSize: MainAxisSize.min,children: [
                Icon(Icons.cloud_download,size: 28.0,color: Colors.white),
                Padding(padding: EdgeInsets.only(right:7.0)),
                Text("บันทึกการตั้งค่า",style: TextStyle(color: Colors.white),)
              ],),onPressed: ()=>changecash()),
            )
          ],
        ),
      ),
    );
  }
}
