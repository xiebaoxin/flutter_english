import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globleConfig.dart';
import '../utils/updateApp.dart';
import '../utils/DialogUtils.dart';
import '../utils/comUtil.dart';


class upgGradePage extends StatefulWidget {
  @override
  upgGradePageState createState() => new upgGradePageState();
}

class upgGradePageState extends State<upgGradePage> {
  String _loading = '0';
  String _packageInfovs, _packageInfobn;
  String _newVersioncontent;
  String _conntent;
  var _ostypename;

  String _downurl ;


  Future<bool> checkInfo() async {
    print("<net---> download :");
    bool retslt = false;
//    setState(() {
      _ostypename =await UpdateApp.defaultTargetPlatform;
//    });

    final packageInfo = await PackageInfo.fromPlatform();
//    setState(() {
      _packageInfovs = packageInfo.version; //1.0.0
      _packageInfobn = packageInfo.buildNumber; //1
//    });

    String errorMsg = "";
    int statusCode;
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      errorMsg = "请检查网络";
      print("请检查网络");
      DialogUtils().showMyDialog(context, errorMsg);
    }


    try {
      Dio dio = UpdateApp.createInstance();
      String url ='';
      if (_ostypename == TargetPlatform.android) {
        url =  GlobalConfig.base + 'Pub/upGrade/type/0';
      } else if (_ostypename == TargetPlatform.iOS) {
        url =  GlobalConfig.base + 'Pub/upGrade/type/1';

      }

      await dio.get(url).then((Response response) async {
        print(response);
        statusCode = response.statusCode;
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          DialogUtils().showMyDialog(context, errorMsg);
        }
        if (response.data["update"] != null) {
          String newVersion = response.data["update"]['verCode'].toString();
          if (newVersion.compareTo(packageInfo.buildNumber) > 0) {
            print(newVersion + "|compareTo|" + packageInfo.buildNumber);

            setState(() {
              _newVersioncontent = "${response.data["update"]['ver']}(${newVersion})";
              _conntent=response.data["update"]['content'];
              if (_ostypename == TargetPlatform.android) {
                _downurl =  response.data["update"]["url"];
              } else if (_ostypename == TargetPlatform.iOS) {
                _downurl =response.data["update"]["url"];
              }

            });

            retslt = true;
          }

        }

      });
    } catch (exception) {
      DialogUtils().showMyDialog(context, exception.toString());
    }
    return retslt;
  }


  @override
  void initState() {
    checkInfo();
    super.initState();
//    initdown();
  }
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _key,
          body: Center(
              child: AlertDialog(
            title: Text("${GlobalConfig.appName}温馨提示"),
            content: Container(
              padding: const EdgeInsets.all(10.0),
              alignment: Alignment.center,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: <Widget>[
                  Text("当前版本:$_packageInfovs($_packageInfobn)"),
                  Text("新版本信息:" + (_newVersioncontent??"无新版") ),
                  Text(_conntent??"无"),
                  _downurl!=null?
                  RaisedButton(
                      elevation: 4,
                      child: Container(
                          alignment: Alignment.center,
                          width:100,
                          child: Text(
                            '升级',
                            style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'FZLanTing',
                                fontSize:16, color: Colors.white),
                            maxLines: 1,
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      onPressed:() {
                        launchURL(_downurl);

                      }):   SizedBox(height: 10,),
            Align(
                      alignment: Alignment.centerLeft,
                     child:
                     Row(
                       children: <Widget>[
                         FlatButton(
                           child: new Text("取消"),
                           onPressed: () {
                             Navigator.of(context).pop(false);
                           },
                         ),
                         FlatButton(
                           child: new Text("确定"),
                           onPressed: () {
                             Navigator.of(context).pop(true);
                           },
                         )
                       ],
                     )),
                      //Text(_loading == '0' ? "正在下载……，" : "已下载：$_loading%",style: TextStyle(color: Colors.red, fontSize: 14.0),)),
     /*           LinearProgressIndicator(
                    backgroundColor: Colors.blue,
                    value: _loading,
                    semanticsLabel: '正在下载新版本……',
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                  ),*/
                ],
              ),
            ),
          )),
        );
  }

  Future launchURL(String url) async {
//    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _key.currentState.showSnackBar(
          SnackBar(content: Text("无法打开网址")));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
