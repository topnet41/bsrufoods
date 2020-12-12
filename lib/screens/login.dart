import 'package:bsrufoods/controller/auth_controller.dart';
import 'package:bsrufoods/screens/account/register.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();

}



final keyfrom = GlobalKey<FormState>();
final userController = TextEditingController();
final passwordController = TextEditingController();
Authcontroller authController;



void _onLogin() {
  if (keyfrom.currentState.validate()) {
    keyfrom.currentState.save();
    authController.onLogin(
        email: userController.text, password: passwordController.text);
    print(passwordController.text);
  }
}


class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    authController = Authcontroller(context);
  }
  bool statusWidget = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbsorbPointer(
        absorbing: statusWidget,

        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "images/logo.png",
                    width: 100,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Form(
                      key: keyfrom,
                      child: Column(
                        children: [
                          _createinput(
                              controller: userController,
                              hinttext: "E-mail",
                              isPassword: false),
                          _createinput(
                              controller: passwordController,
                              hinttext: "Password",
                              isPassword: true),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),),
                                color: Color.fromRGBO(255, 51, 247, 1.0),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text("เข้าสู่ระบบ",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                                onPressed: () {
                                  _onLogin();
                                }),
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                                color: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text("สมัครสมาชิก",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                                onPressed: () {
                                  MaterialPageRoute route = MaterialPageRoute(builder: (BuildContext context)=>Register());
                                  Navigator.push(context, route);
                                }),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                                child: Column(
                                  children: [
                                    Text("เชื่อมต่อด้วย"),
                                    Divider(),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(vertical: 30)),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "images/fb.png",
                                      width: 25,
                                      height: 25,
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5)),
                                    Text("Facebook",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                  ],
                                ),
                                onPressed: ()=> authController.loginWithFacebook(context)),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createinput(
      {@required TextEditingController controller,
      @required String hinttext,
      TextInputType keyboardType = TextInputType.text,
      bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        validator: (msx) {
          if (msx.isEmpty) return "input valid";
          return null;
        },
        decoration: InputDecoration(
          hintText: hinttext,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(255, 51, 247, 1)),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(255, 51, 247, 1)),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }
}
