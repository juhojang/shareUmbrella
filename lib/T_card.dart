import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcard/tcard.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';
import 'package:untitled37/main.dart';
import 'chatPage.dart';


late List<Marker> ProviderMarker=[];

class TCardPage extends StatefulWidget {

  String? fingerPrint;

  double? locationX;

  double? locationY;


  late List<Marker> markers = [];

  List<dynamic> fingerprintkeys=[];

  Map valueMap={};



  TCardPage(this.fingerPrint,this.locationX,this.locationY,this.markers,this.fingerprintkeys,this.valueMap);



  @override
  _TCardPageState createState() => _TCardPageState();

}

class _TCardPageState extends State<TCardPage> {


  late GoogleMapController mapController;

  final DBRef=FirebaseDatabase.instance.reference();

  TCardController _controller = TCardController();

  bool buttonTap=false;

  bool noPerson=false;

  List<Marker> viewMarker=[];


  late CameraPosition _initialPosition = CameraPosition(target: LatLng(widget.locationY!,widget.locationX!),zoom: 15);



  @override
  void initState() {
    super.initState();
    print("bye");
    print(widget.valueMap);
    if(fingerprintkeys.length==0)
      {
        print("noperson");
        noPerson=true;
      }
    for(int i=0;i<widget.fingerprintkeys.length;i++)
    {
      if(widget.fingerprintkeys[i]!=widget.fingerPrint)
      {
        print(widget.valueMap[widget.fingerprintkeys[i]]["currentLocation_y"]);
        widget.markers.add(Marker(position: LatLng(widget.valueMap[widget.fingerprintkeys[i]]["currentLocation_y"],
            widget.valueMap[widget.fingerprintkeys[i]]["currentLocation_x"]), markerId: MarkerId(widget.fingerprintkeys[i]+"current"),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)));
        widget.markers.add(Marker(position: LatLng(widget.valueMap[widget.fingerprintkeys[i]]["futureLocation_y"],
            widget.valueMap[widget.fingerprintkeys[i]]["futureLocation_x"]), markerId: MarkerId(widget.fingerprintkeys[i]+"future"),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
      }
    }
  }


  double Distance(double lat1,double lon1,double lat2,double lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a))*1000;
  }


  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 50, 0, 0),
            child: !buttonTap?Text("우산공유자 선택",style: TextStyle(fontSize: 40,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')):
            Text("우산공유자와 매칭",style: TextStyle(fontSize: 40,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')),
          ),
          !buttonTap?AnimatedOpacity(opacity: 0.1,duration: Duration(seconds: 1),child: Image(image: AssetImage('assets/images/rainy.gif'),fit: BoxFit.cover,height: double.infinity,))
              :AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),child: Image(image: AssetImage('assets/images/rainy.gif'),fit: BoxFit.cover,height: double.infinity,)),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: !buttonTap?Center(child: Text("이런\n 더 이상의 공유자가 없어요 :(",style: TextStyle(fontSize: 20,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold'))):
          Text("",style: TextStyle(fontSize: 40,color: Colors.lightBlue))),
          !buttonTap?Column(
            children: <Widget>[
              SizedBox(height: 120),

              !noPerson?Center(
                child: TCard(
                  size: Size(MediaQuery.of(context).size.width/1.1, MediaQuery.of(context).size.height/1.7),
                  cards: List.generate(
                    widget.markers.length~/2,
                        (int index) {
                          double distance1=Distance(widget.locationX!, widget.locationY!,
                              widget.markers[2*index+1].position.longitude,widget.markers[2*index+1].position.latitude);
                          print(distance1);
                          double distance2=Distance(widget.markers[0].position.longitude, widget.markers[0].position.latitude,
                              widget.markers[2*index+2].position.longitude,widget.markers[2*index+2].position.latitude);
                      return Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                          color: Colors.lightBlue,),
                        alignment: Alignment.center,
                        child: Center(
                          child: Stack(
                            children: [Column(
                              children: [
                                Spacer(),
                                Text(
                                  '공유자 ${index + 1}',
                                  style: TextStyle(fontSize: 20.0, color: Colors.white,fontFamily: 'Galmuri11-Bold'),
                                ),
                                Spacer(),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height/2.7,
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
                                    markers:{widget.markers[0],widget.markers[2*index+1],widget.markers[2*index+2]},
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '출발거리 차이: ${distance1.toStringAsFixed(3)} m',
                                  style: TextStyle(fontSize: 20.0, color: Colors.white,fontFamily: 'Galmuri11-Bold'),
                                ),
                                Spacer(),
                                Text(
                                  '도착거리 차이: ${distance2.toStringAsFixed(3)} m',
                                  style: TextStyle(fontSize: 20.0, color: Colors.white,fontFamily: 'Galmuri11-Bold'),
                                ),
                                Spacer(),
                              ],
                            ),
                            ]
                          ),
                        ),
                      );
                    },
                  ),
                  controller: _controller,
                  onForward: (index, info) {
                    _index = index;
                    print(info.direction);
                    setState(() {});
                  },
                  onBack: (index, info) {
                    _index = index;
                    setState(() {});
                  },
                  onEnd: () {
                    print('end');
                  },
                ),
              ):Container(),
              SizedBox(height: 20),
              !noPerson?Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Spacer(),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: FloatingActionButton(
                        backgroundColor: Colors.deepOrangeAccent.shade100,
                        onPressed: () {
                          _controller.back();
                        },
                        child: Icon(Icons.settings_backup_restore,size: 40,color: Colors.deepOrangeAccent,),
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: FloatingActionButton(
                        backgroundColor: Colors.green.shade100,
                        onPressed: () {
                          widget.fingerprintkeys.remove(widget.fingerPrint);
                          DBRef.child('"'+widget.fingerprintkeys[_index]+'"').set({
                            '"type"':'"제공자"',
                            '"currentLocation_x"': widget.valueMap[widget.fingerprintkeys[_index]]["currentLocation_x"],
                            '"currentLocation_y"': widget.valueMap[widget.fingerprintkeys[_index]]["currentLocation_y"],
                            '"futureLocation_x"' : widget.valueMap[widget.fingerprintkeys[_index]]["futureLocation_x"],
                            '"futureLocation_y"' : widget.valueMap[widget.fingerprintkeys[_index]]["futureLocation_y"],
                            '"selected"' : '"'+widget.fingerPrint!+'"'
                          });
                          setState(() {
                            buttonTap=true;
                          });
                        },
                        child: Icon(Icons.check,size: 70,color: Colors.green,),
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: FloatingActionButton(
                        backgroundColor: Colors.red.shade100,
                        onPressed: () {
                          _controller.forward();
                        },
                        child: Icon(Icons.cancel_outlined,size: 40,color: Colors.red,),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ):Container(),
            ],
        ):Column(
            children: [
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              Center(
                  child: Text("우산공유자에게 \n고마움에 대한 답례를 해보세요 :)",style: TextStyle(fontSize: 17,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')),
                ),
              Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
                  onPressed:(){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => chatting(widget.fingerPrint!,widget.fingerprintkeys[_index])));
                  },
                  child: Text("우산공유자와 대화",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
              Spacer(),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
                  onPressed:(){
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("주의\n\n정말로 취소하시겠어요?",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.lightBlue),),
                            insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                            actions: [
                              TextButton(
                                child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.lightBlue),),
                                onPressed: () {
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
                  child: Text("매칭취소",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
              Spacer(),
            ],
          ),
        ]
      ),
    );
  }
}

