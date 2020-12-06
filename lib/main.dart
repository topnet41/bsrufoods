import 'package:bsrufoods/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/home.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    Asp(),
  );
}

class Asp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "BsruFood",
        theme: ThemeData(
          primaryColor: Color.fromRGBO(255, 51, 247, 1),
        ),
        // home: Login(),
        initialRoute: '/',
        routes: {
          '/': (_) => SplashScreen(),
          '/login': (_) => Login(),
          '/home': (_) => Home()
        });
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth firebase = FirebaseAuth.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
       var user = firebase.currentUser;
       print("user == ${user}");
    Future.microtask(() {
      if(user != null){
        Navigator.pushReplacementNamed(context, '/home');
      }
      else{
        Navigator.pushReplacementNamed(context, '/login');
      }

      // Navigator.pushReplacementNamed(context, '/login');
      // print("userid = ${firebase.currentUser.photoURL}");
      // firebaseMessaging.getToken().then((String token) {
      //   assert(token != null);
      //   print("Token : $token");
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("images/logo.png", width: 150),
          ],
        ),
      ),
    );
  }
}
