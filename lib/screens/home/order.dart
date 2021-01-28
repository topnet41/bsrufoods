import 'package:bsrufoods/screens/order/oederGetQr.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  List ss = [];
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
             // To ensure the Scanner view is properly sizes after rotation
             // we need to listen for Flutter SizeChanged notification and update controller
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (notification) {
                Future.microtask(() => controller?.updateDimensions(qrKey));
                return false;
              },
              child: SizeChangedLayoutNotifier(
                key: const Key('qr-size-notifier'),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan result: $qrText'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        ss.add(scanData);
        getqrCode();
      });
    });
  }

  void getqrCode(){
    if(ss.length == 1){
        MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>OrderGetQr(qrText));
        Navigator.push(context, route).then((value) {setState(() {
          ss = [];
          qrText = "";
        });});
        }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}