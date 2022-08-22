import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tcard/tcard.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';

List<Color> colors = [
  Colors.blue,
  Colors.yellow,
  Colors.red,
  Colors.orange,
  Colors.pink,
  Colors.amber,
  Colors.cyan,
  Colors.purple,
  Colors.brown,
  Colors.teal,
];



class TCardPage extends StatefulWidget {

  String? fingerPrint;

  double? locationX;

  double? locationY;


  late List<Marker> markers = [];



  TCardPage(this.fingerPrint,this.locationX,this.locationY,this.markers);



  @override
  _TCardPageState createState() => _TCardPageState();

}

class _TCardPageState extends State<TCardPage> {

  late List<Marker> ProviderMarker;

  late GoogleMapController mapController;

  final DBRef=FirebaseDatabase.instance.reference();

  TCardController _controller = TCardController();



  late CameraPosition _initialPosition = CameraPosition(target: LatLng(widget.locationY!,widget.locationX!),zoom: 15);



  @override
  void initState() {
    super.initState();
    readData();
    setState(() {

    });
  }

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 200),
            TCard(
              cards: List.generate(
                colors.length,
                    (int index) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors[index],
                    ),
                    child: Column(
                      children: [
                        Spacer(),
                        Text(
                          '공유자 ${index + 1}',
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                        Spacer(),
                        Container(
                          width: 300,
                          height: 300,
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
                            markers: widget.markers.toSet(),
                          ),
                        ),
                        Spacer()
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
                    readData();
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
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text(_index.toString()),
      ),
    );
  }

  void readData() {
    DBRef.once().then((DatabaseEvent dataSnapshot){
      String data=dataSnapshot.snapshot.value.toString();
      Map valueMap=jsonDecode(data);
      List<dynamic> fingerprintkeys=valueMap.keys.toList();
      for(int i=0;i<fingerprintkeys.length;i++)
        {
          if(fingerprintkeys[i]!=widget.fingerPrint)
            {
              Map detail=valueMap[fingerprintkeys[i]];
              int id = Random().nextInt(100);
              ProviderMarker.add(Marker(position: LatLng(detail["currentLocation_x"], detail["currentLocation_y"]), markerId: MarkerId(id.toString())));
              print("hi");
              print(detail["currentLocation_x"]);
              print(widget.markers);
            }
        }
    });
  }
}

