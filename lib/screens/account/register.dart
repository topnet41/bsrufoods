import 'dart:io';
import 'dart:math';

import 'package:bsrufoods/controller/firestore_controller.dart';
import 'package:bsrufoods/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:select_form_field/select_form_field.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final keyfrom = GlobalKey<FormState>();
  final name = TextEditingController();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumber = TextEditingController();
  final reCeipt = TextEditingController();
  String bank ;
  var now = DateTime.now();
  String getDatetime;
  final List<Map<String, dynamic>> _items = [
    {
      'value': 'ธนาคารไทยพาณิชย์',
      'label': 'ธนาคารไทยพาณิชย์',
    },
    {
      'value': 'ธนาคารกสิกรไทย',
      'label': 'ธนาคารกสิกรไทย',
    },
    {
      'value': 'ธนาคารกรุงเทพ',
      'label': 'ธนาคารกรุงเทพ',
    },
    {
      'value': 'ธนาคารกรุงศรีอยุธยา',
      'label': 'ธนาคารกรุงศรีอยุธยา',
    },
  ];
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot snapshot ;
  String memberid;

   void getlengthMember()async{
        int member;
        final documents = await firestore.collection("member").get();
        member = documents.docChanges.length+1;
        print(member);
        memberid = member.toString();
   }

  final picker = ImagePicker();
  bool statusBool;

  File _image;
  File _imgReceipt;
  String urlPhoto, urlPhoto1;

  @override
  void initState() { 
    super.initState();
    statusBool = false;
    getlengthMember();
    // print(memberid);
  }

  void _onSave() {
    if (_imgReceipt == null || bank == null) {
      Alert(
          context: context,
          type: AlertType.warning,
          title: "กรุณาเพิ่มบาร์โค้ด หรือ ระบุธนาคาร",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "ตกลง",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();
    } else {
      if (keyfrom.currentState.validate()) {
        keyfrom.currentState.save();
        registerThread();
        print(passwordController.text);
      }
    }
  }

  Future<void> uploadPictureToStore() async {
    Random random = Random();
    int i = random.nextInt(100000);

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    if (_image != null) {
      await firebaseStorage.ref().child('Member/member$i.jpg').putFile(_image);
      urlPhoto = await firebaseStorage
          .ref()
          .child('Member/member$i.jpg')
          .getDownloadURL();
    } else {
      urlPhoto =
          "https://firebasestorage.googleapis.com/v0/b/bsrufood.appspot.com/o/Member%2Fbaseline_account_circle_black_48dp.png?alt=media&token=2269f14d-3913-4911-9baa-94b0e615c7a9";
    }
    await firebaseStorage
        .ref()
        .child('Barcode/member$i.jpg')
        .putFile(_imgReceipt);
    urlPhoto1 = await firebaseStorage
        .ref()
        .child('Barcode/member$i.jpg')
        .getDownloadURL();

    await setupDisplayName();
  }

  Future<void> registerThread() async {
    setState(() {
      statusBool = true;
    });
    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: userController.text, password: passwordController.text)
        .then((response) {
      print('Register Success for Email = $userController');
      uploadPictureToStore();
    }).catchError((response) {
      setState(() {
        statusBool = false;
      });
      String title = response.code;
      var alertView = {
          "invalid-email":{
            "title":"อีเมลไม่ถูกต้อง",
            "body":"ตัวอย่าง:bsru@email.com"
          },
          "email-already-in-use":{
            "title":"อีเมลนี้มีผู้ใช้งานแล้ว",
            "body":"ลองกรอกใหม่อีกครั้ง"
          }
      };
      Alert(
          context: context,
          type: AlertType.info,
          title: alertView[title]["title"],
          desc: alertView[title]["body"],
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "ตกลง",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();
    });
  }

  Future<void> setupDisplayName() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<String> tokenUser;
    await _firebaseMessaging.getToken().then((String token) {
      tokenUser = [token];
    });
    Map<String, dynamic> map = Map();
    map['username'] = name.text;
    map['userId'] = "${now.year}$memberid";
    map['prompt'] = reCeipt.text;
    map['barcode'] = urlPhoto1;
    map['phone'] = phoneNumber.text;
    map['statusShop'] = true;
    map['bank'] = bank;
    map['tokenUser'] = FieldValue.arrayUnion(tokenUser);
    map['userStatus'] = "admin";

    var user = firebaseAuth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: name.text, photoURL: urlPhoto);
      await firestore.collection("member").doc(user.uid).set(map).then((value) {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext context) => Home());
        Navigator.of(context).pushAndRemoveUntil(
            materialPageRoute, (Route<dynamic> route) => false);
      });
    }
    print(user);
  }

  Widget galleryButton() {
    return IconButton(
        icon: Icon(Icons.add_photo_alternate),
        onPressed: () {
          getImage(ImageSource.gallery, 0);
        });
  }

  Widget cameraButton() {
    return IconButton(
        icon: Icon(Icons.add_a_photo),
        onPressed: () {
          getImage(ImageSource.camera, 0);
        });
  }

  Future getImage(ImageSource imageSource, int index) async {
    final pickedFile = await picker.getImage(
      source: imageSource,
      maxWidth: 512,
      maxHeight: 512,
    );

    setState(() {
      if (pickedFile != null) {
        if (index == 0) {
          _image = File(pickedFile.path);
        } else {
          _imgReceipt = File(pickedFile.path);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("สมัครสมาชิก"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
                key: keyfrom,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("รูปภาพร้านค้า"),
                      Divider(),
                      _image != null
                          ? Image.file(
                              _image,
                              width: 150,
                              height: 150,
                            )
                          : Image.asset("images/empty.jpg", width: 150),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cameraButton(),
                          Padding(padding: EdgeInsets.only(right: 70)),
                          galleryButton()
                        ],
                      ),
                      Text("ข้อมูลร้านค้า"),
                      Divider(),
                      _createinput(
                          controller: name,
                          hinttext: "ชื่อร้านค้า",
                          maxLength: 50),
                      _createinput(
                          controller: userController,
                          hinttext: "อีเมล",
                          keyboardType: TextInputType.emailAddress),
                      _createinput(
                          controller: passwordController,
                          hinttext: "รหัสผ่าน",
                          isPassword: true),
                      _createinput(
                          controller: phoneNumber,
                          hinttext: "เบอร์โทรศัพท์",
                          keyboardType: TextInputType.number,
                          maxLength: 10),
                      Text("ช่องทางชำระเงิน"),
                      SelectFormField(
                        type: SelectFormFieldType.dropdown, // or can be dialog
                        icon: Icon(Icons.account_balance),
                        labelText: "ธนาคาร",
                        items: _items,
                        onChanged: (val){bank = val ;},
                        onSaved: (val){bank = val ;},
                      ),
                      Divider(),
                      _createinput(
                          controller: reCeipt,
                          hinttext: "หมายเลขบัญชี",
                          keyboardType: TextInputType.number,
                          maxLength: 12),
                      SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.qr_code_scanner),
                                  Text("เพิ่มบาร์โค้ด"),
                                ],
                              ),
                              onPressed: () {
                                getImage(ImageSource.gallery, 1);
                              })),
                      SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save_alt),
                                  statusBool ? CircularProgressIndicator() : Text("บันทึกข้อมูล"),
                                ],
                              ),
                              onPressed: statusBool ? (){} : () => _onSave())),
                    ],
                  ),
                )),
          ),
        ));
  }

  Widget _createinput(
      {@required TextEditingController controller,
      @required String hinttext,
      TextInputType keyboardType = TextInputType.text,
      bool isPassword = false,
      int maxLength = 100}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: TextFormField(
        maxLength: maxLength,
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
