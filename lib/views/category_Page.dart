import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/dataUtils.dart';
import 'goodsList.dart';

class CategoryPage extends StatefulWidget {
  final int catid;
  final String catname;
  CategoryPage(Key key, this.catid,{this.catname=""}) : super(key: key);
  @override
  CategoryPageState createState() => new CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  int _page = 1;
  List<Map<String, dynamic>> _goodsList = List();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
       title: new Text(widget.catname),
      ),
      body:  GoodsListWidget(_goodsList, getNextPage: () => getGoodsList())
    );
  }
  @override
  void initState() {
    getGoodsList();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getGoodsList() async {
    _goodsList= await DataUtils.getIndexGoodsList(_page,_goodsList, context,catid:widget.catid );
    if(_goodsList.isNotEmpty)
      setState(() {
          _page += 1;
      });
/*    await HttpUtils.dioappi(
        "Shop/ajaxGoodsList/p/${_page.toString()}/id/${widget.catid}", {}, context: context).then ((response) {
      print(response);
      setState(() {
        if (response['list'].isNotEmpty) {
          _page += 1;
          response['list'].forEach((ele) {
            if (ele.isNotEmpty) {
              Map<String, dynamic> itemmap = ele;
              _goodsList.add(itemmap);
            }
          });
        }
      });
    });*/
  }

  @override
  void didUpdateWidget(CategoryPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
