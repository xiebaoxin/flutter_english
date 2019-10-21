import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './model/globle_model.dart';
import './views/MyInfoPage.dart';
import './routers/application.dart';
import './utils/screen_util.dart';
import './globleConfig.dart';
import './views/home_Page.dart';
import './views/category.dart';
import './views/sharePage.dart';
import './views/person/myfavera.dart';
import './views/player/mini_player_page.dart';
import 'package:provide/provide.dart';
import './data/base.dart';
import 'main_provide.dart';

class App extends PageProvideNode {

  App() {
    mProviders.provide(Provider<MainProvide>.value(MainProvide.instance));
  }
  @override
  Widget buildContent(BuildContext context) {
    // TODO: implement buildContent
    return _AppContentPage();
  }
}

class _AppContentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<_AppContentPage> with TickerProviderStateMixin<_AppContentPage> {

  MainProvide _provide;
  TabController controller;
  Animation<double> _animationMini;
  AnimationController _miniController;
  final _tranTween = new Tween<double>(begin: 1, end: 0);


  @override
  bool get wantKeepAlive => true;

  String _token='';
  bool _login=true;
  // 默认索引第一个tab
  int _tabIndex = 0;

  // 正常情况的字体样式
  final tabTextStyleNormal = new TextStyle(color: const Color(0xff969696));

  // 选中情况的字体样式
  final tabTextStyleSelect = new TextStyle(color: const Color(0xff63ca6c));

  // 底部菜单栏图标数组
  var tabImages;

  // 页面内容
  var _pages;

  // 菜单文案'商城',
  var tabTitles = ['首页',  '分享', '我的'];

  // 生成image组件
  Image getTabImage(path) {
    return new Image.asset(path, width: 20.0, height: 20.0);
  }

  void initData() {

    double extralHeight = Klength.topBarHeight + //顶部标题栏高度
        Klength.bottomBarHeight + //底部tab栏高度
        ScreenUtil.statusBarHeight + //状态栏高度
        ScreenUtil.bottomBarHeight; //IPhoneX底部状态栏
    if (tabImages == null) {
      tabImages = [
        [
          getTabImage('images/icon/icon_home_n.png'),
          getTabImage('images/icon/icon_home_s.png')
        ],
       /* [
          getTabImage('images/icon/icon_card_n.png'),
          getTabImage('images/icon/icon_card_s.png')
        ],*/
        [
          getTabImage('images/icon/icon_card_n.png'),
          getTabImage('images/icon/icon_card_s.png')
        ],
        [

          getTabImage('images/icon/icon_my_n.png'),
          getTabImage('images/icon/icon_my_s.png')
        ]
      ];
    }

    _pages = [
       HomeIndexPage(),
sharePage(ishome: true,),
//       MyfaveratePage(),
/*    Category(
       rightListViewHeight: ScreenUtil.screenHeight - extralHeight,
    ),*/
    MyInfoPage(),
    ];

  }
    //获取菜单栏字体样式
    TextStyle getTabTextStyle (int curIndex) {
      if (curIndex == _provide.currentIndex) {
        return tabTextStyleSelect;
      } else {
        return tabTextStyleNormal;
      }
    }

    // 获取图标
    Image getTabIcon (int curIndex) {
      if (curIndex == _provide.currentIndex) {
        return tabImages[curIndex][1];
      }
      return tabImages[curIndex][0];
    }

    // 获取标题文本
    Text getTabTitle (int curIndex) {
      return new Text(
        tabTitles[curIndex],
        style: getTabTextStyle(curIndex),
      );
    }

    // 获取BottomNavigationBarItem
    List<BottomNavigationBarItem> getBottomNavigationBarItem () {
      List<BottomNavigationBarItem> list = new List();
      for (int i = 0; i <tabTitles.length; i++) {
        list.add(new BottomNavigationBarItem(
            icon: getTabIcon(i), title: getTabTitle(i)));
      }
      return list;
    }


    @override
    Widget build (BuildContext context) {

      ScreenUtil.instance = ScreenUtil(width: Klength.designWidth,height: Klength.designHeight)..init(context);
      initData();
      return WillPopScope(
        onWillPop: (){_doubleExit(context);},//(){return Future.value(_onWillPop());},
        child: Scaffold(
//          backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
          body: new Stack(
            alignment: AlignmentDirectional.bottomEnd,
            overflow: Overflow.visible,
            children: <Widget>[
              _initTabBarView(),
              _initMiniPlayer()
            ],
          ),
          bottomNavigationBar:_initBottomNavigationBar(),
        )
      );

    }
  ontap(int index) {
    _provide.currentIndex = index;
    controller.animateTo(index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease);
  }

  Provide<MainProvide> _initTabBarView() {
    return Provide<MainProvide>(
        builder: (BuildContext context, Widget child, MainProvide value) {
          return IndexedStack(
            index: _provide.currentIndex,
            children: _pages,
          );
        });
  }

  Provide<MainProvide> _initMiniPlayer() {
    return Provide<MainProvide>(
        builder: (BuildContext context, Widget child, MainProvide value) {
          return Visibility(
            visible: _provide.showMini,
            child: new FadeTransition(
              opacity: _tranTween.animate(_animationMini),
              child: new Container(
                width: 80,
                height: 110,
                child: MiniPlayerPage(),
              ),
            ),
          );
        });
  }



  Provide<MainProvide> _initBottomNavigationBar() {
    return Provide<MainProvide>(
        builder: (BuildContext context, Widget child, MainProvide value) {
          return Theme(
              data: new ThemeData(
                  canvasColor: Colors.white, // BottomNavigationBar背景色
                  textTheme: Theme.of(context).textTheme.copyWith(caption: TextStyle(color: Colors.grey))
              ),
              child: BottomNavigationBar(
                  fixedColor: Colors.black,
                  currentIndex: _provide.currentIndex,
                  onTap: ontap,
                  type: BottomNavigationBarType.fixed,
                  items: getBottomNavigationBarItem())
          );
        });
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('您确定要退出吗?'),
        content: new Text('确定将退出app'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('取消'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('确定'),
          ),
        ],
      ),
    ) ?? false;
  }

  int _lastClickTime = 0;
  Future<bool> _doubleExit(BuildContext context) async{
    int nowTime = new DateTime.now().microsecondsSinceEpoch;
    if (_lastClickTime != 0 && nowTime - _lastClickTime > 1500) {
       await _onWillPop().then((rv){
         rv ? _exitApp(context): new  Future.value(false);
      });
      return new Future.value(true);
    } else {
      _lastClickTime = new DateTime.now().microsecondsSinceEpoch;
      new Future.delayed(const Duration(milliseconds: 1500), () {
        _lastClickTime = 0;
      });
       await _onWillPop().then((rv){
         rv ? _exitApp(context): new Future.value(false);
      });
      return new Future.value(true);
    }
  }


  static Future<void> _exitApp(BuildContext context) async {
    final model = globleModel().of(context);
     await model.setlogout();
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
/*
  getInitConfig() async{
  final model =globleModel().of(context);
  _token= model.token;
  if(_token!='')
    _login=true;
}*/

  @override
  void initState() {
    super.initState();
    _provide = MainProvide.instance;

    controller = new TabController(length: 3, vsync: this);

    _miniController = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationMini = new CurvedAnimation(parent: _miniController, curve: Curves.linear);

  }

  @override
  void dispose() {
    super.dispose();
  }


}

