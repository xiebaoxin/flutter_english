import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:scoped_model/scoped_model.dart';
import '../utils/screen_util.dart';
import '../constants/index.dart';
import 'package:flutter/cupertino.dart';
import '../model/globle_model.dart';
import '../utils/DialogUtils.dart';
import '../routers/application.dart';
import '../globleConfig.dart';
import '../utils/HttpUtils.dart';
import '../utils/comUtil.dart';
import '../components/ImageCropPage.dart';
import '../utils/dataUtils.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'message_page.dart';
import '../model/userinfo.dart';
import 'TradePage.dart';
import 'person/address.dart';
import 'person/set_paypwd.dart';
import 'person/set_pwd.dart';
import 'person/order_list.dart';
import 'person/balance.dart';
import 'person/balancebutie.dart';
import 'person/bangdPhone.dart';
import 'person/usersetting.dart';
import 'person/childrenList.dart';
import 'person/myfavera.dart';
import 'person/recharge.dart';

class MyInfoPage extends StatefulWidget {
  @override
  MyInfoPageState createState() => new MyInfoPageState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class MyInfoPageState extends State<MyInfoPage> {
/*  @override
  bool get wantKeepAlive => true;*/
  double _top;
  String _token;
  ShapeBorder _shape = GlobalConfig.cardBorderRadius;

  final Color _iconcolor = Colors.black26;
  Userinfo _userinfo = Userinfo.fromJson({});
  String _userAvatar;
  bool _showMsg = true;
  var rightArrowIcon = Icon(Icons.chevron_right, color: Colors.black26);
  final double _appBarHeight = 230; // ScreenUtil.screenHeight; //256.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double _top = math.max(padding.top, EdgeInsets.zero.top);

    Widget mainscreen = Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              expandedHeight: 180,
              pinned: _appBarBehavior == AppBarBehavior.pinned,
              floating: _appBarBehavior == AppBarBehavior.floating ||
                  _appBarBehavior == AppBarBehavior.snapping,
              snap: _appBarBehavior == AppBarBehavior.snapping,
              centerTitle: true,
              title: Text(
                "个人中心",
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              leading: Text(""),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.settings),
                  tooltip: '设置',
                  onPressed: () {
                    Application().checklogin(context, () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => SetUserinfo()),
                      );
                    });
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                    padding: EdgeInsets.fromLTRB(
                        0, _top, 0, 2.0), //const EdgeInsets.all(8.0),
                    color: GlobalConfig.mainColor,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: _top + 25),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            height: 50,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                userinfo(),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: userlevel(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("积分:${_userinfo.point.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("余额:${_userinfo.money.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Container(
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text("签到",
                                              style: TextStyle(
                                                  color: Color(0xFFFFFFFF))),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Image.asset(
                                            "images/签到.png",
                                            width: 30.0,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Application().checklogin(context, () {
                                        HttpUtils.dioappi('User/user_sign', {},
                                            context: context, withToken: true)
                                            .then((response) async {
                                          await DialogUtils.showToastDialog(
                                              context, response['msg']);
                                          await DataUtils.freshUserinfo(context);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ])),
//                  stackmsg()
              )),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              renderRow('images/订单.png', "我的订单", index: 12),
              Divider(),
              renderRow('images/mustread.png', "我的收藏",index: 10),
              Divider(),
              renderRow('images/二维码.png', "专属二维码", index: 7),
              Divider(),
              renderRow('images/账户安全.png', "账户安全", index: 6),
              Divider(),
              renderRow('images/攻略.png', "邀请明细", index: 11),
              Divider(),

              renderRow('images/客服.png', "充值",index: 8),
              Divider(),
              renderRow('images/账户安全.png', "支付密码", index: 4),
              Divider(),
              renderRow('images/账户安全.png', "登录密码", index: 5),
              Divider(),
              renderRow(
                  'images/攻略.png',
                  "新手攻略",index: 19
              ),

              Divider(),
              renderRow('images/收货地址.png', "收货地址", index: 3),
              Divider(),
              renderRow('images/关于.png', "关于我们",index: 20),
              Divider(),
              renderRow('images/客服.png', "客服"),
              Divider(),
            ]),
          ),
        ],
      ),
    );

    return ScopedModelDescendant<globleModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          _token = model.token;
          if (_token != '') {
            _userinfo = model.userinfo;
            _userAvatar = model.userinfo.avtar;
          }
          return mainscreen;
        });
  }

  Widget userinfo() {
    return Row(
      children: <Widget>[
        InkWell(
          child: Container(
            width: 35.0,
            height: 35.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: new DecorationImage(
                  image: _userAvatar == null
                      ? AssetImage("images/logo.png")
                      : NetworkImage(_userAvatar + "?gp=0.jpg"),
                  fit: BoxFit.cover),
              border: null,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageCropperPage(),
                )).then((r) async {
              await DataUtils.freshUserinfo(context);
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
          child: Container(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("昵称：" + (_userinfo.nickname),
                    style: TextStyle(
                        fontFamily: "FZLanTing",
                        color: Colors.white,
                        fontSize: 16.0)),
                Text("ID:" + _userinfo.acount,
                    style: TextStyle(
                        fontFamily: "FZLanTing",
                        color: Colors.white,
                        fontSize: 14.0)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget userlevel() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                  int.tryParse(_userinfo.level) > 1
                      ? 'images/vip.png'
                      : 'images/vip-白.png',
                  width: 18.0,
                  height: 18.0),
              Text(_userinfo.levelname,
                  style: TextStyle(
                      color: int.tryParse(_userinfo.level) > 1
                          ? Color(0xFFF2CB51)
                          : Color(0xFFFFFFFF),
                      fontSize: 12.0))
              /*    Text("V${_userinfo.level ?? '0'}",
                  style: TextStyle(
                      color: int.tryParse(_userinfo.level) > 1
                          ? Color(0xFFF2CB51)
                          : Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0)),*/
            ],
          ),
          /* Text(_userinfo.levelname,
              style: TextStyle(
                  color: int.tryParse(_userinfo.level) > 1
                      ? Color(0xFFF2CB51)
                      : Color(0xFFFFFFFF),
                  fontSize: 12.0))*/
        ],
      ),
    );
  }

  Widget getIconImage(path) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: Image.asset(path, width: 20, height: 20),
    );
  }

  Widget buildIconitem(String asimg, String title,) {
    return  ListTile(
        /*  leading:  Container(
                height: 28,
                width: 28,
                child: Icon(Icons.account_balance,color: Colors.grey,),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  *//*        image: new DecorationImage(
                    image: AssetImage(asimg),
                    fit: BoxFit.fill,
                  ),*//*
                ),
              ),*/
            title:
            Text(
              title,
              style: KfontConstant.defaultStyle,
            ),
       trailing: Icon(Icons.keyboard_arrow_right,color: Colors.grey,),
       /* Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 28,
                width: 28,
                child: Icon(Icons.account_balance,color: Colors.grey,),
                decoration: new BoxDecoration(
                  color: Colors.white,
          *//*        image: new DecorationImage(
                    image: AssetImage(asimg),
                    fit: BoxFit.fill,
                  ),*//*
                ),
              ),
            ),
            Text(
              title,
              style: KfontConstant.defaultSubStyle,
            )
          ],
        )*/
    );
  }

  Widget adsRow() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 80,
          child: Padding(
              padding: const EdgeInsets.all(0),
              child:InkWell(
                child: Center(
                  child: Image.asset(
                    'images/gift.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: (){
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('正在加紧开发中…'),
                  ));
                },
              ) ),
        ));
  }


  Widget mainbuid() {
    return
        Container(
          alignment: Alignment.center,
          width: GlobalConfig.cardWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: _shape, //,
              elevation: 5,
              child:  Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                                children: <Widget>[
                                  renderRow('images/订单.png', "我的订单", index: 12),
                                  renderRow('images/二维码.png', "专属二维码", index: 7),
                                  renderRow('images/账户安全.png', "账户安全", index: 6),
                                  renderRow('images/攻略.png', "邀请明细", index: 11),

                                  renderRow('images/收货地址.png', "收货地址", index: 3),
                                  renderRow('images/账户安全.png', "支付密码", index: 4),
                                  renderRow('images/账户安全.png', "登录密码", index: 5),
                                  renderRow(
                                      'images/攻略.png',
                                      "新手攻略",index: 19
                                  ),

                                  renderRow('images/客服.png', "充值",index: 8),
                                  renderRow('images/关于.png', "关于我们",index: 20),
                                  renderRow('images/客服.png', "客服"),
                                  SizedBox(height: 50,width: 50,)
                                ],
                              ),
              ),
                          )

        ),
    );
  }
  Widget mainbuid111() {
    return Column(
      children: <Widget>[
//        SizedBox(
//          height: 60,
//        ),
        Container(
          alignment: Alignment.center,
          width: GlobalConfig.cardWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: _shape, //,
              elevation: 5,
              child: Column(
                children: <Widget>[
               /*   SizedBox(
                    height: 50,
                  ),*/
                  Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                renderRow('images/订单.png', "我的订单", index: 12),
                                renderRow('images/二维码.png', "专属二维码", index: 7),
                                renderRow('images/账户安全.png', "账户安全", index: 6),
                                renderRow('images/攻略.png', "邀请明细", index: 11),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                renderRow('images/收货地址.png', "收货地址", index: 3),
                                renderRow('images/账户安全.png', "支付密码", index: 4),
                                renderRow('images/账户安全.png', "登录密码", index: 5),
                                renderRow(
                                    'images/攻略.png',
                                    "新手攻略",index: 19
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                renderRow('images/客服.png', "充值",index: 8),
                                renderRow('images/关于.png', "关于我们",index: 20),
                                renderRow('images/客服.png', "客服"),
                                SizedBox(height: 50,width: 50,)
                              ],
                            ),
                          )
                        ],
                      )

                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  renderRow(
      String iconnm,
      String Txt, {
        int index = 0,
      }) {
    return Container(
      alignment: Alignment.center,
      child: InkWell(
        child: buildIconitem(iconnm, Txt),
        onTap: () {
          _handleListItemClick(index);
        },
      ),
    );
  }

  _handleListItemClick(int index) async{
    if(index==0 ){
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('正在加紧开发中…'),
      ));
    }
    else if(index==19){
      Application.run(context, "/web",url: '${GlobalConfig.base}/Api/xinshougl',title: '新手攻略',withToken: false);
    }
    else if(index==20){
      Application.run(context, "/web",url: '${GlobalConfig.base}/Api/about',title: '关于我们',withToken: false);
    }
    else{
      await Application().checklogin(context, () {
        switch (index) {
          case 1:
          /*  Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new TradeHistoryPage()),
            );*/
            break;
          case 2:
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => OrderListPage()),
            );
//        Application.router.navigateTo(context, "/order");
            break;
          case 3:
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => AddressPage()),
            );
            break;
          case 4:
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => SetPaywsdPage(edit: _userinfo.paywsd)),
            );
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
            Application.router.navigateTo(context, "/share");
            break;
         case 8:
          Navigator.push(
             context,
             new MaterialPageRoute(
                 builder: (context) => reChargePage()),
           );
            break;
          case 9:
            DialogUtils.close2Logout(context, cancel: true);
            break;
          case 10:
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => MyfaveratePage()),
            );
            break;
          case 11:
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => Childrens()),
            );
            break;
          case 12:
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => OrderListPage()),
            );
            break;

          default:
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('正在加紧开发中…'),
            ));
            break;
        }
      });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final List<Map<String, dynamic>> maplist = [
    {"img": 'images/数字资产.png', "txt": "数字资产", 'index': 1},
    {"img": 'images/订单.png', "txt": "我的订单", 'index': 2},
    {"img": 'images/攻略.png', "txt": "收货地址", 'index': 3},
    {"img": 'images/攻略.png', "txt": "支付密码", 'index': 4},
    {"img": 'images/攻略.png', "txt": "登录密码", 'index': 5},
    {
      "img": 'images/攻略.png',
      "txt": "绑定手机",
      'index': 6
    }, //_userinfo.phone != '' ? "已绑定手机" :
    {"img": 'images/攻略.png', "txt": "邀请有奖", 'index': 7},
    {"img": 'images/攻略.png', "txt": "关于我们", 'index': 8},
    {"img": 'images/攻略.png', "txt": "帮助&客服", 'index': 9},
  ];
  List<Widget> getWidgetList() {
    return maplist.map((item) => getItemContainer(item)).toList();
  }

  Widget getItemContainer(Map<String, dynamic> item) {
    return renderRow(item['img'], item['txt'], index: item['index']);
  }
}
