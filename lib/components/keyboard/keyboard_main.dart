import 'package:flutter/material.dart';
import 'CustomJPasswordFieldWidget.dart';
import 'keyboard_widget.dart';
import 'pay_password.dart';

/// 支付密码  +  自定义键盘

class MpsKeyboard extends StatefulWidget {
  static final String sName = "enter";

  @override
  State<StatefulWidget> createState() {
    return keyboardState();
  }
}


class keyboardState extends State<MpsKeyboard> {
  String pwdData = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VoidCallback _showBottomSheetCallback;

  @override
  void initState() {
    _showBottomSheetCallback = _showBottomSheet;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext c) {
    return new Container(
      width: double.maxFinite,
      height: 300.0,
      color: Color(0xffffffff),
      child: new Column(
        children: <Widget>[
         Align(
              alignment: Alignment.centerRight,
              child:GestureDetector(
                onTap: (){Navigator.pop(context);},
                  child:Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:  Text(
                  '取消',
                  style: new TextStyle(fontSize: 18.0, color: Color(0xff333333)),
                  )
              ) ,
            ),
          ),

          new Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: new Text(
              '请输入支付密码',
              style: new TextStyle(fontSize: 18.0, color: Color(0xff333333)),
            ),
          ),

          ///密码框
          new Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: _buildPwd(pwdData),
          ),

//          new Padding(
//            padding: const EdgeInsets.only(top: 20.0),
//            child: new Text(
//              '不是登录密码或连续数字',
//              style: new TextStyle(fontSize: 12.0, color: Color(0xff999999)),
//            ),
//          ),

//          new Padding(
//            padding: const EdgeInsets.only(top: 30.0), //0xffff0303
//            child: new Text(
//              '密码输入错误，还可输入2次，超出将锁定账户。',
//              style: new TextStyle(fontSize: 12.0, color: Color(0xffffffff)),
//            ),
//          ),
        ],
      ),
    );
  }

  /// 密码键盘 确认按钮 事件
  void onAffirmButton() {
print("okpwd:$pwdData");
Navigator.of(context).pop(pwdData);
Navigator.of(context).pop(pwdData);
  }

  void _onKeyDown(KeyEvent data){
    if (data.isDelete()) {
      if (pwdData.length > 0) {
        pwdData = pwdData.substring(0, pwdData.length - 1);
        setState(() {});
      }
    } else if (data.isCommit()) {
      if (pwdData.length != 6) {
//        Fluttertoast.showToast(msg: "密码不足6位，请重试", gravity: ToastGravity.CENTER);
        return;
      }
      onAffirmButton();
    } else {
      if (pwdData.length < 6) {
        pwdData += data.key;
      }
      setState(() {});
    }
  }
  /// 底部弹出 自定义键盘  下滑消失
  void _showBottomSheet() {
    setState(() {
      // disable the button
      _showBottomSheetCallback = null;
    });
    _scaffoldKey.currentState
        .showBottomSheet<void>((BuildContext context) {
      return new MyKeyboard(_onKeyDown);
    })
        .closed
        .whenComplete(() {
      if (mounted) {
        setState(() {
          // re-enable the button
          _showBottomSheetCallback = _showBottomSheet;
        });
      }
    });
  }

  Widget _buildPwd(var pwd) {
    return new GestureDetector(
      child: new Container(
        width: 250.0,
        height:40.0,
//      color: Colors.white,
        child: new CustomJPasswordField(pwd),
      ),
      onTap: () {
        _showBottomSheetCallback();
      },
    );
  }
}
