import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class chatting extends StatefulWidget {

  String fingerPrintUser="";
  String fingerPrintProvider="";

  chatting(this.fingerPrintUser,this.fingerPrintProvider);

  @override
  State<chatting> createState() => _chattingState();
}

class _chattingState extends State<chatting> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    firestore.collection('chat').doc("chatDetail").collection(widget.fingerPrintUser+widget.fingerPrintProvider).add({'name':"your name", "id":"your id"});
  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
