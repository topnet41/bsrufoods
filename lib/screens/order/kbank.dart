import 'package:flutter/material.dart';

class Kbank extends StatefulWidget {
  final String image;
  Kbank(this.image);
  @override
  _KbankState createState() => _KbankState();
}

class _KbankState extends State<Kbank> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("สลิปโอนเงิน"),
      ),
      body: Center(
        child: Image.network(
          widget.image,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}
