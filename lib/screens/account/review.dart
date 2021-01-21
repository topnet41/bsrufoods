import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Review extends StatefulWidget {
  final String userid;
  Review(this.userid);
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final _ratingController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> coment = [];

  void getComents() async {
    await firestore
        .collection("coments")
        .where("shopId", isEqualTo: widget.userid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          coment.add(element.data());
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getComents();
    _ratingController.text = '3.0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รีวิวร้านอาหาร'),
        centerTitle: true,
      ),
      body: coment.length == 0
          ? Center(
              child: Text(
              "ยังไม่มีความคิดเห็น",
              style: TextStyle(fontSize: 32.0),
            ))
          : ListView.separated(
              itemBuilder: (context, index) {
                double score = coment[index]["score"].toDouble() ; 
                return ListTile(
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        coment[index]["photo"],
                        width: 50,
                        height: 50,
                      )),
                  title: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Text(coment[index]["username"].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(coment[index]["coment"].toString())
                  ],),
                  subtitle: RatingBarIndicator(
                    rating: score,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 18.0,
                    direction: Axis.horizontal,
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min,children: [Icon(Icons.star),Text(coment[index]["score"].toString())],),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: coment.length),
    );
  }
}
