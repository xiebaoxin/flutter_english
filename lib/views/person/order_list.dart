import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/HttpUtils.dart';
import '../../utils/DialogUtils.dart';
import '../../routers/application.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/globle_model.dart';
import '../../model/userinfo.dart';
import '../../views/pay_page.dart';

class OrderListPage extends StatefulWidget {
  OrderListPage({Key key, this.title = '订单', this.type = 0}) : super(key: key);

  final int type;
  final String title;

  @override
  OrderListPageState createState() => OrderListPageState();
}

class OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController = ScrollController(); //listview的控制器

  var _tabs = [
    Tab(text: "全部"),
    Tab(text: "待付款"),
    Tab(text: "待发货"),
    Tab(text: "待收获"),
    Tab(text: "已完成"),
  ];
  var _types = ["", "WAITPAY", "WAITSEND", "WAITRECEIVE", "FINISH"];
  String _type = "";
  Userinfo _userinfo = Userinfo.fromJson({});
  void _initdata() async {
    final model = globleModel().of(context);
    if (model.token != '') {
      setState(() {
        _userinfo = model.userinfo;
      });
    }
  }

  @override
  void initState() {
    _initdata();
    _loadData();
    super.initState();
    _tabController = TabController(
        vsync: this, length: _tabs.length, initialIndex: widget.type);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _page = 1;
    _payLogList=[];
    _loading = false;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("我的订单"),
            bottom: TabBar(
              isScrollable: true,
              controller: _tabController,
//              isScrollable: true, //这个属性是导航栏是否支持滚动，false则会挤在一起了
              unselectedLabelColor: Colors.white, //未选标签标签的颜色(这里定义为灰色)
              labelColor: Colors.white70, //选中的颜色（黑色）
              indicatorColor: Colors.white, //指示器颜色
              indicatorWeight: 1.0, //指示器厚度
              tabs: _tabs,
              onTap: (index) {
                setState(() {
                  _type = _types[index];
                  _page = 1;
                  _payLogList = [];
                });
                _loadData();
              },
            ),
          ),
          body: TabBarView(
            children: _tabs.map((v) {
              return _getBody();
            }).toList(),
          ),
        ));
  }

  int _page = 1;
  bool _loading = false;
  List<Map<String, dynamic>> _payLogList = List();

  _loadData() async {
    if (_loading) {
      return null;
    }

      await HttpUtils.dioappi(
          "Order/order_list/p/${_page.toString()}/tp/${_type}/", {},
          context: context, withToken: true)
          .then((response) {
            print(response);
            print("_____________________________");
        setState(() {
          if (response['data']['list']!=null) {
            _page += 1;
            response['data']['list'].forEach((ele) {
              if (ele.isNotEmpty) {
                Map<String, dynamic> itemmap = ele;
                _payLogList.add(itemmap);
              }
            });
            _loading = true;
          }
        });
      });

  }

  Widget _getBody() {
    var length = _payLogList.length;
    return _payLogList.isNotEmpty
        ? ListView.builder(
      itemCount: _payLogList.length,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        if (index == length) {
          _loadData();
          return null;
        } else if (index > length) {
          return null;
        } else {
          print(index);
          return _orderItem(_payLogList[index]);
        }
      },
    )
        : Center(
      child: Text("什么都没有"),
    );
  }

  _orderItem(Map<String, dynamic> subject) {
    var ods = subject['order_goods'] as List;
//        Map<String,dynamic> ods = subject['order_goods'];
    return subject.isNotEmpty
        ? Card(
      margin: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "订单编号: ${subject['order_sn']}",
                  ),
                  flex: 5,
                ),
                Expanded(
                  child: Text(
                    "${subject['order_status_detail'].toString().contains("待评价") ? '完成' : subject['order_status_detail']}",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: ods.map((v) {
                  return Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 0),
                        child: Center(
                          child: _goodsItem(v),
                        ),
                      ));
                }).toList(),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Align(
                  child:
                  Text(" 合计:￥${subject['total_amount'].toString()}"),
                  alignment: FractionalOffset.bottomRight,
                ),
              ],
            ),
          ),
          /*共${order['count_goods_num'].toString()}件商品*/
          Divider(
            height: 1,
          ),
          ButtonTheme.bar(
            // make buttons use the appropriate styles for cards
              child: _orderBottomBar(subject)),
        ],
      ),
    )
        : Divider();
  }

  Widget _goodsItem(Map<String, dynamic> goods) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*   Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('images/eggs.png', width: 48.0, height: 48.0),
            ),*/
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                errorWidget: (context, url, error) =>Container(
                  height: 75,
                  width: 75,
                  child:  Image.asset(
                    'images/logo_b.png',height: 30,width: 30,fit: BoxFit.fill,),
                ),

                placeholder: (context, url) =>  CircularProgressIndicator(strokeWidth: 2,),
                imageUrl: goods['pic_url'],
