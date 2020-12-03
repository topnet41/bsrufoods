import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

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
    print("tokken = ${result.accessToken.token}");
    await _firebaseAuth.signInWithCredential(FacebookAuthProvider.credential(
        token));

    Navigator.pushReplacementNamed(_context, '/home');
  }

}
