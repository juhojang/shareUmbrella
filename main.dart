import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:untitled17/main_view_model.dart';
import 'package:untitled17/kakao_login.dart';

void main() {
  KakaoSdk.init(nativeAppKey:'2bdac7212221fe813a050e450de93b6b');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  final viewModel=MainViewModel(KakaoLogin());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(viewModel.user?.kakaoAccount?.profile?.profileImageUrl??''),
            Text(
              '${viewModel.isLogined}',
              style: Theme.of(context).textTheme.headline4,
            ),
            InkWell(
              onTap: ()async{
                await viewModel.login();
                setState(() {
                });
              },
              child: Container(
                width: 200,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/kakao_login_medium_narrow.png")
                  )
                ),
              ),
            ),
            InkWell(
              onTap: ()async{
                await viewModel.logout();
                setState(() {
                });
              },
              child: Container(
                child: Center(
                  child: Text(
                      '로그아웃',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54
                  ),),
                ),
                width: 180,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    )
                ),
              ),
          ],
        ),
      ),
    );
  }
}
