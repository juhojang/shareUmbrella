
import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'awaitUser.dart';
import 'T_card.dart';
import 'chatPage.dart';


bool buttonTap=false;
bool userbuttonTap=false;
bool probuttonTap=false;
List<dynamic> fingerprintkeys=[];
Map valueMap={};

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
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

  late AdmobInterstitial interstitialAd;

  String admobBannerId='';

  double currentLocationDif=100.0;
  double futureLocationDif=100.0;

  LocationData? locationData;

  late GoogleMapController _controller;

  late CameraPosition _initialPosition =
  CameraPosition(target: LatLng((locationData?.latitude)!, (locationData?.longitude)!),zoom: 17);

  List<Marker> markers = [];

  addMarker(cordinate) {
    int id = Random().nextInt(100);

    setState(() {
      if(markers.length>=1)
      {
        markers=[];
        markers.add(Marker(position: cordinate, markerId: MarkerId(id.toString())));
        print(markers.length);
      }
      else
      {
        markers.add(Marker(position: cordinate, markerId: MarkerId(id.toString())));
      }
    });
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
    interstitialAd = AdmobInterstitial(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    );
    admobBannerId='ca-app-pub-3940256099942544/6300978111';
    loadInfo();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    interstitialAd.load();
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
                child: AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),child: Text("사용자님 환영합니다.\n도착 위치를 선택하세요.",style: TextStyle(color: Colors.white,fontSize: 25,fontFamily: 'Galmuri11-Bold'),)),
              ):Padding(
                padding: EdgeInsets.fromLTRB(90,80,0, 0),
                child: AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),child: Text("공급자님 환영합니다.\n도착 위치를 선택하세요",style: TextStyle(color: Colors.white,fontSize: 25,fontFamily: 'Galmuri11-Bold'),)),
              )
                  :Padding(
                padding: EdgeInsets.fromLTRB(0,80,0, 0),
                child: AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),child: Text("",style: TextStyle(color: Colors.white,fontSize: 30),)),
              ),
            ]
          ),
          !buttonTap?AnimatedOpacity(opacity: 0.2,duration: Duration(seconds: 1),child: Container(child: Image(image: AssetImage('assets/images/rainy.gif'),fit: BoxFit.cover,height: double.infinity,)))
              :AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),child: Image(image: AssetImage('assets/images/rainy.gif'),fit: BoxFit.cover,height: double.infinity,)),
          Column(
          children: [
            !buttonTap?Container(child: AdmobBanner(adUnitId: admobBannerId, adSize: AdmobBannerSize.BANNER,onBannerCreated: (AdmobBannerController controller){})):Container(),
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
            !buttonTap?AnimatedOpacity(
              opacity: 1,
              duration: Duration(seconds: 1),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text("같이 우산쓰자!",style: TextStyle(fontSize: 31,fontFamily: 'Galmuri11-Bold',color: Colors.lightBlue),),
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.6,
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
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed:(){
                      setState(() {
                        userbuttonTap=!userbuttonTap;
                        buttonTap=!buttonTap;
                        markers=[];
                      });
                    },
                    child: !userbuttonTap?Icon(Icons.person_outlined,color: Colors.lightBlue,size: 50,):Icon(Icons.cancel_outlined,size: 50),
                  ):Container(),
                  Spacer(),
                  userbuttonTap?Column(
                    children: [
                      Text("최대 현재위치 차이",style: TextStyle(fontFamily: 'Galmuri14',color: Colors.white),),
                      Container(
                        width: 150,
                        child: Slider(
                            activeColor: Colors.white,
                            inactiveColor: Colors.lightBlue,
                            thumbColor: Colors.white,
                            value: currentLocationDif,
                            max:1000.0,divisions:10,
                            label: currentLocationDif.round().toString()+'m',
                            onChanged: (double value){
                              setState(() {
                                currentLocationDif=value;
                              });}),
                      )
                    ],
                  ):Spacer(),
                  Spacer(),
                  userbuttonTap?Column(
                    children: [
                      Text("최대 도착위치 차이",style: TextStyle(fontFamily: 'Galmuri14',color: Colors.white),),
                      Container(
                        width: 150,
                        child: Slider(
                            activeColor: Colors.white,
                            inactiveColor: Colors.lightBlue,
                            thumbColor: Colors.white,
                            value: futureLocationDif,
                            max:1000.0,divisions:10,
                            label: futureLocationDif.round().toString()+'m',
                            onChanged: (double value){
                              setState(() {
                                futureLocationDif=value;
                              });}),
                      )
                    ],
                  ):Spacer(),
                  Spacer(),
                  !userbuttonTap?FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed:(){
                      setState(() {
                        probuttonTap=!probuttonTap;
                        buttonTap=!buttonTap;
                        markers=[];
                      });
                    },
                    child: !probuttonTap?Icon(Icons.umbrella_outlined,color: Colors.lightBlue,size: 50):Icon(Icons.cancel_outlined,size: 50),
                  ):Container(),


                ],
              ),


          ],
        ),
          markers.length==1?AnimatedOpacity(opacity: 1,duration: Duration(seconds: 1),
            child: Padding(
              padding: EdgeInsets.fromLTRB(170,MediaQuery.of(context).size.height/4.7,0, 0),
              child: OutlinedButton( onPressed: () async{
                if(userbuttonTap==true)
                  {
                    print('advertise');
                    interstitialAd.show();
                  }
                bool bannedUser=false;
                var collection_ban = FirebaseFirestore.instance.collection("bannedUser");
                var snapshots_ban = await collection_ban.get();
                for (var doc in snapshots_ban.docs) {
                  var banneduser= await doc.reference.get();
                  if(_fingerPrint?.replaceAll('"', '')==banneduser["fingerPrint"])
                  {
                    bannedUser=true;
                  }
                }
                if(bannedUser==false) {
                  userbuttonTap
                      ? writeDataforUser(markers[0].position)
                      : writeDataforProvider(markers[0].position);
                  DBRef.once().then((DatabaseEvent dataSnapshot) {
                    String data = dataSnapshot.snapshot.value.toString();
                    valueMap = jsonDecode(data);
                    fingerprintkeys = valueMap.keys.toList();
                    if (userbuttonTap == true) {
                      for (int i = 0; i < fingerprintkeys.length; i++) {
                        if (valueMap[fingerprintkeys[i]]["type"] == "사용자") {
                          valueMap.remove(fingerprintkeys[i]);
                          fingerprintkeys.remove(fingerprintkeys[i]);
                          i = i - 1;
                          print("remove");
                        }
                      }
                      for (int i = 0; i < fingerprintkeys.length; i++) {
                        print(fingerprintkeys[i]);
                        if (valueMap[fingerprintkeys[i]]["selected"] != null) {
                          valueMap.remove(fingerprintkeys[i]);
                          fingerprintkeys.remove(fingerprintkeys[i]);
                          i = i - 1;
                          print("erase");
                        }
                      }
                      for (int i = 0; i < fingerprintkeys.length; i++) {
                        double distanceCur=Distance(markers[0].position.latitude, markers[0].position.longitude,
                            valueMap[fingerprintkeys[i]]["currentLocation_y"], valueMap[fingerprintkeys[i]]["currentLocation_x"]);
                        if(distanceCur>currentLocationDif)
                        {
                          valueMap.remove(fingerprintkeys[i]);
                          fingerprintkeys.remove(fingerprintkeys[i]);
                          i = i - 1;
                        }
                      }
                      for (int i = 0; i < fingerprintkeys.length; i++) {
                        double distanceFut=Distance(markers[0].position.latitude, markers[0].position.longitude,
                        valueMap[fingerprintkeys[i]]["futureLocation_y"], valueMap[fingerprintkeys[i]]["futureLocation_x"]);
                        if(distanceFut>futureLocationDif)
                        {
                          valueMap.remove(fingerprintkeys[i]);
                          fingerprintkeys.remove(fingerprintkeys[i]);
                          i = i - 1;
                        }
                      }
                    }
                    print(fingerprintkeys);
                    userbuttonTap ? Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          TCardPage(_fingerPrint?.replaceAll('"', ''),
                              locationData?.longitude, locationData?.latitude,
                              markers, fingerprintkeys, valueMap)),
                    ) :
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          awaitUser(_fingerPrint?.replaceAll('"', ''),
                              locationData?.longitude, locationData?.latitude,
                              markers, fingerprintkeys, valueMap)),
                    );
                  });
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
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                  );
                }

                },
                child: Text("선택완료",style: TextStyle(fontSize: 20,color: Colors.white,fontFamily: 'Galmuri11-Bold')),
                style: OutlinedButton.styleFrom(side: BorderSide(width: 3.0,color: Colors.white)), ),
            ),
          ):AnimatedOpacity(opacity: 0,duration: Duration(seconds: 1),
            child: Padding(
              padding: EdgeInsets.fromLTRB(170,MediaQuery.of(context).size.height/4.7,0, 0),
              child: OutlinedButton( onPressed: () { }, child: Text("선택완료",style: TextStyle(fontSize: 20,color: Colors.white,fontFamily: 'Galmuri11-Bold')),style: OutlinedButton.styleFrom(side: BorderSide(width: 3.0,color: Colors.white)), ),
            ),
          )
        ]
      ),
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

