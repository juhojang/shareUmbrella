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
            ElevatedButton(
              onPressed: ()async{
                await viewModel.login();
                setState(() {

                });
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: ()async{
                await viewModel.logout();
                setState(() {

                });
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
