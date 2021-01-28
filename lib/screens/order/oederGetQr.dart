import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderGetQr extends StatefulWidget {
  final String qrString;
  OrderGetQr(this.qrString);
  @override
  _OrderGetQrState createState() => _OrderGetQrState();
}

class _OrderGetQrState extends State<OrderGetQr> {
  FirebaseFirestore firestore =FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(),
      body: Text(widget.qrString),
    );
  }
}