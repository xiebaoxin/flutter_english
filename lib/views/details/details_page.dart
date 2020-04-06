import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:core';
import 'package:scoped_model/scoped_model.dart';
import '../../components/banner.dart';
import 'details_explain.dart';
import 'details_tabar.dart';
import 'details_web.dart';
import 'details_shop.dart';
import '../../model/globle_model.dart';
import '../../utils/screen_util.dart';
import '../../utils/HttpUtils.dart';
import '../../components/loading_gif.dart';
import '../../routers/application.dart';
import '../../model/goods.dart';
import 'addcartItem.dart';
import '../../globleConfig.dart';
import '../../utils/comUtil.dart';
import '../../views/cart/cart.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailsPage extends StatefulWidget {
  final String goodsId;
  DetailsPage({Key key, this.goodsId}) : super(key: key);

  @override
  ContactsDemoState createState() => ContactsDemoState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class ContactsDemoState extends State<DetailsPage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  final double _appBarHeight = ScreenUtil.screenWidth; //256.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  GoodInfo _goodsinfo;
  String _action = "0";

  @override
  Widget build(BuildContext context) {
    TargetPlatform platform = defaultTargetPlatform;
    if (platform != TargetPlatform.iOS) {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        //statusBarIconBrightness: Brightness.dark
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }

    return Material(
      child:   FutureBuilder(
        future: getgoods(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //snapshot就是_calculation在时间轴上执行过程的状态快照
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text(
                  'Press button to start'); //如果_calculation未执行则提示：请点击开始
            case ConnectionState.waiting:
              return  Scaffold(
                  body:Column(
                    children: <Widget>[
                      SizedBox(height: 100,),
                      Loading(),
                      new Text(
                          '请稍候，正在加载...'),
                    ],
                  )); //如果_calculation正在执行则提示：加载中
            default: //如果_calculation执行完毕
              if (snapshot.hasError) //若_calculation执行出现异常
                return new Text('Error: ${snapshot.error}');
              else {
                if (snapshot.hasData) {
                  _goodsinfo = snapshot.data;
                  String titile=_goodsinfo.goodsName.toString();
                  return Scaffold(
                      key: _scaffoldKey,
                      body:CustomScrollView(
                        slivers: <Widget>[
                          SliverAppBar(
                            elevation: 0.0,
                            expandedHeight: _appBarHeight-50,
                            pinned: _appBarBehavior == AppBarBehavior.pinned,
                            floating: _appBarBehavior == AppBarBehavior.floating || _appBarBehavior == AppBarBehavior.snapping,
                            snap: _appBarBehavior == AppBarBehavior.snapping,
                            centerTitle: false,
//                                title: Text(""),
                            flexibleSpace: FlexibleSpaceBar(
//                                    centerTitle: true,
                                title: Text(
                                  titile.length<=12 ? titile : titile.substring(0,12)+"…",
                                  style: TextStyle(color:Color(0xffffffff) ,),
                                ),
                                background: Container(
                                  color: Color(0xffffffff),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Positioned.fill(
                                          child: _goodsinfo.images.length>0?
                                          SwipperBanner(
                                              banners: _goodsinfo.images,
                                              nheight: _appBarHeight):
                                          CachedNetworkImage(
                                            errorWidget: (context, url, error) =>Container(
                                              height: _appBarHeight,
                                              width: MediaQuery.of(context).size.width,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Image.asset(
                                                      'images/logo_b.png',),
                                                    Text("图片无法显示",style: KfontConstant.defaultSubStyle,)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) =>  Loading(),
                                            imageUrl: _goodsinfo.comPic,
                                            height: _appBarHeight,
                                            width: MediaQuery.of(context).size.width,
                                            fit: BoxFit.fill,
                                          )
                                      ),
                                      Positioned(
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment(0.0, -1.0),
                                              end: Alignment(0.0, -0.4),
                                              colors: <Color>[
                                                Color(0x6B000000),
                                                Color(0x00000000)
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      /*    SwipperBanner(
                                        banners: snapshot.data.images,
                                        nheight: _appBarHeight),
                                    const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment(0.0, -1.0),
                                          end: Alignment(0.0, -0.4),
                                          colors: <Color>[
                                            Color(0x6B000000),
                                            Color(0x00000000)
                                          ],
                                        ),
                                      ),
                                    ),*/
                                    ],
                                  ),
                                )),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate(<Widget>[
                              SizedBox(height: 5,),
                              DetailsExplain(_goodsinfo),
                              DetailsShop(_goodsinfo),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Container(child: Divider(height: 2,),width: ScreenUtil.screenWidthDp/2-100,),
                                  Text("详细信息",style: KfontConstant.defaultSubStyle,),
                                  Container(child: Divider(height: 2,),width: ScreenUtil.screenWidthDp/2-100,),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DetailsWeb(_goodsinfo),
                              ),
                            ]),
                          ),
                        ],
                      ),
                      bottomNavigationBar:buildbottomsheet(context,_goodsinfo)
                  );
                } else {
                  return Center(child: Container(child: Loading()) //Text("加载中"),
                  );
                }
              }
          }
        },
      ),
    )
  ;
  }

  bool _getted=false;
  Future getgoods() async {
    if(_getted)
      return _goodsinfo;
    await HttpUtils.dioappi('Shop/goodsInfo/id/${widget.goodsId}', {},context: context).then((response){
      print(response);
      if (response["status"] == 1) {
        _getted=true;
        _goodsinfo = GoodInfo.fromJson(response);
        final model = globleModel().of(context);
        model.setgoodInfo(_goodsinfo);
      }
    });
    return _goodsinfo;
  }

  @override
  void initState() {
    _getted=false;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
     _getted=false;
    _goodsinfo=null;
  }
  void shaoaddform(GoodInfo goodsinfo) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AddCartItemWidget(
                goodsinfo,
                action: _action,
              ),
            ),
          );
        });
  }

  Widget buildbottomsheet1(context, GoodInfo goodsinfo) {
    return Container(
//      width: ScreenUtil.screenWidthDp,
      height: ScreenUtil().L(70),
      color: Colors.transparent,
      alignment: Alignment.center,
      child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ComFunUtil().buildMyButton(context, '立即购买', () {
                          setState(() {
                            _action = "0";
                          });
                          shaoaddform(goodsinfo);
                        },width: 160,
                          height:55,textstyle: TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 18, color: Colors.white)
                      ),
                    ),
                  ),
                  SizedBox(height: 5,)
                ],
              ),
    );
  }

  Widget buildbottomsheet(context, GoodInfo goodsinfo) {
    return Container(
      width: ScreenUtil.screenWidth,
      height: ScreenUtil().L(60),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
         InkWell(
             onTap: () {
               Application().checklogin(context, () {
                 Navigator.push(
                   context,
                   new MaterialPageRoute(
                       builder: (context) =>  Cart()),
                 );
               });
             },
           child:  Stack(
             children: <Widget>[
               Container(
                 width: ScreenUtil().L(80),
                 alignment: Alignment.center,
                 child: Icon(
                   Icons.shopping_cart,
                   size: 35,
                   color: Colors.red,
                 ),
               ),
               Positioned(
                 top: 0,
                 right: 10,
                 child:
                 ScopedModelDescendant<globleModel>(
                     builder: (context, child, model) {
                       return  Container(
                         padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
                         decoration: BoxDecoration(
                           color: Colors.pink,
                           border: Border.all(width: 2, color: Colors.white),
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Text(
                           '${model.totalCount}',
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: ScreenUtil().setSp(12),),
                         ),
                       );}),
               )

             ],
           ),
         ),
          Expanded(child:InkWell(
            onTap: () async {
              setState(() {
                _action = "1";
              });
              shaoaddform(goodsinfo);
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.green,
              child: Text(
                '加入购物车',
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(16)),
              ),
            ),
          ) )
          ,
          Expanded(child:  InkWell(
            onTap: () async {
              setState(() {
                _action = "0";
              });
              shaoaddform(goodsinfo);
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: Text(
                '立即购买',
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(16)),
              ),
            ),
          )
          ),
        ],
      ),
    );
  }

  bool _favorate=false;
  void isCollectGoods()async{
    Map<String, String> params = {
      "goods_id":widget.goodsId.toString()
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/isCollectGoods', params,
        withToken: true, context: context);

    if (response['status'].toString() == '1') {
      setState(() {
        _favorate=true;
      });

    }
  }

  add_favorite() async{
    Map<String, String> params = {
      "goods_id":widget.goodsId.toString()
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/collect_goods', params,
        withToken: true, context: context);

    if (response['status'].toString() == '1'|| response['status'].toString() =='-3') {
      setState(() {
        _favorate=true;
      });

    }

  }
  cancel_favorite() async{
    Map<String, String> params = {
      "goods_id":widget.goodsId.toString()
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/cancel_collect', params,
        withToken: true, context: context);

    if (response['status'].toString() == '1') {
      setState(() {
        _favorate=false;
      });
    }

  }
}
