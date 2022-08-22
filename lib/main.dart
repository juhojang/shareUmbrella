import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'choose_umbrella.dart';
import 'awaitUser.dart';
import 'T_card.dart';


bool buttonTap=false;
bool userbuttonTap=false;
bool probuttonTap=false;
List<dynamic> fingerprintkeys=[];
Map valueMap={};

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  LocationData? locationData;

  late GoogleMapController _controller;

  late CameraPosition _initialPosition =
  CameraPosition(target: LatLng((locationData?.latitude)!, (locationData?.longitude)!),zoom: 17);

  List<Marker> markers = [];

  addMarker(cordinate) {
    int id = Random().nextInt(100);

    setState(() {
      if(markers.length==1)
      {
        markers[0]=Marker(position: cordinate, markerId: MarkerId(id.toString()));
      }
      else
      {
        markers.add(Marker(position: cordinate, markerId: MarkerId(id.toString())));
      }
    });
  }


  @override
  void initState() {
    super.initState();
    loadInfo();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }


  final DBRef=FirebaseDatabase.instance.reference();
  int _counter = 0;
  String? _fingerPrint;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              AnimatedContainer(
              width: buttonTap ? 1000.0 : 1000.0,
              height: buttonTap ? 1000.0 : 1000.0,
              color: buttonTap ? Colors.lightBlue : Colors.transparent,
              alignment:
              buttonTap ? Alignment.center : AlignmentDirectional.topCenter,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            ),
              buttonTap?userbuttonTap?Padding(
                padding: EdgeInsets.fromLTRB(0, 65, 0, 0),
                child: AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),child: Icon(Icons.person_outlined,color: Colors.white,size: 100,)),
              ):
              Padding(
                padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                child: AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),child: Icon(Icons.umbrella_outlined,color: Colors.white,size: 100,)),
              ):
              Container(),
              buttonTap?userbuttonTap?Padding(
                padding: EdgeInsets.fromLTRB(95,80,0, 0),
                child: AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),child: Text("사용자님 환영합니다.\n도착 위치 선택하세요.",style: TextStyle(color: Colors.white,fontSize: 30),)),
              ):Padding(
                padding: EdgeInsets.fromLTRB(90,80,0, 0),
                child: AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),child: Text("공급자님 환영합니다.\n도착 위치를 선택하세요",style: TextStyle(color: Colors.white,fontSize: 30),)),
              )
                  :Padding(
                padding: EdgeInsets.fromLTRB(0,80,0, 0),
                child: AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),child: Text("",style: TextStyle(color: Colors.white,fontSize: 30),)),
              ),
            ]
          ),
          !buttonTap?AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),child: Image(image: AssetImage('assets/images/Rain.gif'),fit: BoxFit.cover,height: double.infinity,))
              :AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),child: Image(image: AssetImage('assets/images/Rain.gif'),fit: BoxFit.cover,height: double.infinity,)),
          Column(
          children: [
            Spacer(),
            !buttonTap?AnimatedOpacity(
              opacity: 1,
              duration: Duration(seconds: 1),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text("share\numbrella",style: TextStyle(fontSize: 35,fontFamily: 'Silkscreen-Regular',color: Colors.lightBlue),),
              ),
            ):AnimatedOpacity(
              opacity: 0,
              duration: Duration(seconds: 1),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text("",style: TextStyle(fontSize: 35,fontFamily: 'Silkscreen-Regular'),),
              ),
            ),
            Spacer(),
            buttonTap?Container(
              width: 500,
              height: 500,
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (controller) {
                  setState(() {
                    _controller = controller;
                  });
                },
                markers: markers.toSet(),

                onTap: (cordinate) {
                  _controller.animateCamera(CameraUpdate.newLatLng(cordinate));
                  addMarker(cordinate);
                },
              ),
            ):Container(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  !probuttonTap?FloatingActionButton(
                    backgroundColor: Colors.lightBlue,
                    elevation: 0,
                    onPressed:(){
                      setState(() {
                        userbuttonTap=!userbuttonTap;
                        buttonTap=!buttonTap;
                        markers=[];
                      });
                    },
                    child: !userbuttonTap?Icon(Icons.person_outlined):Icon(Icons.cancel_outlined),
                  ):Container(),
                  !userbuttonTap?FloatingActionButton(
                    backgroundColor: Colors.lightBlue,
                    elevation: 0,
                    onPressed:(){
                      setState(() {
                        probuttonTap=!probuttonTap;
                        buttonTap=!buttonTap;
                        markers=[];
                      });
                    },
                    child: !probuttonTap?Icon(Icons.umbrella_outlined):Icon(Icons.cancel_outlined),
                  ):Container(),


                ],
              ),


          ],
        ),
          markers.length==1?AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),
            child: Padding(
              padding: EdgeInsets.fromLTRB(170,180,0, 0),
              child: OutlinedButton( onPressed: () {
                userbuttonTap?writeDataforUser(markers[0].position):writeDataforProvider(markers[0].position);
                DBRef.once().then((DatabaseEvent dataSnapshot){
                  String data=dataSnapshot.snapshot.value.toString();
                  valueMap=jsonDecode(data);
                  fingerprintkeys=valueMap.keys.toList();
                  userbuttonTap?Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TCardPage(_fingerPrint?.replaceAll('"', ''), locationData?.longitude, locationData?.latitude,markers,fingerprintkeys,valueMap)),
                  ):
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => awaitUser()),
                  );
                });

                },
                child: Text("선택완료",style: TextStyle(fontSize: 20,color: Colors.white)),
                style: OutlinedButton.styleFrom(side: BorderSide(width: 3.0,color: Colors.white)), ),
            ),
          ):AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),
            child: Padding(
              padding: EdgeInsets.fromLTRB(170,180,0, 0),
              child: OutlinedButton( onPressed: () { }, child: Text("선택완료",style: TextStyle(fontSize: 20,color: Colors.white)),style: OutlinedButton.styleFrom(side: BorderSide(width: 3.0,color: Colors.white)), ),
            ),
          )
        ]
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void writeDataforUser(LatLng latLng) {
      DBRef.child(_fingerPrint!).set({
      '"type"':'"사용자"',
      '"currentLocation_x"': locationData?.longitude,
        '"currentLocation_y"': locationData?.latitude,
        '"futureLocation_x"' : latLng.longitude,
        '"futureLocation_y"' : latLng.latitude
    });
  }

  void writeDataforProvider(LatLng latLng) {
    DBRef.child(_fingerPrint!).set({
      '"type"':'"제공자"',
      '"currentLocation_x"': locationData?.longitude,
      '"currentLocation_y"': locationData?.latitude,
      '"futureLocation_x"' : latLng.longitude,
      '"futureLocation_y"' : latLng.latitude
    });
  }

  void deleteData() {
    DBRef.child(_fingerPrint!).remove();
  }

  void loadInfo() async{
    Location location=new Location();
    LocationData _locationData=await location.getLocation();
    DeviceInfoPlugin deviceInfo=DeviceInfoPlugin();

    if(kIsWeb){
      WebBrowserInfo webBrowserInfo=await deviceInfo.webBrowserInfo;
      print(webBrowserInfo.userAgent);
    }
    else if (Platform.isAndroid){
      AndroidDeviceInfo androidInfo=await deviceInfo.androidInfo;
      print(androidInfo.fingerprint);
      setState(() {
        _fingerPrint=androidInfo.fingerprint;
        _fingerPrint=_fingerPrint?.replaceAll('.', '');
        _fingerPrint=_fingerPrint?.replaceAll('/', '');
        _fingerPrint=_fingerPrint?.replaceAll(':', '');
        _fingerPrint='"'+_fingerPrint!+'"';
        print(_fingerPrint);
        locationData=_locationData;
        print(_locationData.latitude);
        print(_locationData.longitude);
      });
    }
    else if(Platform.isIOS){
      IosDeviceInfo iosInfo=await deviceInfo.iosInfo;
      print(iosInfo.utsname.machine);
    }
  }
}

