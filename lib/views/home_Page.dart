import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../utils/screen_util.dart';
import '../components/fiexdAppbar.dart';
import '../utils/comUtil.dart';
import '../utils/HttpUtils.dart';
import '../constants/index.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';
import '../utils/dataUtils.dart';
import '../routers/application.dart';
import '../model/userinfo.dart';
import '../components/banner.dart';
import '../data/home.dart';
import '../model/index_model.dart';
import '../views/search/search.dart';
import 'message_page.dart';
import 'goodsList.dart';
import 'recommedFloor.dart';
import 'indexHotList.dart';
import 'noticeMessgeList.dart';
import '../views/search/searchlist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/loading_gif.dart';
import 'video_detail_page.dart';

class HomeIndexPage extends StatefulWidget {
  @override
  HomeIndexPageState createState() => new HomeIndexPageState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class HomeIndexPageState extends State<HomeIndexPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  var _futureBannerBuilderFuture;
  var _futureMessageBuilderFuture;
  ScrollController _strollCtrl = ScrollController();

  Userinfo _userinfo;
  var rightArrowIcon = Icon(Icons.chevron_right, color: Colors.black26);

  bool _islogin = false;
  bool showMore = false; //是否显示底部加载中提示
  bool _offState = false; //是否显示进入页面时的圆形进度条

