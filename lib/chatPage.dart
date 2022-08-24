import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';
import 'package:firebase_database/firebase_database.dart';

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

  final myController = TextEditingController();

  final DBRef=FirebaseDatabase.instance.reference();

  void deleteData() {
    DBRef.child('"'+widget.myFingerPrint+'"').remove();
  }


  @override
  void initState() {
    super.initState();
    firestore.collection(widget.fingerPrintUser+widget.fingerPrintProvider).add({'name':"your name", "id":"your id"});
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
                  child: Text("취소",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Galmuri11-Bold'),)),
              Spacer(),
              Spacer(),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
                  onPressed:() {
                    showDialog(
                        context: context,
                        barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("주의\n\n정말로 도챡하셨나요?",style: TextStyle(fontFamily:"Galmuri11-Bold",fontSize: 20,color: Colors.lightBlue),),
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
        Bubble(
          margin: BubbleEdges.only(top: 20,left: 10,bottom: 10),
          elevation: 1,
          alignment: Alignment.topLeft,
          nip: BubbleNip.leftTop,
          child: Text('안녕하세요',style: TextStyle(fontFamily: 'Galmuri14',fontSize: 23),),
        ),
        Bubble(
          margin: BubbleEdges.only(top: 10,right: 10,bottom: 10),
          elevation: 1,
          alignment: Alignment.topRight,
          nip: BubbleNip.rightTop,
          color: Colors.lightBlue.shade200,
          child: Text('안녕하세요',style: TextStyle(fontFamily: 'Galmuri14',fontSize: 23,color: Colors.white),),
        ),
        Bubble(
          margin: BubbleEdges.only(top: 10,left: 10,bottom: 10),
          elevation: 1,
          alignment: Alignment.topLeft,
          nip: BubbleNip.leftTop,
          child: Text('우산좀 빌려주세요.',style: TextStyle(fontFamily: 'Galmuri14',fontSize: 23),),
        ),
        Bubble(
          margin: BubbleEdges.only(top: 10,right: 10),
          elevation: 1,
          alignment: Alignment.topRight,
          nip: BubbleNip.rightTop,
          color: Colors.lightBlue.shade200,
          child: Text('커피한잔 사주시면 우산 빌려드릴게요',style: TextStyle(fontFamily: 'Galmuri14',fontSize: 23,color: Colors.white),),
        ),
        Spacer(),
            Row(
              children: [
                Flexible(
                  child: TextField(
                      controller: myController,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontFamily:'Galmuri11-Bold',color: Colors.lightBlue.shade200),
                        hintText: ' 대화입력',
                      )
                  ),
                ),
                GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
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
      ]
    ),
    );
  }
}
