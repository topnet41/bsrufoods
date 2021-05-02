import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportSale {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List data = [];
  List<PopulationData> data_report = [];
  List menus = [];
  var snpapshop;

  Future<List> getMenu() async {
    var menu;
    menu = await firestore
        .collection("menus")
        .doc(_firebaseAuth.currentUser.uid)
        .get();
    menus = menu["menudetail"];
    return menus;
  }

  Future<List> getdata(String shopid) async {
    List dataReport = [];
    QuerySnapshot datalop;
    datalop = await firestore
        .collection("orders")
        .orderBy("orderList", descending: false)
        .where("shopId", isEqualTo: shopid)
        .get();
    datalop.docs.forEach((element) async {
      Map dataMap = Map();
      dataMap = element.data();
      snpapshop = await element["detail"].get();
      dataMap["detail"] = snpapshop["detail"];
      dataReport.add(dataMap);
      data = dataReport;
    });
    data.sort((m1, m2) => m1["orderList"].compareTo(m2["orderList"]));
    return data;
  }

  Future<List> reportDaily(String date) async {
    int indexWhere = 0;
    int index = 0;
    int count;
    menus.clear();
    await getMenu();
    data.forEach((order)async{
      if (date == order["orderDate"]) {
        int count_report = 0;
        num price_report = 0;
        // print(date);
        await order["detail"].forEach((orderDetail) {
          indexWhere =
              menus.indexWhere((food) => food["name"] == orderDetail["name"]);
          if (indexWhere != -1) {
            count = orderDetail["count"];
            count_report = menus[indexWhere]["count"] == null
                ? menus[indexWhere]["count"] = count
                : (count + menus[indexWhere]["count"]);
            price_report = (count_report * menus[indexWhere]["price"]);
            menus[indexWhere]["price_report"] = price_report;
            menus[indexWhere]["count_report"] = count_report;
          }else{
            menus[index]["price_report"] = orderDetail["price"];
            menus[index]["count_report"] = orderDetail["count"];
            print("${menus[index]["name"]} = ${menus[index]["price_report"]}");
          }
          index++;
        });
      }
    });
    menus.removeWhere((element) => element["count_report"]==null);
    menus.sort((m2,m1)=>m1["count_report"].compareTo(m2["count_report"]));
    print(menus);
    return menus;
  }

  int splitDateTimeYear(String text) {
    var year, dateSplit;
    dateSplit = text.split('/');
    year = dateSplit[2];
    return int.parse(year);
  }

  String splitDateMonth(String text) {
    var my, dateSplit;
    dateSplit = text.split('/');
    my = "${dateSplit[1]}/${dateSplit[2]}";
    return my;
  }

  String dateFormteMonth(int number) {
    List moth = [
      "ม.ค",
      "ก.พ",
      "มี.ค",
      "เม.ย",
      "พ.ค",
      "มิ.ย",
      "ก.ค",
      "ส.ค",
      "ก.ย",
      "ต.ค",
      "พ.ย",
      "ธ.ค"
    ];
    return moth[(number - 1)];
  }

  List reportYear(String year) {
    data_report.clear();
    List price = [];
    for (int i = 1; i <= 12; i++) {
      price.add(0);
      String my = "$i/$year";
      data.forEach((orders) {
        String orderYear = splitDateMonth(orders["orderDate"]);
        if (orderYear == my) {
          orders["detail"].forEach((ordersDetail) {
            price[(i - 1)] += (ordersDetail["count"] * ordersDetail["price"]);
          });
        }
      });
      data_report.add(PopulationData(
          moth: dateFormteMonth(i),
          price: price[(i - 1)],
          barColor:
              charts.ColorUtil.fromDartColor(Color.fromRGBO(255, 51, 247, 1))));
      print("${data_report[(i - 1)].moth} = ${data_report[(i - 1)].price}");
    }

    return data_report;
  }
}

class PopulationData {
  String moth;
  int price;
  charts.Color barColor;
  PopulationData(
      {@required this.moth, @required this.price, @required this.barColor});
}