  List<Map<String, dynamic>> _tabs = [
    {
      'text': "",
      'cat_id': 0,
      'lists': [],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<globleModel>(builder: (context, child, model) {
      _userinfo = model.userinfo;
       _islogin = model.loginStatus;
      return Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          appBar: FiexdAppbar(
            contentHeight: 40.0,
            contentChild:  Padding(
              padding: EdgeInsets.only(left:15.0,right: 0,top:2.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 9,
                      child:  GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (BuildContext context) {
                                  return SearchPage();
                                }));

//                      SearchTopBarActionWidget(
//                        onActionTap: () => goSearchList(context,controller.text),
//                      )
                          },
                          child:  Container(
                            height: 34,

                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
//                            color: Color.fromRGBO(240, 240, 240, 0.5),
                              borderRadius: BorderRadius.circular(17.0),
                              border: Border.all(
                                  width: 0.5, color:Color(0xFFe7281d)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5,2.0,5,2),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.search,
                                        color: Color(0xFF979797),
                                        size: 22,
                                      ),
                                      Text(
                                        "搜一搜",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF979797),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                 /*   Container(
                                height: 34,
                                width: 60,
//                padding: EdgeInsets.all(2.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color:Color(0xaFe7281d),
                                    borderRadius: BorderRadius.circular(17.0)),
                                child:Text("搜索",style: TextStyle(color: Color(0xFFFFFFFF)),))*/
                              ],
                            ),
                          )))
                 ,
                  IconButton(
                      icon: !_islogin ?Icon(Icons.perm_identity,color: Color(0xFFaaaaaa),):Icon(Icons.person,color: Colors.redAccent,),
                      onPressed: !_islogin
                          ? () {
                        Application().checklogin(context, () {
                          ;
                        });
                      }
                          : null),
                ],
              ),
            ),
          ),

          body: _tabs.isEmpty
              ? getIndexCatList()
              : DefaultTabController(
                  length: _tabs.length,
                  initialIndex: 0,
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: ListView(
                      controller: _strollCtrl,
                      children: [
                       FutureBuilder(
                          future: _futureBannerBuilderFuture,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            //snapshot就是_calculation在时间轴上执行过程的状态快照
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return new Text(
                                    '需重新加载'); //如果_calculation未执行则提示：请点击开始
                              case ConnectionState.waiting:
                                return Image.asset(
                                  "images/bg_img.png",
                                  height: 160,
                                  width: ScreenUtil.screenWidth,
                                  fit: BoxFit.fill,
                                );
//                  return new Text('Awaiting result...');  //如果_calculation正在执行则提示：加载中
                              default: //如果_calculation执行完毕
                                if (snapshot.hasError) //若_calculation执行出现异常
                                  return Column(
                                    children: <Widget>[
                                      Text('Error: ${snapshot.error}'),
                                      Image.asset(
                                        "images/bg_img.png",
                                        height: 160,
                                        width: ScreenUtil.screenWidth,
                                        fit: BoxFit.fill,
                                      )
                                    ],
                                  );
                                else {
                                  if (snapshot.hasData) {
                                    var ddre = snapshot.data;
                                    List<String> banners = [];
                                    List<String> linkers = [];
                                    if (ddre != null) {
                                      ddre.forEach((ele) {
                                        if (ele.isNotEmpty &&
                                            ele['ad_code'].isNotEmpty &&
                                            ele['ad_link'].isNotEmpty) {
                                          banners
                                              .add(ele['ad_code'].toString());
                                          linkers
                                              .add(ele['ad_link'].toString());
                                        }
                                      });
                                    }

                                    return Container(
                                        height: 160,
//                                        padding: EdgeInsets.only(left: 8,right: 8),
                                      decoration: new BoxDecoration(
                                     /*   image: new DecorationImage(
                                          image: AssetImage('images/排行榜.png'),
                                          fit: BoxFit.fill,
//这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                                          centerSlice: new Rect.fromLTRB(
                                              270.0, 180.0, 1360.0, 730.0),
                                        ),
                                */
                                        border:null,// Border.all(width: 2, color: Colors.white),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                        child:
                                              banners.length <= 0
                                                  ? Image.asset(
                                                "images/bg_img.png",
                                                height: 160,
                                                width:
                                                ScreenUtil.screenWidth,
                                                fit: BoxFit.fill,
                                              )
                                                  : SwipperBanner(
                                                banners: banners,
                                                nheight: 160,
                                                urllinks: linkers,
                                              )
                                        );
                                  } else {
                                    return Center(
                                      child: Text("加载中"),
                                    );
                                  }
                                } //若_calculation执行正常完成
//                    return new Text('Result: ${snapshot.data}');
                            }
                          },
                        ),
                  /*      stackmsg(),
//                  mainTopitem(),
                        SizedBox(
                          height: 10,
                        ),*/

                        getIndexCatList(),

                        _tabs.isEmpty
                            ? SizedBox(
                                height: 1,
                              )
                            : Container(
                          height: 80,
                                color: Colors.white70,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(3.0, 5, 3, 3.0),
                                  child: TabBarView(
                                        children: _buildTabItemView(),
                                      ),

                                ),
                              ),

                        divdertext('推荐'),
                        _recommondList.length == 0
                            ? Text("没有热门推荐")
                            : RecommendFloor(_recommondList),
                       Container(
                         height: 8,
                         color: Color(0xFFeeeeee),
                       ),

                        divdertext('热门'),
                        IndexHotListFloor(_goodsList, cnum: 2),
                      ],
                    ),
                  )));
    });
  }

  Widget getIndexCatList() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: TabBar(
            indicatorColor: KColorConstant.themeColor,
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            labelColor: KColorConstant.themeColor,
            indicatorWeight: 2,
            labelPadding: EdgeInsets.only(left: 15, right: 8),
            unselectedLabelColor: Colors.black54,
            labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
            tabs: _tabs
                .map((i) => Container(
                      child: Tab(
                        text: i['text'],
                      ),
                    ))
                .toList()),
      ),
    );
  }

  Widget divdertext(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: Divider(
            height: 2,
          ),
          width: ScreenUtil.screenWidthDp / 2 - 100,
        ),
        Text(title, style:TextStyle(
          fontSize:12,
          color: Color(0xaf666666),
        )),
        Container(
          child: Divider(
            height: 2,
          ),
          width: ScreenUtil.screenWidthDp / 2 - 100,
        ),
      ],
    );
  }

  Widget stackmsg() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        height: 38,
        width: 280,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: GlobalConfig.mainColor, width: 1.0),
            borderRadius: BorderRadius.circular(5.0)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: Text(
                  " 通知:",
                  style: TextStyle(color: GlobalConfig.mainColor),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MessagePage(),
                    ),
                  );
                },
              ),
             /* FutureBuilder(
                future: _futureMessageBuilderFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //snapshot就是_calculation在时间轴上执行过程的状态快照
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text('正在读取通知……'); //如果_calculation正在执行则提示：加载中
                    default: //如果_calculation执行完毕
                      if (snapshot.hasError) //若_calculation执行出现异常
                        return new Text('通知读取出错了..');
                      else {
                        if (snapshot.hasData) {
                          _notice = snapshot.data;
                          return InkWell(
                            child: Container(
                                width: 150,
                                height: 38,
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 0, 0, 0),
                                      child: Container(
                                        width: 130,
                                        height: 30,
                                        child: MarqueeWidget(
                                          text: _notice.isNotEmpty
                                              ? _notice[0]['message_title']
                                              : "暂无",
                                          textStyle: new TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45),
                                          scrollAxis: Axis.horizontal,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            onTap: () {
                              if (_notice.isNotEmpty) {
                                ComFunUtil()
                                    .alertMsg(context, _notice[0]['message']);
                              }
                            },
                          );
                        } else {
                          return Text("空空如也");
                        }
                      } //若_calculation执行正常完成
//                    return new Text('Result: ${snapshot.data}');
                  }
                },
              ),*/
              InkWell(
                child: Text(
                  "更多 ",
                  style: TextStyle(color: GlobalConfig.mainColor),
                ), //Icon(Icons.close, size: 16, color: _iconcolor),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => noticeMessgeList("公告", _notice),
                    ),
                  );
                  /*setState(() {
                        _showMsg = false;
                      });*/
                },
              ),
            ],
          ),
        ));
  }

  List<Map<String, dynamic>> _recommondList = List();

  Future recommondList() async {
    _recommondList = await DataUtils.getRecommendGoods(context);
    setState(() {
      ;
    });
  }

  int _page1 = 1;
  List<Map<String, dynamic>> _goodsList = List();
  void getGoodsList() async {
    setState(() {
      _offState = false;
    });
    _goodsList = await DataUtils.getIndexGoodsList(_page1, _goodsList, context,
        recommend: 0); //catid:586,
    setState(() {
      _offState = true;
      _page1 += 1;
    });
  }

  List<Map<String, dynamic>> _notice = List();
  Future<List<Map<String, dynamic>>> _getNotice() async {
    List<Map<String, dynamic>> notice = [];
    await HttpUtils.dioappi("Shop/message_notice", {}, context: context)
        .then((response) {
      if (response['result'].isNotEmpty) {
        response['result'].forEach((ele) {
          if (ele.isNotEmpty) {
            notice.add(ele);
          }
        });
      }
    });
    return notice;
  }

  List<Widget> _buildTabItemView() {
    return _tabs.map((item) {
      return Center(
        child: ListView(
          itemExtent:66,
          scrollDirection: Axis.horizontal,
//          spacing: 5,
//          runSpacing: 3,
          children: (item['lists'] as List).map((it) {
         /*   return InkWell(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (BuildContext context) {
                    return SearchResultListPage(
                      '',
                      catid: it['ucid'],
                      catname: it['name'],
                    );
                  }));
                },
                child: Chip(
                  avatar: CircleAvatar(
                      backgroundColor: KColorConstant.themeColor,
                      child: Text(
                        it['name'].toString().substring(0, 1),
                        style: TextStyle(fontSize: 10),
                      )
                      */
         /*             CachedNetworkImage(
                errorWidget: (context, url, error) => Container(
                  height: 30,
                  width: 30,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'images/logo_b.png',
                        ),
                        Text(
                          "图片无法显示",
                          style: TextStyle(color: Colors.black26),
                        )
                      ],
                    ),
                  ),
                ),
                placeholder: (context, url) => Loading(),
                imageUrl: it['icon'],
                height: 40,
                width: 40,
                fit: BoxFit.fill,
              )*/
         /*
                      ),
                  label: Text(
                    it['name'],
                    style: TextStyle(fontSize: 12),
                  ),
                ));*/
               return  Container(
                height: 70,
                child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (BuildContext context) {
                        return SearchResultListPage(
                          '',
                          catid: it['ucid'],
                          catname: it['name'],
                        );
                      }));
                    },
                    child: Container(
                        margin: EdgeInsets.all(2),
                        child: Column(
                          children: <Widget>[
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
//                            borderRadius: BorderRadius.circular(3.0),
                            gradient: LinearGradient(
                                colors: [Colors.red, Color(0xFFff64a4)], begin: Alignment.center, end: Alignment.topRight),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            it['name'].toString().substring(0, 1),
                            style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Color(0xFFFFFFFF)),
                          )
                     /*     CircleAvatar(
                          backgroundColor: KColorConstant.themeColor,
                            child: Text(
                              it['name'].toString().substring(0, 1),
                              style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Color(0xFFFFFFFF)),
                            )),*/
                        ),
                            Text(
                              it['name'],
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        ))
//
                    ));
          }).toList(),
        ),
      );
    }).toList();
    ;
  }

  List _listbanner = [];
  bool _getbannerd = false;
  Future _getbannerdata() async {
    if (_getbannerd) return _listbanner;
    _listbanner = await DataUtils.getIndexTopSwipperBanners(context);
    _getbannerd = true;
    return _listbanner;
  }

  Future _initCatsDatelist() async {
    List<Map<String, dynamic>> CategoryItems = [];
    await DataUtils.getSubsCategory(context, cat_id: 586).then((response) {
      var cateliest = response["items"];

      cateliest.forEach((ele) {
        if (ele.isNotEmpty) {
          CategoryItems.add(ele);
        }
      });
      setState(() {
        _tabs = CategoryItems.map((item) {
          return {
            'text': item['name'],
            'cat_id': item['ucid'],
            'icon': item['icon'],
            'lists': item['list'] as List,
          };
        }).toList();
      });
    });
  }

  @override
  void initState() {
    _initCatsDatelist();
    // TODO: implement initState
    getGoodsList();
    recommondList();
    _strollCtrl.addListener(() {
      if (_strollCtrl.position.pixels == _strollCtrl.position.maxScrollExtent) {
        print('滑动到了最底部${_strollCtrl.position.pixels}');
        setState(() {
          showMore = true;
        });
        getGoodsList();
      }
    });

    super.initState();
    _futureBannerBuilderFuture = _getbannerdata();
//    _futureMessageBuilderFuture = _getNotice();
  }
}
