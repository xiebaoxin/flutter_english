import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fluro/fluro.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import './routers/routes.dart';
import './routers/application.dart';
import 'globleConfig.dart';
import './model/globle_model.dart';
import 'splashPage.dart';
import './model/cart.dart';
import './data/cart.dart';

import 'package:flutter/material.dart';
import 'package:flutter_english/video/demo_video_player.dart';
import 'video/main.dart';
import 'video/tx_semple.dart';
import 'video/audioplayer.dart';
import 'myhome.dart';

void maintest() => runApp(MyhomeApp());
class MyhomeApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter应用',
      home: MyHome(
        content: '黑马程序员',
      ),
      theme: ThemeData(primarySwatch: Colors.purple),
    );
  }
}

void main111() => runApp(MyVideoApp());
void main11() => runApp(new MaterialApp(home: new Scaffold(body: new AudioApp())));
////flutter packages pub run flutter_launcher_icons:main  --一键生成logo
void main() {
  runApp(Bixue(
    model: globleModel(),
  ));
  if (Platform.isAndroid) {
// 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(
            statusBarColor:  GlobalConfig.mainColor,
            statusBarIconBrightness: Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class Bixue extends StatefulWidget {
  final globleModel model;
  const Bixue({Key key, @required this.model}) : super(key: key);

  @override
  KukabaoState createState() => new KukabaoState();
}

class KukabaoState extends State<Bixue> {
  @override
  Widget build(BuildContext context) {
     final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
    return ScopedModel(
      model: widget.model,
      child: ScopedModel<globleModel>(
          model: widget.model,
          child: MaterialApp(
            title: '毕学',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
//              platform: TargetPlatform.iOS,
              primarySwatch: Colors.deepOrange,
//              primaryColor: GlobalConfig.mainColor,
              primaryIconTheme: const IconThemeData(color: Colors.white),
              brightness: Brightness.light,
              accentColor: Colors.orange,
            ),
//            color: GlobalConfig.mainColor,
//      initialRoute: "/",
            onGenerateRoute: Application.router.generator,
            onGenerateTitle: (context) {
              return '毕学';
            },
            builder: (BuildContext context, Widget child) {
              return Directionality(
                  textDirection: TextDirection.ltr,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1,
                    ),
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: Brightness.light,
                      ),
                      child: child,
                    ),
                  ));
            },
            home: SplashPage(),
          )),
    );
  }

  _initFluwx() async {
    await fluwx.register(
        appId: GlobalConfig.wxAppId,
        doOnAndroid: true,
        doOnIOS: true,
        enableMTA: false);
    var result = await fluwx.isWeChatInstalled();
    print("is installed $result");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initFluwx();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    fluwx.dispose();
  }

  @override
  void didUpdateWidget(Bixue oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
