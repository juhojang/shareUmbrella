import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';


bool buttonTap=false;
bool userbuttonTap=false;
bool probuttonTap=false;

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
          AnimatedContainer(
            width: buttonTap ? 1000.0 : 1000.0,
            height: buttonTap ? 1000.0 : 1000.0,
            color: buttonTap ? Colors.blueAccent : Colors.transparent,
            alignment:
            buttonTap ? Alignment.center : AlignmentDirectional.topCenter,
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
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
                child: Text("share\numbrella",style: TextStyle(fontSize: 35,fontFamily: 'Silkscreen-Regular'),),
              ),
            ):AnimatedOpacity(
              opacity: 0,
              duration: Duration(seconds: 1),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text("share\numbrella",style: TextStyle(fontSize: 35,fontFamily: 'Silkscreen-Regular'),),
              ),
            ),
            Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  !probuttonTap?FloatingActionButton(
                    onPressed:(){
                      setState(() {
                        userbuttonTap=!userbuttonTap;
                        buttonTap=!buttonTap;
                      });
                    },
                    child: const Icon(Icons.person_outlined),
                  ):Container(),
                  !userbuttonTap?FloatingActionButton(
                    onPressed:(){
                      setState(() {
                        probuttonTap=!probuttonTap;
                        buttonTap=!buttonTap;
                      });
                    },
                    child: const Icon(Icons.people_alt_outlined),
                  ):Container(),
                ],
              ),
          ],
        ),
        ]
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void writeDataforUser() {
      DBRef.child(_fingerPrint!).set({
      'type':'사용자',
      'currentLocation_x': locationData?.longitude.toString(),
        'currentLocation_y': locationData?.latitude.toString(),
        'futureLocation' : 'x,y 좌표'
    });
  }

  void writeDataforProvider() {
    DBRef.child(_fingerPrint!).set({
      'type':'제공자',
      'currentLocation_x': locationData?.longitude.toString(),
      'currentLocation_y': locationData?.latitude.toString(),
      'futureLocation' : 'x,y 좌표'
    });
  }

  void readData() {
    DBRef.once().then((DatabaseEvent dataSnapshot){
      print(dataSnapshot.snapshot.value);
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

