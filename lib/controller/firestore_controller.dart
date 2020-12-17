import 'package:cloud_firestore/cloud_firestore.dart';

class Firestorecontroller{
   FirebaseFirestore firestore = FirebaseFirestore.instance;
   DocumentSnapshot snapshot ;

   Future getlengthMember()async{
        int member;
        String memberid;
        final documents = await firestore.collection("member").doc().get();
        snapshot = documents;
        member = snapshot.data().length+1;
        memberid = member.toString();
        return memberid;
   }

}