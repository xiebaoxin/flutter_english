import 'package:flutter/material.dart';
import 'movie/movielist.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key key, this.content}) : super(key: key);
  final String content;

  _MyHomeState createState() => new _MyHomeState();
}

// 如果页面内只有一个动画切换效果，则实现 SingleTickerProviderStateMixin 特征即可，
// 如果存在多个动画效果，则必须实现 TickerProviderStateMixin
// 当使用的是 DefaultTabController 的时候，不需要指定任何 Minxin
class _MyHomeState extends State<MyHome> {
  // 1. 使用 DefaultTabController 之后，这里不再需要定义 _controller
  // TabController _controller;
  List<Widget> _pagelist = [
    new MovieList(mt: 'in_theaters'),
    new MovieList(mt: 'coming_soon'),
    new MovieList(mt: 'top250')
  ];
  List<Widget> _tabs = [
    Tab(
      text: '正在热映',
      icon: Icon(Icons.movie_filter),
    ),
    Tab(
      text: '即将上映',
      icon: Icon(Icons.movie_creation),
    ),
    Tab(
      text: 'Top250',
      icon: Icon(Icons.local_movies),
    ),
  ];

  // 2. 使用 DefaultTabController 之后，这里不再需要初始化 _controller 属性
  /* @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: _tabs.length);
  } */

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              '电影列表',
              style: TextStyle(fontSize: 14),
            ),
            centerTitle: true,
            // leading: Icon(Icons.menu),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 20),
                child: Icon(Icons.search),
              )
            ],
          ),
          body: TabBarView(
            // 3. 使用 DefaultTabController 之后，这里不再需要 controller 属性
            // controller: _controller,
            children: _pagelist,
          ),
          drawer: Drawer(
            child: Container(
              decoration: BoxDecoration(color: Colors.black87),
              child: ListView(
                  // 消除顶部的灰色条区域
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName: Text('刘龙宾'),
                      accountEmail: Text('liulongbin1314@outlook.com'),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://images.gitee.com/uploads/91/465191_vsdeveloper.png?1530762316'),
                      ),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  'http://www.liulongbin.top:3005/images/bg1.jpg'))),
                    ),
                    ListTile(
                      title:
                          Text('用户反馈', style: TextStyle(color: Colors.white)),
                      trailing: Icon(Icons.feedback, color: Colors.white),
                    ),
                    ListTile(
                      title:
                          Text('系统设置', style: TextStyle(color: Colors.white)),
                      trailing: Icon(Icons.settings, color: Colors.white),
                    ),
                    ListTile(
                      title:
                          Text('我要发布', style: TextStyle(color: Colors.white)),
                      trailing: Icon(Icons.send, color: Colors.white),
                    ),
                    Divider(color: Colors.white30),
                    ListTile(
                      title: Text('注销', style: TextStyle(color: Colors.white)),
                      trailing: Icon(Icons.exit_to_app, color: Colors.white),
                    )
                  ]),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border(top: BorderSide(color: Colors.grey, width: 1))),
            height: 50,
            child: TabBar(
              // 4. 使用 DefaultTabController 之后，这里不再需要 controller 属性
              // controller: _controller,
              tabs: _tabs,
              indicatorColor: Colors.red,
              labelStyle: TextStyle(height: 0, fontSize: 10),
            ),
          )),
    );
  }
}
