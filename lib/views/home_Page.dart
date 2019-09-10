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
import 'recommed.dart';
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

  List<Map<String,dynamic>> _tabs = [{
    'text': "wu大幅度",
    'cat_id': 0,
    'lists': [],
  }];

Widget getIndexCatList(){
  return   Container(
    width: MediaQuery.of(context).size.width,
    child:TabBar(
        indicatorColor: KColorConstant.themeColor,
        indicatorSize: TabBarIndicatorSize.label,
        isScrollable: true,
        labelColor: KColorConstant.themeColor,
        tabs: _tabs
            .map((i) => Container(
          child:  Tab(
            text:i['text'],
            icon: Icon(Icons.movie_filter),
          ),
        ))
            .toList()),
  );
}

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<globleModel>(builder: (context, child, model) {
      _userinfo = model.userinfo;
      return
        _tabs.isEmpty?
        getIndexCatList():
        DefaultTabController(
          length: _tabs.length,
          initialIndex: 0,
          child:
          Scaffold(
            backgroundColor:  Colors.white,
            body:ListView(
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
//                  mainTopitem(),
              SizedBox(height: 10,),

              getIndexCatList(),

              _tabs.isEmpty?SizedBox(height: 1,): Container(
                height: 120,
                color: Color.fromRGBO(132, 95, 63, 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBarView(
                    children: _buildTabItemView(),
                  ),
                ),
              ),



              divdertext('推荐'),
              _recommondList.length == 0
                  ? Text("没有热门推荐")
                  : RecommendFloor(
                _recommondList,
                cnum: 3,
              ),
              divdertext('热门'),
              RecommendFloor(_goodsList, cnum: 2),
            ],
          ),)

      )
     ;
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

  List<Map<String, dynamic>> _recommondList = List();

  Future recommondList() async {
    _recommondList = await DataUtils.getIndexRecommendGoods(context);
    setState(() {;});
  }

  int _page1 = 1;
  List<Map<String, dynamic>> _goodsList = List();
  void getGoodsList() async {
    setState(() {
      _offState = false;
    });
    _goodsList=await DataUtils.getIndexGoodsList(_page1, context);
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
    return   Center(
        child: new GridView.count(
          crossAxisCount: 4,
          padding: const EdgeInsets.all(10.0),
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          children: ( item['lists'] as List).map((it) {
            return Container(
              height: 50,
                child:InkWell(
                  onTap: (){
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (BuildContext context) {
                          return SearchResultListPage('',catid: it['ucid'],catname: it['name'],);
                        }));
                  },
                  child:  Text("${it['name']}"),));
            //                      return Text(iti.item);
          }).toList(),
        ),
      );

      return   Wrap(
          spacing: 8,
          runSpacing: 8,
          children:( item['lists'] as List).map((iti) {
            return Text("${iti['ucid']}--${iti['name']}");
            //                      return Text(iti.item);
          }).toList());
    }).toList();;
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
    List<Map<String,dynamic>> CategoryItems =[];
    await DataUtils.getSubsCategory(context,cat_id: 586).then((response){
      var cateliest = response["items"];

      cateliest.forEach((ele) {
        if (ele.isNotEmpty) {
          CategoryItems.add(ele);
        }
      });
      setState(() {
      _tabs=  CategoryItems.map((item){
          return {
            'text': item['name'],
            'cat_id': item['ucid'],
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

}
