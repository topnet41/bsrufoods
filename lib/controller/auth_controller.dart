import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import 'getphoto.dart';

class Authcontroller {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DocumentSnapshot snapshot;
  final BuildContext _context;

  Authcontroller(BuildContext context) : _context = context;

  void alertNotfould(String message) {
    Alert(context: _context, type: AlertType.error, title: message, buttons: [
      DialogButton(
        onPressed: () {
          Navigator.pop(_context);
        },
        child: Text(
          "ตกลง",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ]).show();
  }

  onLogin({
    @required String email,
    @required String password,
  }) async {
    try {
      final user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final document = await firestore
          .collection("member")
          .doc(_firebaseAuth.currentUser.uid)
          .get();
      snapshot = document;
      if (snapshot["userStatus"] == "admin") {
        List<String> tokenUser;
        await _firebaseMessaging.getToken().then((String token) {
          tokenUser = [token];
        });
        Map<String, dynamic> map = Map();
        map['tokenUser'] = FieldValue.arrayUnion(tokenUser);

        await firestore
            .collection("member")
            .doc(_firebaseAuth.currentUser.uid)
            .update(map);
        Navigator.pushReplacementNamed(_context, "/home");
      } else {
        await facebookLogin.logOut();
        await _firebaseAuth.signOut();
        alertNotfould("บัญชีนี้ไม่สามารถใข้งานได้");
      }
    } catch (e) {
      final _e = (e as FirebaseAuthException);
      alertNotfould("อีเมลหรือรหัสผ่านไม่ถูกต้อง");
      print(_e.message);
    }
  }

  final facebookLogin = FacebookLogin();

  Future loginWithFacebook(BuildContext context) async {
    FacebookLoginResult result =
        await facebookLogin.logIn(["email", "public_profile"]);
    var token = result.accessToken.token;
    
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${token}');
    final profile = json.decode(graphResponse.body);
    var dataphoto = Getphoto.fromJson(profile);
    String photo = dataphoto.picture.data.url;
    await _firebaseAuth
        .signInWithCredential(FacebookAuthProvider.credential(token));
    final document = await firestore
        .collection("member")
        .doc(_firebaseAuth.currentUser.uid)
        .get();
    snapshot = document;
    if (snapshot.exists) {
      if (snapshot["userStatus"] == "admin") {
        List<String> tokenUser;
        await _firebaseMessaging.getToken().then((String token) {
          tokenUser = [token];
        });
        Map<String, dynamic> map = Map();
        map['tokenUser'] = FieldValue.arrayUnion(tokenUser);

        await firestore
            .collection("member")
            .doc(_firebaseAuth.currentUser.uid)
            .update(map);
        Navigator.pushReplacementNamed(_context, "/home");
      } else {
        await facebookLogin.logOut();
        await _firebaseAuth.signOut();
        alertNotfould("บัญชีนี้ไม่สามารถใข้งานได้");
      }
    } else {
      await _firebaseAuth.currentUser.updateProfile(photoURL: photo);
      Navigator.pushReplacementNamed(_context, '/register');
    }
  }
}
