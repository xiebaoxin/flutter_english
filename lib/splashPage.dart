import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:package_info/package_info.dart';
import 'routers/application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './model/globle_model.dart';
import './utils/HttpUtils.dart';
import './utils/DialogUtils.dart';
import './utils/comUtil.dart';
import './utils/updateApp.dart';
import 'globleConfig.dart';
import './views/upgradeApp.dart';
import './model/userinfo.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<SplashPage> {
  Timer timer;
  bool _isupdate = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _packageInfoversion,_packageInfobuildNumber;
  void getNowVersion() async {
    // 获取此时版本
    var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfoversion=packageInfo.version;
      _packageInfobuildNumber=packageInfo.buildNumber;
    });
  }
  void _checkUpdateApp() async {
    SharedPreferences prefs = await _prefs;
    String isupdate ='';//prefs.getString('update') ?? '';//暂时每次更新

    if (isupdate == '') {
      if (await UpdateApp().checkDownloadApp) {
        _isupdate = await DialogUtils().showMyDialog(context, '有更新版本，是否马上更新?');
        if (!_isupdate) {
          prefs.setString("update", 'yes');
        } else {
          prefs.remove('update');
           await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => upgGradePage(),
            ),
          );
      /*         .then((result) {
            if(result){
              prefs.setString("update", 'yex');
            }
          });*/
        }
      }
    }

    timer = Timer(const Duration(milliseconds: 1500), () async {
      final model = globleModel().of(context);
      String token = model.token;
        var response = await HttpUtils.dioappi(
            'User/userInfo', {},
            context: context,
            withToken: true);
        if (response["status"] == 1) {
          await model.setlogin(token, response["userinfo"]);
        } else
          await model.setlogout();

        Application.run(context, "/home");
    });
  }

  @override
  void initState() {
    super.initState();
    getNowVersion();
    _checkUpdateApp();
  }

  @override
  void dispose() {
    if(timer!=null) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _splashWegit();
  }

  Widget _splashWegit() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
            ),
            child: Container(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 60,),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset(
                            'images/logo.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "毕学欢迎您",
                          style: new TextStyle(
                              color: GlobalConfig.mainColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("版本${_packageInfoversion}(${_packageInfobuildNumber})"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
