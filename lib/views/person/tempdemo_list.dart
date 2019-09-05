import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/HttpUtils.dart';
import '../../model/paylog_model.dart';

class DemolistPage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<DemolistPage> {
  List list = new List(); //列表要展示的数据
  ScrollController _scrollController = ScrollController(); //listview的控制器
  int _page = 1; //加载的页数
  bool isLoading = false; //是否正在加载数据

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
        _getMore();
      }
    });
  }

  /**
   * 初始化list数据 加延时模仿网络请求
   */
  Future getData() async {
    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        list = List.generate(15, (i) => '哈喽,我是原始数据 $i');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("ddfdf"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemBuilder: _renderRow,
          itemCount: list.length,
          controller: _scrollController,
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _renderRow(BuildContext context, int index) {
    return ListTile(
      title: Text(list[index]),
    );
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 3), () {
      print('refresh');
      setState(() {
        list = List.generate(20, (i) => '哈喽,我是新刷新的 $i');
      });
    });
  }

  /**
   * 上拉加载更多
   */
  Future _getMore() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      await Future.delayed(Duration(seconds: 1), () {
        print('加载更多');
        setState(() {
          list.addAll(List.generate(5, (i) => '第$_page次上拉来的数据'));
          _page++;
          isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }
}