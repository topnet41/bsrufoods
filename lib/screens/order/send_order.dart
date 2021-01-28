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
              "https://apibsrufood.000webhostapp.com/apiNotification.php?isAdd=true&token=$value&title=$username&body=$mes");
        });
      }).toList();
    });
  }

  void sendOrder(List order,String username) async {
    order.map((e) {
      getSenduser(e["userId"],"อาหารได้แล้วบางส่วน",username);
    }).toList();
  }

  Future setdata(var e)async{
          await firestore.collection("orderDetail").doc(e["orderPath"]).update({"detail":FieldValue.arrayRemove(e["detail"])});
          await update(e);
          print("mkaflmkewfmegtmioersyngsdknguierfdlngrhkdfglnfhgkj");
  }

  Future update(var e)async{
          await firestore.collection("orderDetail").doc(e["orderPath"]).update({"detail":FieldValue.arrayUnion(e["detail"])});
  }

  void claerOrder(List order,String username){
    order.map((e) {
       var checkOrder = e["detail"].indexWhere((element) => element["status"] == false);
      if(checkOrder == -1){
          firestore.collection("orders").doc(e["orderPath"]).update({"history":true});
         firestore.collection("orderDetail").doc(e["orderPath"]).update({"detail":FieldValue.arrayRemove(e["detailSta"])}).then((value){
                firestore.collection("orderDetail").doc(e["orderPath"]).update({"detail":FieldValue.arrayUnion(e["detail"])});
           });
          getSenduser(e["userId"],"อาหารได้ครบแล้ว",username);
      }else{
           firestore.collection("orderDetail").doc(e["orderPath"]).update({"detail":FieldValue.arrayRemove(e["detailSta"])}).then((value){
                firestore.collection("orderDetail").doc(e["orderPath"]).update({"detail":FieldValue.arrayUnion(e["detail"])});
           });
          // print(e["orderPath"]);
          // print("ee == ${jsonEncode(e)}");
      }
  }).toList();
}

}
