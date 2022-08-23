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

  List<Marker> viewMarker=[];


  late CameraPosition _initialPosition = CameraPosition(target: LatLng(widget.locationY!,widget.locationX!),zoom: 15);



  @override
  void initState() {
    super.initState();
    print("bye");
    print(widget.valueMap);
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
    print("hey");
    print(widget.markers.toSet());
    return Scaffold(
      body: Stack(
        children: [
          !buttonTap?AnimatedOpacity(opacity: 0.1,duration: Duration(seconds: 1),child: Image(image: AssetImage('assets/images/rainy.gif'),fit: BoxFit.cover,height: double.infinity,))
              :AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),child: Image(image: AssetImage('assets/images/rainy.gif'),fit: BoxFit.cover,height: double.infinity,)),
          !buttonTap?Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 100),
              TCard(
                size: Size(400, 600),
                cards: List.generate(
                  widget.markers.length~/2,
                      (int index) {
                        double distance1=Distance(widget.locationX!, widget.locationY!,
                            widget.markers[2*index+1].position.longitude,widget.markers[2*index+1].position.latitude);
                        print(distance1);
                        double distance2=Distance(widget.markers[0].position.longitude, widget.markers[0].position.latitude,
                            widget.markers[2*index+2].position.longitude,widget.markers[2*index+2].position.latitude);
                    return Container(
                      color: Colors.lightBlue,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Spacer(),
                          Text(
                            '공유자 ${index + 1}',
                            style: TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                          Spacer(),
                          Container(
                            width: 400,
                            height: 400,
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
                            style: TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                          Spacer(),
                          Text(
                            '도착거리 차이: ${distance2.toStringAsFixed(3)} m',
                            style: TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                          Spacer(),
                        ],
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      _controller.back();
                    },
                    child: Text('되돌리기'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _controller.forward();
                    },
                    child: Text('다른 공유자'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _controller.reset();
                    },
                    child: Text('리셋'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      buttonTap=true;
                      setState(() {
                      });
                    },
                    child: Text('선택'),
                  )
                ],
              ),
            ],
          ),
        ):Container(),
        ]
      ),
    );
  }
}

