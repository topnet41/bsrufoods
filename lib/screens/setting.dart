import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 242, 245, 1.0),
      appBar: AppBar(
        title: Text("ตั้งค่า"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(right: 5.0,left: 5.0),
        child: Column(
          children: [
            Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("เปิดรับเงินสด",style: TextStyle(fontSize: 18),),Switch(value: false, onChanged: null)],
                ),
              ),
            ),
            Text("การเปิดรับเงินสดอาจมีความเสี่ยงในการสั่งซื้อ เพื่อลดความเสี่ยงกรุณาจำกัดจำนวนในการสั่ง")
          ],
        ),
      ),
    );
  }
}
