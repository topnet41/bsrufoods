import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Editmenu extends StatefulWidget {
  final int index;
  final List menuDetail,menu;
  Editmenu(this.index, this.menuDetail,this.menu);
  @override
  _EditmenuState createState() => _EditmenuState();
}

class _EditmenuState extends State<Editmenu> {
  final keyfrom = GlobalKey<FormState>();
  final name = TextEditingController();
  final price = TextEditingController();
  final optionName = TextEditingController();
  final optionPrice = TextEditingController();
  final picker = ImagePicker();
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  File _image;
  List<Map> option = [];
  bool statusbtn;

  Future<void> uploadPictureToStore() async {
    Random random = Random();
    int i = random.nextInt(100000);
    if (_image != null) {
      await firebaseStorage
          .ref()
          .child('product/product$i.jpg')
          .putFile(_image);
      widget.menuDetail[widget.index]["image"] = await firebaseStorage
          .ref()
          .child('product/product$i.jpg')
          .getDownloadURL();
    }else{
      widget.menuDetail[widget.index]["image"] = widget.menuDetail[widget.index]["image"];
    }
    setdata();
  }

  void deleteOption(int index) {
    Alert(
        context: context,
        title: "ลบตัวเลือก",
        content: Text(option[index]["name"]),
        buttons: [
          DialogButton(
            onPressed: () {
              option.remove(option[index]);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(
              "ตกลง",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "ยกเลิก",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void editOption(int index,String name,String price) {
    optionName.text = name;
    optionPrice.text = price;
    Alert(
        context: context,
        title: "แก้ไขตัวเลือก",
        content: Column(
          children: [
            TextField(
              controller: optionName,
              decoration: InputDecoration(
                labelText: 'ตัวเลือก',
              ),
            ),
            TextField(
              controller: optionPrice,
              decoration: InputDecoration(
                labelText: 'ราคา',
              ),
              keyboardType: TextInputType.number,
            )
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (optionName.text == "" || optionPrice.text == "") {
                print("ไม่ม่ค่านะเว้ยย");
              } else {
                num priceMenu = int.parse(optionPrice.text);
                Map<String, dynamic> optionMap = Map();
                optionMap["name"] = optionName.text;
                optionMap["price"] = priceMenu;
                option[index]= optionMap;
                optionName.clear();
                optionPrice.clear();
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text(
              "ตกลง",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ]).show();
  }


  void addOption() {
    Alert(
        context: context,
        title: "เพิ่มตัวเลือก",
        content: Column(
          children: [
            TextField(
              controller: optionName,
              decoration: InputDecoration(
                labelText: 'ตัวเลือก',
              ),
            ),
            TextField(
              controller: optionPrice,
              decoration: InputDecoration(
                labelText: 'ราคา',
              ),
              keyboardType: TextInputType.number,
            )
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (optionName.text == "" || optionPrice.text == "") {
                print("ไม่ม่ค่านะเว้ยย");
              } else {
                num priceMenu = int.parse(optionPrice.text);
                Map<String, dynamic> optionMap = Map();
                optionMap["name"] = optionName.text;
                optionMap["price"] = priceMenu;
                option.add(optionMap);
                optionName.clear();
                optionPrice.clear();
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text(
              "ตกลง",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ]).show();
  }

  Widget galleryButton() {
    return IconButton(
        icon: Icon(Icons.add_photo_alternate),
        onPressed: () {
          getImage(ImageSource.gallery);
        });
  }

  Widget cameraButton() {
    return IconButton(
        icon: Icon(Icons.add_a_photo),
        onPressed: () {
          getImage(ImageSource.camera);
        });
  }

  Widget orderOption() {
    return Column(
      children: List.generate(option.length, (index) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(option[index]["name"].toString()),
                Text(option[index]["price"].toString()),
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          editOption(index,option[index]["name"],"${option[index]["price"]}");
                        }),
                    IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteOption(index))
                  ],
                ),
              ],
            ),
            Divider()
          ],
        );
      }),
    );
  }

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
      source: imageSource,
      maxWidth: 512,
      maxHeight: 512,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> setdata() async {
    var user = firebaseAuth.currentUser;
    Map<String, dynamic> map = Map();
    map["menudetail"] = FieldValue.arrayRemove(widget.menu);
    await firestore
        .collection("menus")
        .doc(user.uid)
        .update(map)
        .then((value) {});
    update();
  }

  Future<void> update() async {
    var user = firebaseAuth.currentUser;
    Map<String, dynamic> map = Map();
    map["menudetail"] = FieldValue.arrayUnion(widget.menuDetail);
    await firestore
        .collection("menus")
        .doc(user.uid)
        .update(map)
        .then((value) {});
    Navigator.pop(context);
  }

  Widget getimages() {
    return widget.menuDetail[widget.index]["image"] == null
        ? Image.asset("images/empty.jpg", width: 150)
        : Image.network(
            widget.menuDetail[widget.index]["image"],
            width: 150,
            height: 150,
          );
  }

  void onSave() {
    if (keyfrom.currentState.validate()) {
      keyfrom.currentState.save();
      num priceMenu = int.parse(price.text);
      widget.menuDetail[widget.index]["price"] = priceMenu;
      widget.menuDetail[widget.index]["option"] = option;
      print(widget.menuDetail);
      uploadPictureToStore();
      setState(() {
        statusbtn = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    statusbtn = false;
    name.text = widget.menuDetail[widget.index]["name"];
    price.text = widget.menuDetail[widget.index]["price"].toString();
    for (var data in widget.menuDetail[widget.index]["option"]) {
      Map<String, dynamic> optionMap = Map();
      optionMap["name"] = data["name"];
      optionMap["price"] = data["price"];
      option.add(optionMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("แก้ไขเมนู"),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
                key: keyfrom,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("รูปภาพอาหาร"),
                      Divider(),
                      _image != null
                          ? Image.file(
                              _image,
                              width: 150,
                              height: 150,
                            )
                          : getimages(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cameraButton(),
                          Padding(padding: EdgeInsets.only(right: 70)),
                          galleryButton()
                        ],
                      ),
                      Text("ข้อมูลอาหาร"),
                      Divider(),
                      _createinput(
                          controller: name,
                          hinttext: "ชื่ออาหาร",
                          maxLength: 50),
                      _createinput(
                          controller: price,
                          hinttext: "ราคาอาหาร",
                          maxLength: 10,
                          keyboardType: TextInputType.numberWithOptions()),
                      Row(
                        children: [
                          Text("สถานะอาหาร"),
                          Switch(
                            value: widget.menuDetail[widget.index]["status"],
                            onChanged: (value) {
                              setState(() {
                                widget.menuDetail[widget.index]["status"] =
                                    value;
                              });
                            },
                            activeColor: Colors.green,
                          ),widget.menuDetail[widget.index]["status"]? Text("เปิด") : Text("ปิด")
                        ],
                      ),
                      // Text("ข้อมูลตัวเลือก"),
                      // Divider(),
                      // orderOption(),
                      // SizedBox(
                      //     width: double.infinity,
                      //     child: RaisedButton(
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           Icon(Icons.add),
                      //           Text("เพิ่มตัวเลือก"),
                      //         ],
                      //       ),
                      //       onPressed: () => addOption(),
                      //     )),
                      SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                statusbtn
                                    ? CircularProgressIndicator()
                                    : Icon(Icons.save_alt),
                                Text("บันทึกข้อมูล"),
                              ],
                            ),
                            onPressed: statusbtn ? () {} : () => onSave(),
                          ))
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
