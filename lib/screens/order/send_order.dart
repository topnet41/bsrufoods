import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SendOrder {
  final BuildContext _context;
  SendOrder(BuildContext context) : _context = context;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future getSenduser(String userid,String mes,String username) async {
    await firestore
        .collection("member")
        .where("userId", isEqualTo: userid)
        .get()
        .then((value) {
      value.docs.map((data) {
        data["tokenUser"].forEach((value) {
          http.get(
              "https://apinotificationbsrufood.000webhostapp.com/apiNotification.php?isAdd=true&token=$value&title=$username&body=$mes");
        });
      }).toList();
    });
  }

  void sendOrder(List order,String username) async {
    order.map((e) {
      String mes = e["nameSend"].join(',');
      getSenduser(e["userId"],"$mes ได้แล้ว",username);
    }).toList();
  }


  Future claerOrder(List order,String username)async{
   var orderclaer = order.map((e) {
       var checkOrder = e["detail"].indexWhere((element) => element["status"] == false);
      if(checkOrder == -1){
          firestore.collection("orders").doc(e["orderPath"]).update({"history":true});
           firestore.collection("orderDetail").doc(e["orderPath"]).set({"detail":FieldValue.arrayUnion(e["detail"])}).then((value){});
          getSenduser(e["userId"],"อาหารได้ครบแล้ว",username);
      }else{
           firestore.collection("orderDetail").doc(e["orderPath"]).set({"detail":FieldValue.arrayUnion(e["detail"])}).then((value){});
          // print(e["orderPath"]);
          // print("ee == ${jsonEncode(e)}");
      }
  }).toList();
  return orderclaer;
}
  
}
