import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class awaitUser extends StatefulWidget {
  String? fingerPrint;

  double? locationX;

  double? locationY;


  late List<Marker> markers = [];

  List<dynamic> fingerprintkeys=[];

  Map valueMap={};

  @override
  State<awaitUser> createState() => _awaitUserState();

  awaitUser(this.fingerPrint,this.locationX,this.locationY,this.markers,this.fingerprintkeys,this.valueMap);
}

class _awaitUserState extends State<awaitUser> {

  final DBRef=FirebaseDatabase.instance.reference();

  String userFingerprint='';

  bool match=false;

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    timer=Timer.periodic(Duration(seconds: 5), (timer) {
      DBRef.once().then((DatabaseEvent dataSnapshot){
        String data=dataSnapshot.snapshot.value.toString();
        widget.valueMap=jsonDecode(data);
        widget.fingerprintkeys=widget.valueMap.keys.toList();
        Map newMap=widget.valueMap[widget.fingerPrint];
        print(newMap.length);
        if(newMap.length==6)
        {
          timer.cancel();
          userFingerprint=newMap["selected"];
          print(userFingerprint);
          setState(() {
            match=true;
          });
        }
      });
    });
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 50, 0, 0),
            child: !match?Text("우산공유자 등록 완료",style: TextStyle(fontSize: 40,color: Colors.lightBlue)):
            Text("우산필요자와 매칭",style: TextStyle(fontSize: 40,color: Colors.lightBlue)),
          ),
          Spacer(),
          Spacer(),
          Center(
            child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: !match?Text("우산필요한 사람과 매칭을 기다리는 중...",style: TextStyle(fontSize: 20,color: Colors.lightBlue,)):
              Text("",style: TextStyle(fontSize: 0,color: Colors.lightBlue)),),
          ),
          Spacer(),
          Spacer(),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: !match?Text("필요자와 우산을 같이 쓰고 갈 수 있을 뿐만 아니라\n 중고우산을 팔 수도 있어요!",style: TextStyle(fontSize: 17,color: Colors.lightBlue,)):
            Text("",style: TextStyle(fontSize: 0,color: Colors.lightBlue)),),
          Spacer(),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: !match?Text("필요자에게 정당한 대가를 요구해보세요.\n 물론 공짜도 좋지만요 :)",style: TextStyle(fontSize: 17,color: Colors.lightBlue,)):
            Text("",style: TextStyle(fontSize: 0,color: Colors.lightBlue)),),
          Spacer(),
          match?OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
              onPressed:(){    timer?.cancel();},
              child: Text("우산필요자와 대화",style: TextStyle(color: Colors.white,fontSize: 20),)):Container(),
          Spacer(),
          OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
              onPressed:(){    timer?.cancel();},
              child: Text("등록취소",style: TextStyle(color: Colors.white,fontSize: 20),)),
          Spacer(),

        ],
      )
    );
  }
}
