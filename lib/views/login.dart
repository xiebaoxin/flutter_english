import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/globle_model.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../globleConfig.dart';
import '../utils/DialogUtils.dart';
import '../utils/HttpUtils.dart';
import '../utils/comUtil.dart';
import '../routers/application.dart';
import 'register.dart';
import 'fogetpwd.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _phoneState, _pwdState = false;
  String _checkStr = '', _wechaName, _unionId, _openid, _avatar;
  TextEditingController _phonecontroller = new TextEditingController();
  TextEditingController _pwdcontroller = new TextEditingController();
  Map<String, dynamic> _wxuserInfo;
  final FocusNode _focusNode = FocusNode();
  bool _loading = false;
  // 显示加载进度条
  void showLoadingDialog() {
    setState(() {
      _loading = true;
    });
    DialogUtils.showLoadingDialog(context);
  }

  // 隐藏加载进度条
  hideLoadingDialog() {
    if (_loading) {
      Navigator.of(context).pop();
      setState(() {
        _loading = false;
      });
    }
  }

  Future _userWxInfo(String code) async {
      Map<String, String> params = {
        "code": code,
      };
      showLoadingDialog();
      await HttpUtils.dioappi(
          "WxAppAuth/userWxInfo", params,
          context: context).then((response) async {
        hideLoadingDialog();
        if (response['data']['unionid'].isNotEmpty) {
          print(response['data']['unionid']);
          _wechaName = response['data']['nickname'];
          _unionId = response['data']['unionid'];
          _openid = response['data']['openid'];
          _avatar = response['data']['headimgurl'];
          _wxuserInfo = response['data'];
         await _checkWxlogin(_unionId);
        } else {
          _alertmag("微信认证失败!");
        }
        /*
        *{openid: oEJBM1crLLjW1lGFM5aoGs6id0ok, nickname: 努力吧, sex: 0, language: zh_CN, city: , province: , country: , headimgurl: http://thirdwx.qlogo.cn/mmopen/vi_32/666ZxTwTYHUu57JWG5trN0vMjt7icY9WrByHPL9Vtjic3S77k8yOHBswkVGZ0jhBUeAWFYNlIfMsSXKd3khEZKpQ/132, privilege: [], unionid: omxDS1GXNd_q74TIAsdblxFSDw4s}
        * */
      });
  }

  @override
  void initState() {
    super.initState();
    fluwx.responseFromAuth.listen((response) async{
      print('------------微信登录回调 response.errCode: ${response.errCode}');
      if (response.errCode == 0) {
        print("-------微信 response.code:${response.code}");
       await _userWxInfo(response.code);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _phoneState = null;
    _pwdState = null;
    _phonecontroller = null;
    _pwdcontroller = null;
    _wxuserInfo = null;
  }

  void _login() async {
    var _phone = _phonecontroller.text;
    var _pwd = _pwdcontroller.text;
    var pdata = {
      "phone": _phone,
      "password": _pwd,
      "unionid": _unionId,
      "openid": _openid,
      "nickname": _wechaName,
      "headimgurl": _avatar,
      "wxinfo": jsonEncode(_wxuserInfo),
    };

      showLoadingDialog();
      print(pdata);
      await HttpUtils.dioappi(
          "Pub/Login", pdata,
          context: context).then ((response) async {
        hideLoadingDialog();
        if (response["status"] == 1) {
          String token = response["userinfo"]["token"];
          if (token != null && token != "") {
            await _loginok(token, response["userinfo"]);
          } else {
            _alertmag("登录失败)");
          }
        } else {
          _alertmag("账号或密码错误");
        }
      });
  }

  Future _checkWxlogin(String unionId) async {
      if (unionId .isNotEmpty){
      var pdata = {
        "unionid": unionId,
      };

      await HttpUtils.dioappi(
          "Pub/checkWx", pdata,
          context: context).then ((response) async {
        print("----------------get userWxInfo--------------------");
        print(response["userinfo"]);
        _wechaName=_wechaName+":"+response["msg"];
        if (response["status"] == 1) {
            String token = response["userinfo"]["token"];
          await _loginok(token, response["userinfo"]);
        }else
          await _alertmag("微信登录失败:${response["msg"]}");
      });

    }
  }

  void _loginok(String token, Map<String, dynamic> userinfo) async {
    final model = globleModel().of(context);
    await model.setlogin(token, userinfo);
    print('正在登录到指定位置');
    Navigator.of(context).pop(true);
//    Application.run(context, "/home");
//    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
 /*//lutter 登录以后  会有返回箭头显示 因为  路由的切换导致不是路由的第一个页面，解决办法清空路由。
   Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => "\"
        ), (route) => route == null);*/
  }

  void _checkPhone() {
    if (_phonecontroller.text != null &&
        _phonecontroller.text.length == 11 &&
        ComFunUtil.isChinaPhoneLegal(_phonecontroller.text)) {
      _phoneState = true;
    } else {
      _phoneState = false;
    }
  }

  void _checkPwd() {
    if (_pwdcontroller.text != null &&
        _pwdcontroller.text.length >= 6 &&
        _pwdcontroller.text.length <= 10) {
      _pwdState = true;
    } else {
      _pwdState = false;
    }
  }

  void _alertmag(String msg) async {
    await DialogUtils.showToastDialog(context, msg);
  }

  void _checkSub() {
    _checkPhone();
    _checkPwd();
    if (_phoneState && _pwdState) {
      _checkStr = '';
    } else {
      if (!_phoneState) {
        _checkStr = '请输入11位手机号！';
      } else if (!_pwdState) {
        _checkStr = '请输入6-10位密码！';
      }
    }
    print(_checkStr);
    if (_checkStr == '') {
      _login();
    } else {
      _alertmag(_checkStr);
    }
  }

  Widget _buildotherTips() {
    return Padding(
      padding: new EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, //子组件的排列方式为主轴两端对齐
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => register(),
                  ));
            },
            child: Container(
              padding: EdgeInsets.all(15),
              child: Text(
                "注册",
                style: new TextStyle(fontSize: 14.0),
              ),
            ),
          ),
          SizedBox(width: 50,),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => fogetpwdPage(),
                  ));
            },
            child: Container(
              padding: EdgeInsets.all(15),
              child: Text(
                "忘记密码",
                style: new TextStyle(fontSize: 14.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeinxinButtonField() {
    return Padding(
        padding: new EdgeInsets.all(10.0),
        child: Visibility(
            visible: GlobalConfig.ios_show,
            child: Column(
          children: <Widget>[
            IconButton(
                iconSize: 30,
                icon: Image.asset(
                  "images/icon_wechat.png",
                  fit: BoxFit.fill,
                ),
                onPressed:_loading?null: () {
                  fluwx.sendAuth(scope: "snsapi_userinfo", state: "wechat_sdk_demo_test");
                }),
            Text("微信登录")
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
//    return WillPopScope(child:
      return  Scaffold(
               appBar: AppBar(
        title: new Text("登录${_loading?'中…':''}"),
        centerTitle: true,
      ),
          body: SingleChildScrollView(
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(height: 35.0),
                new Padding(
                    padding: new EdgeInsets.all(10.0),
                    child: Image.asset(
                      'images/logo.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    )),
                Text(_wechaName != null ? "您好，$_wechaName" : ''),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
                  child: new Stack(
                    alignment: new Alignment(1.0, 1.0),
                    //statck
                    children: <Widget>[
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new Padding(
                                padding:
                                    new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                                child: Icon(Icons.person,
                                    color: GlobalConfig.mainColor)),
                            new Expanded(
                              child: new TextField(
                                controller: _phonecontroller,
                                cursorColor: GlobalConfig.mainColor,
                                keyboardType: TextInputType.phone,
                                //光标切换到指定的输入框
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_focusNode),
                                decoration: new InputDecoration(
                                  hintText: '请输入手机号码',
                                  contentPadding: EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ]),
                      new IconButton(
                        icon: new Icon(Icons.clear, color: Colors.black45),
                        onPressed: () {
                          _phonecontroller.clear();
                        },
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 30.0),
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                            child: Icon(
                              Icons.lock,
                              color: GlobalConfig.mainColor,
                            )
                            /*   new Image.asset(
                            'images/icon_password.png',
                            width: 40.0,
                            height: 40.0,
                            fit: BoxFit.fill,
                          ),*/
                            ),
                        new Expanded(
                          child: new TextField(
                            controller: _pwdcontroller,
                            // 光标颜色
                            cursorColor: GlobalConfig.mainColor,
                            focusNode: _focusNode,
                            decoration: new InputDecoration(
                              hintText: '请输入密码',
                              contentPadding: EdgeInsets.all(10.0),
                              suffixIcon: new IconButton(
                                icon: new Icon(Icons.clear,
                                    color: GlobalConfig.mainColor),
                                onPressed: () {
                                  _pwdcontroller.clear();
                                },
                              ),
                            ),
                            obscureText: true,
                          ),
                        ),
                      ]),
                ),
                new Container(
                  width: 340.0,
                  child:  FlatButton(
                    color: GlobalConfig.mainColor,
                       child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          _wechaName != null ?'绑定账户登录': '登录',
                          style: new TextStyle(
                              color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                      onPressed:_loading?null: () {
                        _checkSub();
                      },
                    ),

                ),
                _buildotherTips(),
                _buildWeinxinButtonField(),
              ],
            ),
          ),
/*      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.unarchive),
        label: Text("测试"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => activeUser(),
            ));
        },
      ),*/
        );
       // ,onWillPop: _doubleExit);
  }

  int _lastClickTime = 0;
  Future<bool> _doubleExit() {
    int nowTime = new DateTime.now().microsecondsSinceEpoch;
    if (_lastClickTime != 0 && nowTime - _lastClickTime > 1500) {
      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: new Text('退出' + GlobalConfig.appName),
              content: new Text('确定要退出App吗'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    return Future.value(false);
                  },
                  child: new Text('取消'),
                ),
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    return Future.value(true);
                  },
                  child: new Text('确定'),
                ),
              ],
            ),
      );
      //Future.value(true);
    } else {
      _lastClickTime = new DateTime.now().microsecondsSinceEpoch;
      new Future.delayed(const Duration(milliseconds: 1500), () {
        _lastClickTime = 0;
      });
      return new Future.value(false);
    }
  }
}
