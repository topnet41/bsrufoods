import 'dart:io';
import 'dart:math';

import 'package:bsrufoods/screens/account/register_Controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String statusUser = "admin";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final picker = ImagePicker();

  File _image;
  File _imgReceipt;
  String urlPhoto,urlPhoto1;

  void _onSave() {
    uploadPictureToStore();

    // if (keyfrom.currentState.validate()) {
    //   keyfrom.currentState.save();
    //   print(passwordController.text);
    // }
  }

  Future<void> uploadPictureToStore() async {
    Random random = Random();
    int i = random.nextInt(100000);

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    await firebaseStorage.ref().child('Member/member$i.jpg').putFile(_image);
         urlPhoto = await firebaseStorage
        .ref()
        .child('Member/member$i.jpg')
        .getDownloadURL();
    await firebaseStorage
        .ref()
        .child('Barcode/member$i.jpg')
        .putFile(_imgReceipt);
         urlPhoto1 = await firebaseStorage
        .ref()
        .child('Barcode/member$i.jpg')
        .getDownloadURL();

    await registerThread();
  }

  Future<void> registerThread() async {
    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: userController.text, password: passwordController.text)
        .then((response) {
      print('Register Success for Email = $userController');
      setupDisplayName();
    }).catchError((response) {
      String title = response.code;
      String message = response.message;
      print('title = $title,message = $message');
    });
  }

  Future<void> setupDisplayName() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String,dynamic> map = Map();
    map['prompt'] = reCeipt.text;
    map['barcode'] = urlPhoto1;
    map['phone'] = phoneNumber.text;
    map['userStatus'] = statusUser;

    var user = firebaseAuth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: name.text,photoURL: urlPhoto);
      await firestore.collection("member").doc(user.uid).set(map).then((value)=>Navigator.pushReplacementNamed(context, "/home"));
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
                          : Image.network(
                              "https://apibsrufood.000webhostapp.com/empty.jpg",
                              width: 150),
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
                      _createinput(controller: name, hinttext: "ชื่อร้านค้า"),
                      _createinput(
                          controller: userController, hinttext: "อีเมล"),
                      _createinput(
                          controller: passwordController,
                          hinttext: "รหัสผ่าน",
                          isPassword: true),
                      _createinput(
                          controller: phoneNumber, hinttext: "เบอร์โทรศัพท์"),
                      Text("ช่องทางชำระเงิน"),
                      Divider(),
                      _createinput(
                          controller: reCeipt, hinttext: "หมายเลขบัญชี"),
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
                                  Text("บันทึกข้อมูล"),
                                ],
                              ),
                              onPressed: () => _onSave())),
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
