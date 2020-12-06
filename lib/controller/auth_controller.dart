import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;


import 'getphoto.dart';

class Authcontroller {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final BuildContext _context;

  Authcontroller(BuildContext context) : _context = context;

  onLogin({
    @required String email,
    @required String password,
  }) async {
    try {
      final user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      Navigator.pushReplacementNamed(_context, '/home');
      // print(user);
    } catch (e) {
      final _e = (e as FirebaseAuthException);
      print(_e.message);
    }
  }

  final facebookLogin = FacebookLogin();

  Future loginWithFacebook(BuildContext context) async {
    FacebookLoginResult result =
        await facebookLogin.logIn(["email", "public_profile"]);
    var token = result.accessToken.token;

    final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${token}');
    final profile = json.decode(graphResponse.body);
    var dataphoto = Getphoto.fromJson(profile);
    String photo = dataphoto.picture.data.url;
    await _firebaseAuth.signInWithCredential(FacebookAuthProvider.credential(
        token));
    var user = _firebaseAuth.currentUser;  
    await user.updateProfile(photoURL: photo);
    Navigator.pushReplacementNamed(_context, '/home');
  }


}
