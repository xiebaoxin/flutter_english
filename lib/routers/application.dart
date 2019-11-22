import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:fluro/fluro.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../views/video_detail_page.dart';
import '../views/details/details_page.dart';
import '../views/webView.dart';

class Application {
  static Router router;

  static void run(context, appuri,
      {String url, String title, bool withToken = true}) async {
    if (appuri.startsWith('/web')) {
      if (url != '') {
        await webto(context, appuri, title: title, url: url);
      } else {
        await DialogUtils.showToastDialog(context, '无效网址');
      }
    } else
      router.navigateTo(context, appuri, transition: TransitionType.native);
  }

  static Future webto(context, appuri, {String url, String title}) async {
    if (appuri.startsWith('/web')) {
//      appuri =   "/web?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title ?? '浏览')}";
//      await router.navigateTo( context, appuri, transition: TransitionType.fadeIn);

      await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => WebView(title, url),
        ),
      );
    } else {
      await DialogUtils.showToastDialog(context, '无效网址');
    }
  }

  checklogin(BuildContext context, Function callBack) async {
    var response = await HttpUtils.dioappi('User/checktoken', {},
        context: context, withToken: true);
    if (response["status"] == 1) {
      callBack();
    } else {
      await Navigator.pushNamed(context, '/login').then((v){
        if(v!=null && v==true && callBack!=null)
          callBack();
      });
    }
  }

  ///跳转到第二个界面
  static goodsDetail(context, int goodsId,{String vdtype='',Map<String, dynamic> item,}) {
  /*  router.navigateTo(context, '/details/$goodsId',
        transition: TransitionType.fadeIn);*/
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>vdtype.isNotEmpty&& item['vdurl'].isNotEmpty ? VideoDetailPage(goodsId,type: vdtype,vdurl: item['vdurl']??"",):DetailsPage(goodsId:goodsId.toString() ,),
      ),
    );
  }
}
/*
 onPressed: () {

  /*           Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(goodsId:'120'),
                    ),
                  );*/


            Application.router.navigateTo(context, "/login",
                transition: TransitionType.fadeIn);
          },
router.navigateTo(context, "/users/1234", transition: TransitionType.fadeIn);

          onTap: () {
                Application.router.navigateTo(context,
                   '/swip?pics=${Uri.encodeComponent(_buildPicsStr())}&currentIndex=${i.toString()}');
              },
//// /web?url=${Uri.encodeComponent(linkUrl)}&title=${Uri.encodeComponent('掘金沸点')}


//        var bodyJson = '{"url":'+cellItem.url+',"title":'+cellItem.modName+'}';
            //        url = "/web/$bodyJson";
onPressed: () {
                  var bodyJson = '{"user":1281,"pass":3041}';
                  router.navigateTo(context, '/home/$bodyJson');
                  // Perform some action
                },


          */

/*
    Navigator.push(context,
        new MaterialPageRoute(builder: (BuildContext context) {
      return Detail('45');
    }));
*/

/*    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
//          return Detail('45');
        return WebView('45', 'http://www.baidu.com');
        },
        transitionsBuilder:
            (___, Animation<double> animation, ____, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: RotationTransition(
              turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
              child: child,
            ),
          );
        })
    );*/
