import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import '../components/ToastDialog.dart';
import '../components/LoadingDialog.dart';
import '../model/globle_model.dart';

class DialogUtils extends Dialog {
  static Widget uircularProgress(){
    return CircularProgressIndicator(
      strokeWidth: 4.0,
      valueColor:
      AlwaysStoppedAnimation<Color>(Colors.deepOrange),
    );

  }


  // 显示加载对话框
  static showLoadingDialog(context, {text}) {
    showDialog<Null>(
        context: context, // BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            // 调用对话框
            text: text ?? '加载中...',
          );
        });
  }

  // 关闭加载对话框
  static closeLoadingDialog(context) {
    Navigator.pop(context);
  }

  static close2Logout(context,{bool cancel=false}) async {
    final model = globleModel().of(context);
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: new Text(
              '登录验证',
              style: new TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            ),
            content: new Text('请重新登录！'),
            actions: <Widget>[
               new FlatButton(
                child:  Text(cancel ?"取消":''),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                  onPressed: () async {
                    await model.setlogout();
                    print('正在退出……');
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/login');
//                    Navigator.pushNamedAndRemoveUntil(context, '/login', (Route router) => false);
                  },
                  child: new Text('确定')),
            ],
          ),
    );
  }

  Future<bool> showMyDialog(context, String text) {
    return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => new AlertDialog(
                    title: new Text("温馨提示"),
                    content: new Text(text),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("取消"),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      new FlatButton(
                        child: new Text("确定"),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    ])) ??
        false;
  }


  Future showToast(context, text,{duration}) async{
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ToastDialog(
            text: text ?? '操作成功',
          );
        });
    await Future.delayed(Duration(milliseconds:  duration ?? 3000)); //等待秒
    Navigator.pop(context);

  }

  /// 显示文字对话框
  static showToastDialog(context, text,{duration}) async{
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ToastDialog(
            text: text ?? '操作成功',
          );
        });
    // 定时器关闭对话框
    await Future.delayed(Duration(milliseconds:  duration ?? 1200)); //等待秒
    Navigator.pop(context);

  }
}
