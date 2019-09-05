import 'package:flutter/material.dart';
import '../../constants/index.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/DialogUtils.dart';
import '../../routers/application.dart';
import '../../components/ImageCropPage.dart';
import '../../model/globle_model.dart';
import '../../globleConfig.dart';
import '../../utils/dataUtils.dart';
import '../../utils/comUtil.dart';
import '../../utils/screen_util.dart';
import '../message_page.dart';
import '../../model/userinfo.dart';
import 'address.dart';
import 'set_paypwd.dart';
import 'set_pwd.dart';
import 'order_list.dart';
import 'bangdPhone.dart';
import '../../views/upgradeApp.dart';

class SetUserinfo extends StatefulWidget {
  @override
  SetUserinfoState createState() => new SetUserinfoState();
}

class SetUserinfoState extends State<SetUserinfo> {
  ShapeBorder _shape = GlobalConfig.cardBorderRadius;

  final Color _iconcolor = Colors.black26;
  Userinfo _userinfo = Userinfo.fromJson({});
  String _userAvatar;
  var rightArrowIcon = Icon(Icons.chevron_right, color: Colors.black26);

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Column(
                    children: <Widget>[
                      InkWell(
                        child: Column(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 15.0, 10.0, 15.0),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new Text(
                                    "头像",
                                    style: KfontConstant.defaultStyle,
                                  )),
                                  Container(
                                    width: 35.0,
                                    height: 35.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      image: new DecorationImage(
                                          image: _userAvatar == null
                                              ? AssetImage("images/logo.png")
                                              : NetworkImage(
                                                  _userAvatar + "?gp=0.jpg"),
                                          fit: BoxFit.cover),
                                      border: null,
                                    ),
                                  ),
                                  rightArrowIcon
                                ],
                              ),
                            ),
                            Divider(
                              height: 1.0,
                            )
                          ],
                        ),
                        onTap: () {
                        Application().checklogin(context, () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => ImageCropperPage()),
                          );
                        }).then((v)  {
                          DataUtils.freshUserinfo(context);
                        });
                        },
                      ),
/*
                      renderRow(
                          Icon(Icons.play_for_work, color: _iconcolor), "性别",texti: _userinfo.json['sex'].toString()=='0'?"男":"女",
                          ),*/
                      renderRow(
                          Icon(Icons.play_for_work, color: _iconcolor), "用户ID",texti: _userinfo.acount,
                          ),
                      renderRow(
                          Icon(Icons.play_for_work, color: _iconcolor), "昵称",texti: _userinfo.nickname,),

                      renderRow(Icon(Icons.play_for_work, color: _iconcolor),
                          _userinfo.phone != '' ? "已绑定${_userinfo.phone}" : "绑定手机",
                          index: 6),
                      renderRow(
                          Icon(Icons.play_for_work, color: _iconcolor), "版本",index: 7
                         ),

                    ],
                  ),
                ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                child: ComFunUtil().buildMyButton(
                  context,
                  '退出登录',
                      () {
                    DialogUtils.close2Logout(context, cancel: true);
                  }, width: 120,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  initinfo() {
    final model = globleModel().of(context);
    if (model.token != '') {
      setState(() {
        _userinfo = model.userinfo;
        _userAvatar = model.userinfo.avtar;
      });
    }

  }
  @override
  void initState() {
    initinfo();
    super.initState();
  }

  renderRow(
    Icon icon,
    String Txt, {
    int index = 0,
    String texti = '',
  }) {
    return new InkWell(
      child: Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
             /*   Container(
                  child: icon,
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                ),*/
                 Expanded(
                    child: new Text(
                  Txt,
                  style: KfontConstant.defaultStyle,
                )),

                Row(
                  children: <Widget>[
                    Text(texti),
                    index>0?   rightArrowIcon:SizedBox(width: 1,)
                  ],
                ),

              ],
            ),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
      onTap: () {
        _handleListItemClick(index);
      },
    );
  }

  _handleListItemClick(int index) {
    Application().checklogin(context, () {
      switch (index) {
        case 1:

          break;
        case 2:

//        Application.router.navigateTo(context, "/order");
          break;
        case 3:
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => AddressPage()),
          );
          break;
        case 4:
          ;
//          Navigator.push(
//            context,
//            new MaterialPageRoute(
//                builder: (context) => SetPaywsdPage(edit: _userinfo.paywsd)),
//          );
          break;
        case 5:
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => SetPasswordPage()),
          );
          break;
        case 6:
          Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => BandPhonePage(
                      phone: _userinfo.phone,
                    )),
          );
          /* Application.run(context, "/web",
            url: "${GlobalConfig.webbase}/Index/myshareuser/app/1/token/",
            title: '我的团队');*/
          break;
        case 7:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => upgGradePage(),
            ),
          );
          break;

        case 9:
          DialogUtils.close2Logout(context, cancel: true);
          break;
      }
    });
  }
}
