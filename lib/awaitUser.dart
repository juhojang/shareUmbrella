import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chatPage.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  late GoogleMapController mapController;

  final DBRef=FirebaseDatabase.instance.reference();

  String userFingerprint='';

  bool match=false;

  late CameraPosition _initialPosition = CameraPosition(target: LatLng(widget.locationY!,widget.locationX!),zoom: 15);

  Timer? timer;

  double distance1=0;

  double distance2=0;

  void deleteData() {
    DBRef.child('"'+widget.fingerPrint!+'"').remove();
  }


  double Distance(double lat1,double lon1,double lat2,double lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a))*1000;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if(!match)
    {
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
          widget.markers.add(Marker(position: LatLng(widget.valueMap[userFingerprint]["currentLocation_y"],
              widget.valueMap[userFingerprint]["currentLocation_x"]), markerId: MarkerId(userFingerprint+"current"),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)));
          widget.markers.add(Marker(position: LatLng(widget.valueMap[userFingerprint]["futureLocation_y"],
              widget.valueMap[userFingerprint]["futureLocation_x"]), markerId: MarkerId(userFingerprint+"future"),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
          print(userFingerprint);
          setState(() {
            match=true;
            distance1=Distance(widget.locationX!, widget.locationY!,
                widget.markers[1].position.longitude,widget.markers[1].position.latitude);
            print(distance1);
            distance2=Distance(widget.markers[0].position.longitude, widget.markers[0].position.latitude,
                widget.markers[2].position.longitude,widget.markers[2].position.latitude);
          });
        }
      });
    });
    }
    if(match==true)
    {
      timer?.cancel();
    }
    return Scaffold(
      body: !match?Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 50, 0, 0),
            child: !match?Text("우산공유자 등록 완료",style: TextStyle(fontSize: 35,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')):
            Text("우산필요자와 매칭",style: TextStyle(fontSize: 40,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')),
          ),
          Spacer(),
          Spacer(),
          Center(
            child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: !match?Text("우산필요한 사람과 매칭을 기다리는 중...",style: TextStyle(fontSize: 15,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')):
              Text("",style: TextStyle(fontSize: 0,color: Colors.lightBlue)),),
          ),
          Spacer(),
          Spacer(),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: !match?Text("필요자와 우산을 같이 쓰고 갈 수 있을 뿐만 아니라\n 중고우산을 팔 수도 있어요!",style: TextStyle(fontSize: 14,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')):
            Text("",style: TextStyle(fontSize: 0,color: Colors.lightBlue)),),
          Spacer(),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: !match?Text("필요자에게 정당한 대가를 요구해보세요.\n 물론 공짜도 좋지만요 :)",style: TextStyle(fontSize: 17,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')):
            Text("",style: TextStyle(fontSize: 0,color: Colors.lightBlue)),),
          Spacer(),
          Spacer(),
          OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
              onPressed:(){
                showDialog(
                    context: context,
                    barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text("주의\n\n정말로 취소하시겠어요?",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.lightBlue),),
                        insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                        actions: [
                          TextButton(
                            child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.lightBlue),),
                            onPressed: () {
                              timer?.cancel();
                              deleteData();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('취소',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.lightBlue),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                );
                },
              child: Text("등록취소",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
          Spacer(),

        ],
      ):Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 50, 0, 0),
            child: Text("우산필요자와 매칭 성공!",style: TextStyle(fontSize: 30,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')),
          ),
          Spacer(),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/2,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              onTap: (cordinate) {
                mapController.animateCamera(CameraUpdate.newLatLng(cordinate));
              },
              markers:widget.markers.toSet(),
            ),
          ),
          Spacer(),
          Text(
            '출발거리 차이: ${distance1.toStringAsFixed(3)} m',
            style: TextStyle(fontSize: 20.0, color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold'),
          ),
          Spacer(),
          Text(
            '도착거리 차이: ${distance2.toStringAsFixed(3)} m',
            style: TextStyle(fontSize: 20.0, color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold'),
          ),
          Spacer(),
          Spacer(),
          match?OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
              onPressed:(){
                timer?.cancel();
                DBRef.once().then((DatabaseEvent dataSnapshot){
                  String data=dataSnapshot.snapshot.value.toString();
                  valueMap=jsonDecode(data);
                  List<dynamic> currentfingerprintkeys=valueMap.keys.toList();
                  if(currentfingerprintkeys.contains(userFingerprint))
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => chatting(userFingerprint,widget.fingerPrint!,widget.fingerPrint!)));
                  }
                  else{
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("상대방이 매칭을 취소했습니다.\n 전 화면으로 돌아갑니다.",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.deepOrange),),
                            insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                            actions: [
                              TextButton(
                                child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.deepOrange),),
                                onPressed: () async{
                                  bool bannedUser=false;
                                  var collection_ban = FirebaseFirestore.instance.collection("bannedUser");
                                  var snapshots_ban = await collection_ban.get();
                                  for (var doc in snapshots_ban.docs) {
                                    var banneduser= await doc.reference.get();
                                    if(widget.fingerPrint==banneduser["fingerPrint"])
                                    {
                                      bannedUser=true;
                                      print("true");
                                    }
                                  }
                                  if(bannedUser==false)
                                  {
                                    var collection = FirebaseFirestore.instance.collection(userFingerprint+widget.fingerPrint!);
                                  var snapshots = await collection.get();
                                  for (var doc in snapshots.docs) {
                                    await doc.reference.delete();
                                  }
                                  }
                                  else{
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Text("당신은 밴유저입니다.\n\n2019037038로 문의주십시오.",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.red),),
                                            insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                                            actions: [
                                              TextButton(
                                                child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.red),),
                                                onPressed: () async{
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        }
                                    );
                                  }
                                  deleteData();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        }
                    );
                  }
                });
                  },
              child: Text("우산필요자와 대화",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)):Container(),
          Spacer(),
          OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor:Colors.deepOrange, side: BorderSide(width:5.0,color: Colors.deepOrange)),
              onPressed:(){
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text("주의\n\n정말로 취소하시겠어요?",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.deepOrange),),
                      insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                      actions: [
                        TextButton(
                          child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.deepOrange),),
                          onPressed: () {
                            timer?.cancel();
                            deleteData();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('취소',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.deepOrange),),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
              );},
              child: Text("매칭취소",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
          Spacer(),

        ],
      )
    );
  }
}
