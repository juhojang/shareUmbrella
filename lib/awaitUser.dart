import 'package:flutter/material.dart';

class awaitUser extends StatefulWidget {
  const awaitUser({Key? key}) : super(key: key);

  @override
  State<awaitUser> createState() => _awaitUserState();
}

class _awaitUserState extends State<awaitUser> {

  bool match=false;

  @override
  Widget build(BuildContext context) {
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
              Text("우산필요자와 매칭",style: TextStyle(fontSize: 40,color: Colors.lightBlue)),),
          ),
          Spacer(),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: !match?Text("필요자에게 정당한 대가를 요구해보세요.\n 물론 공짜도 좋지만요 :)",style: TextStyle(fontSize: 17,color: Colors.lightBlue,)):
            Text("우산필요자와 매칭",style: TextStyle(fontSize: 40,color: Colors.lightBlue)),),
          Spacer(),
          OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor:Colors.lightBlue, side: BorderSide(width:5.0,color: Colors.lightBlue)),
              onPressed:(){},
              child: Text("등록취소",style: TextStyle(color: Colors.white,fontSize: 20),)),
          Spacer(),

        ],
      )
    );
  }
}
