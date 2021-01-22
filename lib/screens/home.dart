import 'package:badges/badges.dart';
import 'package:bsrufoods/screens/account.dart';
import 'package:bsrufoods/screens/notifi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home/homelist.dart';
import 'menu.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  String messaged;
  var items;
  String shopid;
  CollectionReference order ;

    void getUser()async{
      await firestore.collection("member").doc(auth.currentUser.uid).get().then((value) {
          setState(() {
              shopid = value["userId"];
          });
      });
    }

    sendNotification(String title,String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('10000',
        'FLUTTER_NOTIFICATION_CHANNEL', 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
 
    var platformChannelSpecifics = NotificationDetails(android:androidPlatformChannelSpecifics,iOS: iOSPlatformChannelSpecifics );
 
    await flutterLocalNotificationsPlugin.show(111, title,
        body, platformChannelSpecifics,
        payload: 'I just haven\'t Met You Yet');
  }

    @override
    void initState() { 
      
      super.initState();
      message();
      getUser();
    }


Widget shows(int i){
  print(i);
  return i == 0 ? Homelist() : i == 1 ? Menu() : i == 2 ? Notifi(shopid) : Account();
}
int _currentIndex = 0;
  Widget showlogo() {
    return Container(
      width: 150.0,
      height: 150.0,
      child: Image.asset('images/logo.png'),
    );
  }

  void onTabTapped(int index) {
   setState(() {
     _currentIndex = index;
   });
 }
  Widget buttomlist(int noti) {
    return BottomNavigationBar(
        onTap: onTabTapped, // new
        selectedItemColor: Color.fromRGBO(255, 255, 255, 1.0),
        currentIndex: _currentIndex, 
        backgroundColor: Color.fromRGBO(255, 51, 247, 1.0),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(
              Icons.home,
              size: 35.0,
            ),
            title: Text("หน้าแรก",),
          ),
          BottomNavigationBarItem(
            icon: new Icon(
              Icons.list,
              size: 35.0,
            ),
            title: Text("เมนู"),
          ),
          BottomNavigationBarItem(
            icon: Badge(
            badgeContent: noti == 0 ? Text("0",style: TextStyle(color: Colors.white)) 
            : Text(noti.toString(),style: TextStyle(color: Colors.white),),
            toAnimate: true,
            position: BadgePosition(top: -3,start: 30),
            child: Icon(
                  Icons.notifications,
                  size:35.0
                ),   
            ),title:Text("การแจ้งเตือน")),
          BottomNavigationBarItem(
            icon: new Icon(
              Icons.person,
              size: 35.0,
            ),
            title: Text("บัญชี"), 
          ),
        ]);
  }

  void message(){
    firebaseMessaging.configure(
        onMessage: (msg) async{
            print("onMessage: $msg");
            Map mapNotification = msg["notification"];
            String title = mapNotification["title"];
             String body = mapNotification["body"];
            return sendNotification(title,body);
        },
      onLaunch: (msg) async {
        print("onLaunch: $msg");
        return;
      },
      onResume: (msg) async {
        print("onResume: $msg");
        return;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('orders').where("shopId",isEqualTo: shopid).where("staOrder",isEqualTo: false).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

    return Scaffold(
      bottomNavigationBar: buttomlist(snapshot.data.docs.length),
      body: SafeArea(
        child: Center(
          child: shows(_currentIndex),
        ),
      ),
    );
      });
  }
}
