import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart';

class chatting extends StatefulWidget {

  String fingerPrintUser="";
  String fingerPrintProvider="";
  String myFingerPrint="";


  chatting(this.fingerPrintUser,this.fingerPrintProvider,this.myFingerPrint);

  @override
  State<chatting> createState() => _chattingState();
}

class _chattingState extends State<chatting> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  ScrollController _scrollController = new ScrollController();

  final myController = TextEditingController();

  final DBRef=FirebaseDatabase.instance.reference();

  void deleteData() {
    DBRef.child('"'+widget.myFingerPrint+'"').remove();
  }

  int backedUser=0;

  List<String> myText=[];

  List<dynamic> timeList=[];

  Widget Listview_builder(){
    return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 10),
      scrollDirection: Axis.vertical,
        itemCount: myText.length,
        itemBuilder:(BuildContext context,int index){
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("${timeList[index]}",style: TextStyle(fontFamily: 'Galmuri14'),),
              Bubble(
                margin: BubbleEdges.only(top: 10,right: 10,bottom: 10),
                elevation: 1,
                alignment: Alignment.topRight,
                nip: BubbleNip.rightTop,
                color: Colors.lightBlue.shade200,
                child: Text('${myText[index]}',style: TextStyle(fontFamily: 'Galmuri14',fontSize: 23,color: Colors.white),),
              ),
            ],
          );
        }
    );
  }


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
          child: Row(
            children: [
              Text("채팅",style: TextStyle(fontSize: 40,color: Colors.lightBlue,fontFamily: 'Galmuri11-Bold')),
              Spacer(),
              OutlinedButton(
                    style: OutlinedButton.styleFrom(backgroundColor:Colors.red, side: BorderSide(width:5.0,color: Colors.red)),
                    onPressed:(){
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text("주의\n\n정말로 신고하시겠어요?\n신고하면 대화기록이 저장되고 상대방은 밴유저로 기록됩니다.",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.red),),
                              insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                              actions: [
                                TextButton(
                                  child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.red),),
                                  onPressed: () async{
                                    if(widget.fingerPrintProvider!=widget.myFingerPrint)
                                    {
                                      firestore.collection("bannedUser").add({"fingerPrint":widget.fingerPrintProvider});
                                    }
                                    else{
                                      firestore.collection("bannedUser").add({"fingerPrint":widget.fingerPrintUser});
                                    }
                                    deleteData();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('취소',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.red),),
                                  onPressed: () {
                                    firestore.collection('chat').doc("chatDetail").delete();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    },
                    child: Text("신고",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
              Spacer(),
              Spacer(),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor:Colors.deepOrange, side: BorderSide(width:5.0,color: Colors.deepOrange)),
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
                                onPressed: () async{
                                  DBRef.once().then((DatabaseEvent dataSnapshot) async{
                                    String data=dataSnapshot.snapshot.value.toString();
                                    valueMap=jsonDecode(data);
                                    List<dynamic> currentfingerprintkeys=valueMap.keys.toList();
                                    if(currentfingerprintkeys.contains(widget.fingerPrintUser)&&currentfingerprintkeys.contains(widget.fingerPrintProvider))
                                    {
                                      deleteData();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    }
                                    else {
                                      var collection = FirebaseFirestore.instance.collection(widget.fingerPrintUser+widget.fingerPrintProvider);
                                      var snapshots = await collection.get();
                                      for (var doc in snapshots.docs) {
                                        await doc.reference.delete();
                                      }
                                      deleteData();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();

                                    }
                                  });
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
                  child: Text("취소",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
              Spacer(),
              Spacer(),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
                  onPressed:() {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("주의\n\n정말로 도착하셨나요?",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.lightBlue),),
                            insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                            actions: [
                              TextButton(
                                child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.lightBlue),),
                                onPressed: () async{
                                  var collection = FirebaseFirestore.instance.collection(widget.fingerPrintUser+widget.fingerPrintProvider);
                                  var snapshots = await collection.get();
                                  for (var doc in snapshots.docs) {
                                    await doc.reference.delete();
                                  }
                                  deleteData();
                                  Navigator.of(context).pop();
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
                  child: Text("도착완료",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
              Spacer(),
            ],
          )
        ),
        Expanded(child: Listview_builder()),
            Container(
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                        controller: myController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          hintStyle: TextStyle(fontFamily:'Galmuri11-Bold',color: Colors.lightBlue.shade200),
                          hintText: ' 대화입력',
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DBRef.once().then((DatabaseEvent dataSnapshot){
                        String data=dataSnapshot.snapshot.value.toString();
                        valueMap=jsonDecode(data);
                        List<dynamic> currentfingerprintkeys=valueMap.keys.toList();
                        if(currentfingerprintkeys.contains(widget.fingerPrintUser)&&currentfingerprintkeys.contains(widget.fingerPrintProvider))
                        {
                          myText.add(myController.text);
                          myController.clear();
                          timeList.add(DateTime.now().hour.toString()+':'+DateTime.now().minute.toString()+':'+DateTime.now().second.toString());
                          firestore.collection(widget.fingerPrintUser+widget.fingerPrintProvider).add({'name':widget.myFingerPrint, "text":myText.last,"time":DateTime.now()});
                          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                          setState(() {
                          });
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
                                      child: const Text('신고',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.red),),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: Text("주의\n\n정말로 신고하시겠어요?\n신고하면 대화기록이 저장되고 상대방은 밴유저로 기록됩니다.",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.red),),
                                                insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.red),),
                                                    onPressed: () async{
                                                      if(widget.fingerPrintProvider!=widget.myFingerPrint)
                                                      {
                                                        firestore.collection("bannedUser").add({"fingerPrint":widget.fingerPrintProvider});
                                                      }
                                                      else{
                                                        firestore.collection("bannedUser").add({"fingerPrint":widget.fingerPrintUser});
                                                      }
                                                      deleteData();
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('취소',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.red),),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('확인',style: TextStyle(fontFamily: "Galmuri11-Bold",color: Colors.deepOrange),),
                                      onPressed: () async{
                                        var collection = FirebaseFirestore.instance.collection(widget.fingerPrintUser+widget.fingerPrintProvider);
                                        var snapshots = await collection.get();
                                        for (var doc in snapshots.docs) {
                                          await doc.reference.delete();
                                        }
                                        deleteData();
                                        Navigator.of(context).pop();
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
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.lightBlue.shade200,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.lightBlue[200],
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                      ),
                      child: Container(
                        height: 40,
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '보내기',style: TextStyle(fontFamily: 'Galmuri11-Bold',color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ]
    ),
    );
  }
}
