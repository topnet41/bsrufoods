import 'dart:convert';

import 'package:flutter/foundation.dart';

class MyData {
  final int orderid;
  final List<MyDataMenu> detail;

  MyData({
    this.orderid,
    this.detail,
  });
  

  MyData copyWith({
    int orderid,
    List<MyDataMenu> detail,
  }) {
    return MyData(
      orderid: orderid ?? this.orderid,
      detail: detail ?? this.detail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderid': orderid,
      'detail': detail?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory MyData.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return MyData(
      orderid: map['orderid'],
      detail: List<MyDataMenu>.from(map['detail']?.map((x) => MyDataMenu.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory MyData.fromJson(String source) => MyData.fromMap(json.decode(source));

  @override
  String toString() => 'MyData(orderid: $orderid, detail: $detail)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is MyData &&
      o.orderid == orderid &&
      listEquals(o.detail, detail);
  }

  @override
  int get hashCode => orderid.hashCode ^ detail.hashCode;
}

class MyDataMenu {
  final String name;
  bool status;

  MyDataMenu({
    this.name,
    this.status,
  });

  MyDataMenu copyWith({
    String name,
    bool status,
  }) {
    return MyDataMenu(
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
    };
  }

  factory MyDataMenu.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return MyDataMenu(
      name: map['name'],
      status: map['status'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MyDataMenu.fromJson(String source) => MyDataMenu.fromMap(json.decode(source));

  @override
  String toString() => 'MyDataMenu(name: $name, status: $status)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is MyDataMenu &&
      o.name == name &&
      o.status == status;
  }

  @override
  int get hashCode => name.hashCode ^ status.hashCode;
}
