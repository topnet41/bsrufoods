import 'package:badges/badges.dart';
import 'package:bsrufoods/screens/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home/homelist.dart';
import 'menu.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var items;
  CollectionReference order ;

    @override
    void initState() { 
      super.initState();
    }


List<Widget> shows = [Homelist(),Menu(),null,Account()];
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
            position: BadgePosition(top: -1,start: 33),
            child: IconButton(
                icon: Icon(
                  Icons.notifications,
                  size:35.0
                ),
                onPressed: (){},
            )
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('orders').where("userId",isEqualTo: "20202").where("staOrder",isEqualTo: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        print(snapshot.data.docs.length);
    return Scaffold(
      bottomNavigationBar: buttomlist(snapshot.data.docs.length),
      body: SafeArea(
        child: Center(
          child: shows[_currentIndex],
        ),
      ),
    );
      });
  }
}
