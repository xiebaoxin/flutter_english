import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../globleConfig.dart';

class MessagePage extends StatefulWidget {
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> with SingleTickerProviderStateMixin {
TabController _tabController;

   double _width = GlobalConfig.cardWidth;
  ShapeBorder _shape =  GlobalConfig.cardBorderRadius;

  void _initdata() {;}

  @override
  void initState() {
    super.initState();
    _initdata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const List<msgChoice> choices = const <msgChoice>[
      const msgChoice(
        title: '消息',
        categoryId: 0,
      ),
      const msgChoice(
        title: '通知',
        categoryId: 1,
      ),
      const msgChoice(
        title: '活动',
        categoryId: 2,
      )
    ];


    return DefaultTabController(
      length: choices.length,
      initialIndex: 0, //初始索引
      child: Scaffold(
        appBar: AppBar(
          title: Text('消息通知'),
          bottom: TabBar(
//              isScrollable: true, //这个属性是导航栏是否支持滚动，false则会挤在一起了
              unselectedLabelColor: Colors.white, //未选标签标签的颜色(这里定义为灰色)
              labelColor: Colors.grey, //选中的颜色（黑色）
              indicatorColor: Colors.grey, //指示器颜色
              indicatorWeight: 2.0, //指示器厚度
              tabs: [
            Tab(
              icon: Icon(Icons.message),
              text: "消息",
            ),
            Tab(
              icon: Icon(Icons.info),
              text: "通知",
            ),
            Tab(
              icon: Icon(Icons.local_play),
              text: '活动',
            ),
          ]),
        ),
        body: TabBarView(
          children: choices.map((msgChoice choice) {
                return   SizedBox(
                    height: 70,
                    width: _width,
                    child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: _shape,
                        child: ListTile(
                            title: Text(choice.title),
                            subtitle: new Text("抗震压包装，安全到家---"+choice.title),
                            trailing: Icon(Icons.done,color: Colors.red,)
//                            Image.asset('images/express.png',width: 40.0, height: 40.0))
                    )));
            //一个属于展示内容的listview
          }).toList(),
        ),
      ),
    );

  }

}

class msgChoice {
  const msgChoice({this.title, this.categoryId});

  final String title; //这个参数是分类名称
  final int categoryId; //这个适用于网络请求的参数，获取不同分类列表
}