//                  width:  MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
                height: 48,
                width: 48.0,
              ),
            ),

            Expanded(
              child: _orderTitle(goods),
            ),
          ],
        ),
        onTap: () {
          Application.goodsDetail(context,
              goods['goods_id'],vdtype: goods['videotype'],item:goods);
        },
      ),
    );
  }

  _orderBottomBar(Map<String, dynamic> order) {
    return Column(
      children: <Widget>[
        ButtonBar(
          children: <Widget>[
            order['pay_btn'] == 1
                ? FlatButton(
              child: const Text('立即付款'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PayPage(order['order_sn'].toString()),
                  ),
                );
              },
            )
                : Text(""),
            order['cancel_btn'] == 1
                ? FlatButton(
              child: const Text('取消订单'),
              onPressed: () {
                if (order['pay_status'] == 0)
                  HttpUtils.dioappi("Order/cancel_order/id/"+ order['order_id'].toString(),
                      {},
                      context: context, withToken: true)
                      .then((response) async {
                    await DialogUtils.showToastDialog(context, response['msg'].toString());
                    _page = 1;
                    _payLogList = List();
                    _loading = false;
                    _loadData();
                  });
                else if (order['pay_status'] == 1) {
                  HttpUtils.dioappi('Order/record_refund_order',
                      {'order_id': order['order_id'].toString()},
                      context: context, withToken: true)
                      .then((response) async {
                    await DialogUtils.showToastDialog(context, response['msg'].toString());
                    _page = 1;
                    _payLogList = List();
                    _loading = false;
                    _loadData();
                  });
                }
              },
            )
                : Text(""),
            (order['receive_btn'] == 1 && order['pay_status'] == 1)
                ? FlatButton(
              child: const Text('确认收货'),
              onPressed: () {
                HttpUtils.dioappi('Order/order_confirm/id/${order['order_id']}',
                    {},
                    context: context, withToken: true)
                    .then((response) async {
                  await DialogUtils.showToastDialog(context, response['msg'].toString());
                  _page = 1;
                  _payLogList = List();
                  _loading = false;
                  _loadData();
                });
              },
            )
                : Text(""),
            (order['shipping_btn'] == 1 && order['shipping_name'] != "")
                ? FlatButton(
              child: const Text('查看物流'),
              onPressed: () {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('正在加紧开发中…'),
                ));
              },
            )
                : Text(""),
            /*    order['comment_btn']==1?
            FlatButton(
              child: const Text('追加评论'),
              onPressed: () {
                */ /* ... */ /*
              },
            ):Text(""),*/
          ],
        ),
      ],
    );
  }

  _orderTitle(Map<String, dynamic> goods) {
    return Container(
      padding: EdgeInsets.all(5),
      height: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  goods['goods_name'].length<=8 ? goods['goods_name'] : goods['goods_name'].substring(0,8)+"…",
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                      text: "￥${goods['member_goods_price']}",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: "\n x${goods['goods_num']}",
                            style: TextStyle(color: Colors.black54))
                      ]),
                ),
              ) // 单价&数量
            ],
          ),

          goods['spec_key_name'] != null
              ? Expanded(
            child: Text(
              "规格：${goods['spec_key_name']}",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          )
              : Text(""), //规格
        ],
      ),
    );
  }
}
