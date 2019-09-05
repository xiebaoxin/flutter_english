import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class wxShareDialog extends StatelessWidget {
  const wxShareDialog(
      {Key key, this.title, this.content, this.img, this.imgid, this.url})
      : super(key: key);

  final Widget title;
  final Widget content;
  final String img;
  final String url;
  final String imgid;
/*

  _initFluwx() async{
    await fluwx.register(appId: GlobalConfig.wxAppId, doOnAndroid: true, doOnIOS: true, enableMTA: false);
    var result = await fluwx.isWeChatInstalled();
    print("is installed $result");
  }
*/

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
      actions: <Widget>[

        CupertinoDialogAction(
          child: const Text('微信好友'),
          onPressed: () {
            fluwx
                .share(WeChatShareImageModel(
                    image: img, // "assets://images/down_qrcode.png",
                    thumbnail: "assets://logo.png",
                    transaction: url,
                    scene: WeChatScene.SESSION,
                    description: "image"))
                .then((rv) {
              print(rv);
//              Navigator.pop(context, 'Cancel');
            });
          },
        ),
        CupertinoDialogAction(
          child: const Text('微信朋友圈'),
          onPressed: () {
            fluwx.share(WeChatShareImageModel(
                    image: img, //"assets://images/down_qrcode.png",
                    thumbnail: "",
                    transaction: url, //,
                    scene: WeChatScene.TIMELINE,
                    description: "护卡宝邀请您"));
          },
        ),

        CupertinoDialogAction(
          child: const Text('取消'),
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
        ),
      ],
    );
  }
}