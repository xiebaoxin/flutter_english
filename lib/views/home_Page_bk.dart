import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../utils/screen_util.dart';
import '../utils/DialogUtils.dart';
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
  ShapeBorder _shape = GlobalConfig.cardBorderRadius;
  ScrollController _strollCtrl = ScrollController();

  Userinfo _userinfo;

  var rightArrowIcon = Icon(Icons.chevron_right, color: Colors.black26);
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  bool _isLoading = false; //是否正在请求新数据
  bool showMore = false; //是否显示底部加载中提示
  bool _offState = false; //是否显示进入页面时的圆形进度条

  @override
  Widget build(BuildContext context) {
    Widget mainscreen = Scaffold(
/*        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Image.asset(
              "images/logo.png",
              height: 25,
              width: 25,
              fit: BoxFit.fill,
            ),
            iconSize: 26,
            onPressed: () {
              ;
            },
          ),
          title: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (BuildContext context) {
                  return SearchPage();
                }));
              },
              child: Container(
                height: 35,
                padding: EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(238, 238, 238, 0.5),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.search,
                            color: Color(0xFFFFFFFF),
                            size: 24,
                          ),
                          Text(
                            "搜索",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              color: Color(0xFF979797),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          actions: <Widget>[
            IconButton(
              icon: Image.asset(
                "images/czzy.png",
                height: 15,
                width: 15,
                fit: BoxFit.fill,
              ),
              iconSize: 18,
              onPressed: () {},
            )
          ],
        ),*/
        body: Stack(
          children: <Widget>[
            RefreshIndicator(
                onRefresh: () async {
                  _onRefresh();
                },
                child: ListView(
                  controller: _strollCtrl,
                  children: [
                    FutureBuilder(
                      future: _futureBannerBuilderFuture,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        //snapshot就是_calculation在时间轴上执行过程的状态快照
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text(
                                'Press button to start'); //如果_calculation未执行则提示：请点击开始
                          case ConnectionState.waiting:
                            return Image.asset(
                              "images/bg_img.png",
                              height: 180,
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
                                    height: 180,
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
                                      banners.add(ele['ad_code'].toString());
                                      linkers.add(ele['ad_link'].toString());
                                    }
                                  });
                                }

                                return Container(
                                    height: 180,
                                    child: Column(
                                      children: <Widget>[
                                        banners.length <= 0
                                            ? Image.asset(
                                                "images/bg_img.png",
                                                height: 180,
                                                width: ScreenUtil.screenWidth,
                                                fit: BoxFit.fill,
                                              )
                                            : SwipperBanner(
                                                banners: banners,
                                                nheight: 180,
                                                urllinks: linkers,
                                              )
                                      ],
                                    ));
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
                    stackmsg(),
                    mainTopitem(),
                    divdertext('推荐'),
                    _recommondList.length == 0
                        ? Text("没有热门推荐")
                        : IndexHotListFloor(
                            _recommondList,
                            cnum: 3,
                          ),
                    divdertext('热门'),
                    IndexHotListFloor(_goodsList, cnum: 2),
                  ],
                )),
            Offstage(
              offstage: _offState,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ));
    return ScopedModelDescendant<globleModel>(builder: (context, child, model) {
      _userinfo = model.userinfo;
      return mainscreen;
    });
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
        Text(title, style: KfontConstant.fLoorTitleStyle),
        Container(
          child: Divider(
            height: 2,
          ),
          width: ScreenUtil.screenWidthDp / 2 - 100,
        ),
      ],
    );
  }

  /**
   * 模拟下拉刷新
   */
  Future<void> _onRefresh() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
      _page1 = 1;
    });

    print('下拉刷新开始,page = $_page1');
    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
        _goodsList = List();
        getGoodsList();
        print('下拉刷新结束,page = $_page1');
      });
    });
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
              FutureBuilder(
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
              ),
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

  Widget mainTopitem() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              // This ensures that the Card's children are clipped correctly.
              clipBehavior: Clip.antiAlias,
              shape: _shape, //,
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(
                              builder: (BuildContext context) {
                            return SearchResultListPage(
                              '',
                              catid: 587,
                              catname: "幼儿",
                            );
                          }));
                        },
                        child: buildIconitem('images/czzy.png', "幼儿")),
                    InkWell(
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(
                              builder: (BuildContext context) {
                            return SearchResultListPage(
                              '',
                              catid: 588,
                              catname: "初级",
                            );
                          }));
                        },
                        child: buildIconitem('images/about.png', "初级")),
                    InkWell(
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(
                              builder: (BuildContext context) {
                            return SearchResultListPage(
                              '',
                              catid: 589,
                              catname: "中级",
                            );
                          }));
                        },
                        child: buildIconitem('images/mustread.png', "中级")),
                    InkWell(
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(
                              builder: (BuildContext context) {
                            return SearchResultListPage(
                              '',
                              catid: 590,
                              catname: "高级",
                            );
                          }));
                        },
                        child: buildIconitem('images/reward.png', "高级")), //原分享
                  ],
                ),
              ))),
    );
  }

  Widget buildIconitem(String asimg, String title) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 45,
            width: 45,
            decoration: new BoxDecoration(
              color: Colors.white,
              image: new DecorationImage(
                image: AssetImage(asimg),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Text(
          title,
          style: KfontConstant.defaultStyle,
        )
      ],
    );
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

  List _listbanner = [];
  bool _getbannerd = false;
  Future _getbannerdata() async {
    if (_getbannerd) return _listbanner;
    Map<String, String> params = {'objfun': 'getAppHomeAdv'};
    Map<String, dynamic> response =
        await HttpUtils.dioappi('Shop/getIndexData', params, context: context);
    _listbanner = response["items"];

    _getbannerd = true;
    return _listbanner;
  }

  @override
  void initState() {
    // TODO: implement initState
    getGoodsList();
    recommondList();
    _strollCtrl.addListener(() {
      if (_strollCtrl.position.pixels == _strollCtrl.position.maxScrollExtent) {
        if (_strollCtrl.position.pixels ==
            _strollCtrl.position.maxScrollExtent) {
          print('滑动到了最底部${_strollCtrl.position.pixels}');
          setState(() {
            showMore = true;
          });
          getGoodsList();
        }
      }
    });

    super.initState();
    _futureBannerBuilderFuture = _getbannerdata();
    _futureMessageBuilderFuture = _getNotice();
  }

  List<Map<String, dynamic>> _recommondList = List();

  Future recommondList() async {
    _recommondList = List();
    await HttpUtils.dioappi("Shop/ajaxGoodsList/", {}, context: context)
        .then((response) {
      if (_recommondList.isEmpty) {
        if (response['list'].isNotEmpty) {
          int i = 0;
          setState(() {
            response['list'].forEach((ele) {
              if (i < 3 && ele.isNotEmpty) {
                Map<String, dynamic> itemmap = ele;
                _recommondList.add(itemmap);
                i++;
              }
            });
          });
        }
      }
    });
  }

  int _page1 = 1;
  List<Map<String, dynamic>> _goodsList = List();
  // /id/581
  void getGoodsList() async {
    setState(() {
      _offState = false;
    });
    await HttpUtils.dioappi("Shop/ajaxGoodsList/p/${_page1.toString()}", {},
            context: context)
        .then((response) {
      print(response['list']);
      if (response['list'].isNotEmpty) {
        setState(() {
          _offState = true;
          _page1 += 1;
          response['list'].forEach((ele) {
            if (ele.isNotEmpty) {
              Map<String, dynamic> itemmap = ele;
              _goodsList.add(itemmap);
            }
          });
        });
      }
    });
  }
}
