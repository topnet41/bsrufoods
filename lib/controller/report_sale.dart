
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportSale{
  FirebaseFirestore firestore  = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List data = [];
  List data_report = [];
  List menus = [];
  var snpapshop;

  Future<List> getMenu()async{
    var menu;
    menu = await firestore.collection("menus").doc(_firebaseAuth.currentUser.uid).get();
    menus = menu["menudetail"];
    return menus;
  }

  Future<List> getdata(String shopid)async{
    List dataReport = [] ;
    QuerySnapshot datalop;
    datalop = await firestore
      .collection("orders")
      .orderBy("orderList", descending: false)
      .where("shopId", isEqualTo: shopid)
      .get();
      datalop.docs.forEach((element)async{
            Map dataMap = Map();
            dataMap = element.data();
            snpapshop = await element["detail"].get();
            dataMap["detail"] =  snpapshop["detail"];
            dataReport.add(dataMap);
            data = dataReport;
      });
    data.sort((m1,m2)=>m1["orderList"].compareTo(m2["orderList"]));
    return data;
  }

  Future<List> reportDaily(String date)async{
      int indexWhere = 0 ;
      int count ;
      menus.clear();
      await getMenu();
      data.forEach((order) {
        if(date == order["orderDate"]){
        int count_report = 0;
        num price_report = 0;
        // print(date);
          order["detail"].forEach((orderDetail){
            indexWhere = menus.indexWhere((food) => food["name"] == orderDetail["name"]);
            if(indexWhere != -1){
              count = orderDetail["count"];
              count_report = menus[indexWhere]["count"] == null ? menus[indexWhere]["count"] = count : (count + menus[indexWhere]["count"]);
              price_report = (count_report * menus[indexWhere]["price"]);
              menus[indexWhere]["price_report"] = price_report;
              menus[indexWhere]["count_report"] = count_report;
            }
          });
        }
      });
    return menus;
  }

}

class PopulationData {
  int year;
  int population;
  charts.Color barColor;
  PopulationData({
    @required this.year, 
    @required this.population,
    @required this.barColor
  });
}