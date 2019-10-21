import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:core';
import 'dart:math' as math;
import 'package:fluwx/fluwx.dart' as fluwx;
import '../components/wxshare.dart';
import '../utils/comUtil.dart';
import '../utils/HttpUtils.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';
import '../utils/screen_util.dart';
import '../components/banner.dart';


class sharePage extends StatefulWidget {
  final bool ishome;
  sharePage({this.ishome=false});
  @override
  sharePageState createState() => new sharePageState();
}

class sharePageState extends State<sharePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  num _count=1;
  int _curindex = 0;
  int _defindex = 0;
  List<String> _picList=[] ;
  String _userid='0', _userName;

  Future<List<String>> _initPicList() async {
    final model = globleModel().of(context);
    _userid = model.userinfo.id;
    _userName = model.userinfo.name;
//
    await HttpUtils.dioappi('Pub/getWxShareImgs/user_id/${_userid}', {},context: context)
        .then((response) async {
      if (response['imglist'].isNotEmpty) {
        response['imglist'].forEach((ele) {
          if (ele.isNotEmpty) {
            _picList.add(ele['imgfile']);
          }
        });
      }
/*
      _count=_picList.length;
      _defindex=response['default']??0;*/
    });

    return _picList;
  }

  @override
  void initState() {
//    _initPicList();
    super.initState();
    fluwx.responseFromShare.listen((data) {
      print(data);
      print("微信分享回调:${data.errCode.toString()}");
//      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemUiOverlayStyle style = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(style);

    EdgeInsets padding = MediaQuery.of(context).padding;
    double top = math.max(padding.top, EdgeInsets.zero.top);
    return new Scaffold(
      backgroundColor: Colors.transparent,
      body:
      Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(0),
          child:   ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child:
              Center(
                  child: FutureBuilder(
                    future: _initPicList(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {      //snapshot就是_calculation在时间轴上执行过程的状态快照
                      switch (snapshot.connectionState) {
                        case ConnectionState.none: return new Text('Press button to start');    //如果_calculation未执行则提示：请点击开始
                        case ConnectionState.waiting: return new Text('页面过期，请返回重新进入...');  //如果_calculation正在执行则提示：加载中
                        default:    //如果_calculation执行完毕
                          if (snapshot.hasError)    //若_calculation执行出现异常
                            return new Text('Error: ${snapshot.error}');
                          else {
                            if (snapshot.hasData) {
                              return SwipperBanner(banners:snapshot.data,nheight:ScreenUtil.screenHeight,);
                            } else {
                              return Center(
                                child: Text("加载中"),
                              );
                            }
                          }   //若_calculation执行正常完成
//                    return new Text('Result: ${snapshot.data}');
                      }
                    },
                  )

              )),
        ),
        Positioned(
            top: top,
            left: 10.0,
            right: 10.0,
            child: Container(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  !widget.ishome ? IconButton(
                    icon: Icon(Icons.arrow_back_ios,color: Color(0xFFFFFFFF),),
                    tooltip: '返回',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ):SizedBox(width: 10,),
                  Container(
                      padding: EdgeInsets.all(0),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: GlobalConfig.mainColor,
                        shape: BoxShape.circle,),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Center(
                          child:IconButton(
                            icon: Icon(Icons.share,color: Color(0xFFFFFFFF),),
                            tooltip: '分享',
                            onPressed: () {
                              ComFunUtil().showSnackDialog(
                                context: context,
                                child: wxShareDialog(
                                  title: Text('微信分享'),
                                  content: Text('微信分享详细'),
                                  img: _picList[_curindex],
                                  url:
                                  //                                '${GlobalConfig.server}/Appi/api/register/fromuid/$_userid',
                                  '${GlobalConfig.server}/Appi/WxAuth/reg/fromuid/$_userid',
                                ),
                              );
                            },
                          ),
                        ),
                      ))

                ],
              ),
            )),
      ]),


    );
  }

}
