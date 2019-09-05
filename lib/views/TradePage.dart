import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../model/globle_model.dart';
import '../routers/application.dart';
import '../globleConfig.dart';
import '../utils/HttpUtils.dart';
import '../utils/dataUtils.dart';
import '../model/userinfo.dart';

class TradePage extends StatefulWidget {
  @override
  MyTradePageState createState() => new MyTradePageState();
}

class MyTradePageState extends State<TradePage>{

  int _page=1;
  List<Map<String, dynamic>> _payLogList = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(""),
        centerTitle: true,
        title: Text("收藏"),
      ),
        body:  TopListWidget(_payLogList, getNextPage: () => _loadData()),
    );

  }
  _loadData() async {
    var response= await HttpUtils.dioappi("User/collect_list/p/${_page.toString()}", {},context: context);
    print(response);
    setState(() {
      if (response['list'].isNotEmpty) {
//        _page += 1;
        response['list'].forEach((ele) {
          if (ele.isNotEmpty) {
            Map<String, dynamic> itemmap = ele;
            _payLogList.add(itemmap);
          }
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }
}


class TopListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final VoidCallback getNextPage;
  TopListWidget(this.list, { this.getNextPage});
  @override
  Widget build(BuildContext context) {
    Widget imgtop;
    return
      list.length == 0
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text("空空如也"),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5),
        itemCount: list.length,
//          itemExtent: 75,
        itemBuilder: (BuildContext context, int i) {
          Map<String, dynamic> item = list[i];
          if ((i + 3) == list.length) {
            getNextPage();
          }

          String titile=item['goods_name'].toString()??'未命名';
          titile= titile.length<=12 ? titile : titile.substring(0,12)+"…";
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              color: KColorConstant.searchAppBarBgColor,
              padding: EdgeInsets.all(5),
              child:
              i==0?
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ListTile(

                      title:  Text("名称",style: KfontConstant.bigfontSize,),
                      trailing: new Text(
                        '时间',
                        style: KfontConstant.defaultSubStyle,
                      ),
                    ),
                    Divider(height: 1,),
                    ListTile(
                      leading:imgtop,
                      title: new Text(titile),
                      trailing: new Text(
                        '----',
                        style: TextStyle(
                            fontSize: 12.0
                        ),
                      ),
                    )])
                  :
              ListTile(
                leading:imgtop,
                title: new Text(titile),
                trailing: new Text(
                  '----',
                  style: TextStyle(
                      fontSize: 12.0
                  ),
                ),
              ),
            ),
          );
        },
      );
  }
}
