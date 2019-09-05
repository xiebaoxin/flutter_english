import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../components/loading_gif.dart';
import '../../model/globle_model.dart';
import '../../globleConfig.dart';
import '../../routers/application.dart';
import '../../utils/HttpUtils.dart';
import '../../utils/screen_util.dart';
import '../../utils/comUtil.dart';

class Childrens extends StatefulWidget {
  @override
  ChildrensState createState() => new ChildrensState();
}

class Choice {
  const Choice({this.title, this.position});
  final String title;
  final int position;
}

class ChildrensState extends State<Childrens> {
  TabController _tabController;
  int _count = 0, _count1 = 0, _count2 = 0;
  List<Choice> _tabs = [
    Choice(title: '所有成员', position: 0),
    Choice(title: '直推成员', position: 1),
    Choice(title: 'v1会员', position: 2)
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> tabList = [
      buildIconitem('images/所有成员.png', "所有成员($_count)"),
      buildIconitem('images/直推成员.png', "直推成员($_count1)"),
      buildIconitem('images/v1会员.png', "v1会员($_count2)")
    ];
    return DefaultTabController(
        length: _tabs.length,
//      initialIndex: 0, //初始索引
        child: Scaffold(
          appBar: AppBar(
              title: Text('邀请明细'),
              bottom: PreferredSize(
                  child: new Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TabBar(
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: Colors.green,
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.black45,
                        tabs: tabList.map((Widget choice) {
                          return choice;
                        }).toList(),
                        onTap: (index) {
                          setState(() {
                            if (index == 1) {
                              _userList1 = [];
                            } else if (index == 2) {
                              _userList2 = [];
                            } else
                              _userList = [];

                            _loadData(index);
                          });
                        },
                      ),
                    ),
                  ),
                  preferredSize: new Size(double.infinity, 70.0))),
          body: TabBarView(
            children: <Widget>[
              ChildrenList(_userList, getNextPage: () => _loadData(0)),
              ChildrenList(_userList1, getNextPage: () => _loadData(1)),
              ChildrenList(_userList2, getNextPage: () => _loadData(2))
            ],
          ),
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData(0);
  }

  List<Map<String, dynamic>> _userList = List();
  List<Map<String, dynamic>> _userList1 = List();
  List<Map<String, dynamic>> _userList2 = List();

  _loadData(int index) async {
    String url = 'User/myallchildren';
    if (index == 1) {
      url = 'User/mychildren';
    } else if (index == 2) {
      url = 'User/mylevelchildren/lv/1';
    }
    await HttpUtils.dioappi(url, {}, context: context, withToken: true)
        .then((response) async {
      print(response);
      setState(() {
        if (index == 0) {
          _count = response['count'] ?? 0;
          _count1 = response['count1'] ?? 0;
          _count2 = response['count2'] ?? 0;
        }
        if (response['result']!=null && response['result'].isNotEmpty) {
          response['result'].forEach((ele) {
            if (ele.isNotEmpty) {
              Map<String, dynamic> itemmap = ele;

              if (index == 1) {
                _userList1.add(itemmap);
              } else if (index == 2) {
                _userList2.add(itemmap);
              }
              _userList.add(itemmap);
            }
          });
        }
      });
      print(_userList);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget buildmListRow() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.center,
        width: 250,
        child: Card(
            // This ensures that the Card's children are clipped correctly.
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white12),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
                bottomLeft: Radius.circular(18.0),
                bottomRight: Radius.circular(18.0),
              ),
            ), //,
            elevation: 5.0,
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    alignment: Alignment.center,
                    width: 220,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
//                        buildIconitem('images/订单.png', "订单"),
//                        buildIconitem('images/余额2.png', "余额"),
//                        buildIconitem('images/补贴.png', "补贴"),
                      ],
                    )))),
      ),
    );
  }

  Widget buildIconitem(String asimg, String title) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.asset( asimg,
                  width: asimg=='images/所有成员.png'?30:25.0,
                  height: asimg=='images/所有成员.png'?30:25.0,
              fit: BoxFit.fitHeight,),

            ),
            Text(
              title,
              style: KfontConstant.defaultSubStyle,
            )
          ],
        ));
  }
}

class ChildrenList extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final VoidCallback getNextPage;
  ChildrenList(this.list, {this.getNextPage});
  @override
  Widget build(BuildContext context) {
    return list.length == 0
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text("空空如也"),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5),
            itemCount: list.length,
            itemExtent: 75,
            itemBuilder: (BuildContext context, int i) {
              Map<String, dynamic> item = list[i];
              /* if ((i + 3) == list.length) {
              getNextPage();
            }*/
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  color: KColorConstant.searchAppBarBgColor,
                  padding: EdgeInsets.all(5),
                  child: ListTile(
                    leading: CachedNetworkImage(
                      errorWidget: (context, url, error) =>Container(
                        height: 25,
                        width: 25,
                        child:
                              Image.asset(
                                'images/logo_b.png',)),

                      placeholder: (context, url) =>  Image.asset( 'images/logo_b.png',
                          width: 25.0,
                          height: 25.0),
                      imageUrl:item['avatar'],
                         // "http://testapp.hukabao.com:8008/public/upload/goods/thumb/236/goods_thumb_236_0_400_400.png", //
                      width: 25,
                      fit: BoxFit.cover,
                    ), //
                    title: Text(
                      item['nickname'].length<=12 ? item['nickname'] : item['nickname'].substring(0,12)+"…",
                      style: KfontConstant.defaultStyle,
                    ),
                   subtitle:  Text(
                     "V${(item['level']-1)}(${item['levelname']})",
                     style: KfontConstant.defaultStyle,
                   ), /* Text(
                      item['phone'],
                      style: KfontConstant.defaultLittleStyle,
                    ),*/
                    trailing: Text(
                      "注册${item['reg_time']??''}",
                      style: KfontConstant.defaultStyle,
                    ),
              /*      Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[

                      ],
                    ),*/
                  ),
                ),
              );
            },
          );
  }
}
