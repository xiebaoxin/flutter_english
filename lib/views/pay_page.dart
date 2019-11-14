import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:image_picker/image_picker.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';
import '../routers/application.dart';
import '../utils/DialogUtils.dart';
import '../utils/HttpUtils.dart';
import '../utils/dataUtils.dart';
import '../utils/screen_util.dart';
import '../utils/comUtil.dart';
import '../model/userinfo.dart';
import 'person/order_list.dart';

class PayPage extends StatefulWidget {
  final String order_sn;
  int paytype; //0订单支付 1充值
  bool is_farm;
  PayPage(this.order_sn, {this.paytype = 0, this.is_farm = false});
  @override
  PayPageState createState() => PayPageState();
}

class PayPageState extends State<PayPage> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  File _image;
  int _objtype = 0;
  int _payofftype = 0;
  String _payname = "";
  var _goodslist;
  Map<String, dynamic> _payinfo = {};
  ShapeBorder _shape = GlobalConfig.cardBorderRadius;
  Userinfo _userinfo = Userinfo.fromJson({});
  String _outpaytranceid;
  int _outpaed = 0;
  bool _payed = false;

  Future _getdata() async {
    final model = globleModel().of(context);

    if (model.token != '') {
      _userinfo = model.userinfo;
    }

    Map<String, String> params = {
      "order_sn": widget.order_sn,
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'Cart/cart4', params,
        withToken: true, context: context);
//    print(response['result']);
    if (response['status'].toString() == "1") {
      setState(() {
        _payname = response['result']['body'];
        _outpaytranceid = response['result']['outpay_transid'];
        _payinfo = response['result']['order'];
        _outpaed = response['result']['outpaed'];
        _goodslist = response['result']['goods_list'];
      });
    }else if (response['status']== 0) {
      await DialogUtils.showToastDialog(context, response['msg']);
      setState(() {
        _payname = response['result']['body'];
        _outpaytranceid ='';
        _payinfo = response['result']['order'];
        _goodslist = response['result']['goods_list'];
        _outpaed=1;
      });
  }  else{
      await DialogUtils.showToastDialog(context, response['msg']);
      Navigator.of(context).pop(false);
    }
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _getdata();
    super.initState();

    fluwx.responseFromPayment.listen((data) {
      setState(() {
        print("${data.errCode}");
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _image?.delete();
  }

  @override
  Widget build(BuildContext context) {
    String amount = "0";
    amount = widget.paytype == 1
        ? _payinfo['account'].toString()
        : _payinfo['order_amount'].toString();
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('订单支付'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
//            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Container(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("订单编号:",
                                style: KfontConstant.defaultStyle),
                            Text(" ${widget.order_sn}",
                                style: KfontConstant.defaultStyle),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("订单时间: ",
                                style: KfontConstant.defaultStyle),
                            Text(" ${_payinfo['add_time']}",
                                style: KfontConstant.defaultStyle),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
//            dizhi(),
            _orderItemsList(),
            Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "订单金额：",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                      Text(
                                        "${_payinfo['total_amount']}元",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "商品合计：",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                      Text(
                                        "${_payinfo['goods_price']}元",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                    ]),
    /*     Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "团购：",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                      Text(
                                        "${_payinfo['coupon_price']}元",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                    ]),
                              */
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "积分：",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                      Text(
                                        "${_payinfo['integral']}BX",
                                        style: KfontConstant.defaultStyle,
                                      ),
                                    ]),
                              ]),
                        )))),
          ],
        )),
        bottomNavigationBar: buildbottomsheet(context));
  }

  Widget dizhi() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.location_city),
                  title: Text(
                    "收货人： ${_payinfo['consignee']}[${_payinfo['mobile']}]",
                    maxLines: 1,
                    softWrap:
                        true, //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: _payinfo.isNotEmpty
                      ? Text("${_payinfo['address']}",
                          maxLines: 1,
                          softWrap:
                              true, //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
                          overflow: TextOverflow.ellipsis,
                          style: KfontConstant.defaultSubStyle)
                      : null,
                ),
                Divider(),
                Text(
                  "运费： ${_payinfo['shipping_price']}元",
                  style: KfontConstant.defaultStyle,
                ),
              ],
            ),
          ),
        ));
  }

  _orderItemsList() {
    var ods = _goodslist as List;
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: ods != null
          ? Card(
              child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: ods.map((v) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 0),
                        child: Column(
                          children: <Widget>[_goodsItem(v), Divider()],
                        ),
                      );
                    }).toList(),
                  )),
            )
          : Divider(),
    );
  }

  Widget _goodsItem(Map<String, dynamic> goods) {
    return GestureDetector(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                imageUrl: goods['pic_url'],
//                  width:  MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
                height: 48,
                width: 48.0,
              ),
            ),
            _orderTitle(goods),
          ],
        ),
      ),
      onTap: () {
        Application.goodsDetail(context, goods['goods_id']);
      },
    );
  }

  _orderTitle(Map<String, dynamic> goods) {
    return Container(
      padding: EdgeInsets.all(0),
      width: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            goods['goods_name'],
            maxLines: 2,
            softWrap: true, //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "￥${goods['member_goods_price']}",
                    style: TextStyle(fontSize: 11),
                  ),
                  Text("x${goods['goods_num']}",
                      style: TextStyle(fontSize: 11, color: Colors.black54)),
                ]),
          ),

          goods['spec_key_name'] != null
              ? Text(
                  "规格：${goods['spec_key_name']}",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                )
              : SizedBox(
                  width: 1,
                ), //规格
        ],
      ),
    );
  }

  Future<void> _openImage() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _image = file;
      });
      submitteOutPay(file);
    }
  }

  void refreshShowpayform(int v){
    setState(() {
      _objtype = v;
    });
    Navigator.of(context).pop();
    showPayForm();
  }
  void showPayForm() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              width: ScreenUtil.screenWidth,
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          Text(
                            "确认付款",
                          ),
                          Icon(Icons.error_outline)
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        child: Column(
                      children: <Widget>[
                        Text("订单号：${widget.order_sn}"),
                        Text(
                          "合计支付：${widget.paytype == 1 ? _payinfo['account'].toString() : _payinfo['order_amount'].toString()}元",
                          style: TextStyle(fontSize: 24),
                        )
                      ],
                    )),
                    Expanded(
                      child: _outpaed == 0
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                height: 100,
                                child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                    Container(
                                      height: 35,
                                      child: ListTile(
                                          title: Text(
                                            "支付宝",
                                            style: KfontConstant.defaultSubStyle,
                                          ),
                                          trailing:  Radio(
                                            value:1,
                                            groupValue:_objtype,
                                            activeColor: Colors.blue,
                                            onChanged:(v){
                                              refreshShowpayform(v);
                                            },
                                          )
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      child: ListTile(
                                          title: Text(
                                            "微信",
                                            style: KfontConstant.defaultSubStyle,
                                          ),
                                          trailing:  Radio(
                                            value:0,
                                            groupValue:_objtype,
                                            activeColor: Colors.blue,
                                            onChanged:(v){
                                              refreshShowpayform(v);
                                            },
                                          )
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      child: ListTile(
                                          title: Text(
                                            "线下支付",
                                            style: KfontConstant.defaultSubStyle,
                                          ),
                                          trailing:  Radio(
                                            value:2,
                                            groupValue:_objtype,
                                            activeColor: Colors.blue,
                                            onChanged:(v){
                                              refreshShowpayform(v);
                                            },
                                          )
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        ComFunUtil().buildMyButton(context, '确认支付', () {
                                          Application().checklogin(context, () {
                                           if(_objtype == 0) wxsubmit();
                                           if(_objtype == 1) submit();
                                           if(_objtype == 2){
                                             Navigator.of(context).pop();
                                             showofflinePayForm();
                                           }
                                          });
                                        },),
                                      ],
                                    ),
                                  ],)
                              ),
                            )
                          : SizedBox(height: 10.0),
                    ),

                  ])

              );
        });
  }

  void showofflinePayForm() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              width: ScreenUtil.screenWidth,
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          Text(
                            "确认付款",
                          ),
                          Icon(Icons.error_outline)
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        child: Column(
                          children: <Widget>[
                            Text("订单号：${widget.order_sn}"),
                            Text(
                              "合计支付：${widget.paytype == 1 ? _payinfo['account'].toString() : _payinfo['order_amount'].toString()}元",
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        )),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("选择支付方式："),
                          ),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            ChoiceChip(
                              key: ValueKey<int>(0),
                              label: Text(
                                "支付宝",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(20),
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'FZLanTing',
                                    color: Colors.white),
                              ),
                              //未选定的时候背景
                              selectedColor: GlobalConfig.mainColor,
                              //被禁用得时候背景
//                            disabledColor: Colors.grey,
                              backgroundColor: Colors.grey,
                              selected: _payofftype == 0,
                              onSelected: (bool value) {
//                              parent.onSelectedChanged(index);
                                setState(() {
                                  _payofftype = 0;
                                  Navigator.of(context).pop();
                                  showofflinePayForm();
                                });
                              },
                            ),
                            ChoiceChip(
                              key: ValueKey<int>(1),
                              label: Text(
                                "微信",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(20),
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'FZLanTing',
                                    color: Colors.white),
                              ),
                              //未选定的时候背景
                              selectedColor: GlobalConfig.mainColor,
                              backgroundColor: Colors.grey,
                              selected: _payofftype == 1,
                              onSelected: (bool value) {
                                setState(() {
                                  _payofftype = 1;
                                  Navigator.of(context).pop();
                                  showofflinePayForm();
                                });
                              },
                            )
                          ]),
                        ],
                      ),
                    ),
                    FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: ComFunUtil().buildMyButton(
                                    context,
                                    _payed ? '上传中……' : '请上传已支付凭证或截图',
                                    _payed
                                        ? null
                                        : () {
                                            _openImage();
                                          },
                                    width: 200,height: 34),
                              ),
                    Expanded(
                        child:Center(
                                child: Image.asset(
                                  _payofftype == 0  ? 'images/alioffpay.jpg': 'images/wxoffpay.jpg',
                                height: 300,
                                fit: BoxFit.fill,
                              ))
                           )
                  ])

          );
        });
  }

  Widget buildbottomsheet(context) {
    return Container(
      width: ScreenUtil.screenWidth,
      height: ScreenUtil().L(60),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: ScreenUtil().L(300),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Center(
                child: Row(
                  children: <Widget>[
                    Text(
                      "合计支付：${widget.paytype == 1 ? _payinfo['account'].toString() : _payinfo['order_amount'].toString()}元",
                      style: KfontConstant.defaultStyle,
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: InkWell(
            onTap: () async {
              if (_outpaed == 0) showPayForm();
            },
            child: _outpaed == 0
                ? Container(
                    height: ScreenUtil().H(50),
                    width: 80,
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                      color: Color(0xFFfe5400),
                      border: null,
                      gradient: const LinearGradient(
                          colors: [Colors.orange, Color(0xFFfe5400)]),
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(20.0)),
                    ),
                    child: Text(
                      '立即支付',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(16)),
                    ),
                  )
                : Text("已经支付，待确认",
                    style: TextStyle(
                        color: Color(0xFFfe5400),
                        fontSize: ScreenUtil().setSp(16))),
          )),
        ],
      ),
    );
  }

  void submit() async {
    Application().checklogin(context, () async {
      String strurlprm =
          "order_sn=${widget.order_sn}&type=$_objtype&user=${_userinfo.id}&price=&money=${_payinfo['order_amount'].toString()}";
      Application.webto(context, "/web",
              url:
                  '${GlobalConfig.server}/plugins/codepay/tmlcodepay.php?$strurlprm',
              title: '扫码支付')
          .then((response) {
        _getdata();
      });
    });
  }

  void submitteOutPay(File image) async {
    setState(() {
      _payed = true;
    });
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
    FormData formData = new FormData.from({
      "order_sn": _payinfo['order_sn'],
      "transaction_id": _outpaytranceid,
      "offline_pay": "apptest",
      "payed_pic": new UploadFileInfo(new File(path), name,
          contentType: ContentType.parse("image/$suffix"))
    });

    await HttpUtils.dioFormAppi(
            widget.is_farm ? 'Cart/offline_pay/act/farm' : 'Cart/offline_pay',
            formData,
            withToken: true,
            context: context)
        .then((response) async {
      await DialogUtils.showToastDialog(context, response['msg']);
      if (response['status'].toString() == '1') {
        await DataUtils.freshUserinfo(context);
        Navigator.pop(context);
      } else {
        setState(() {
          _payed = false;
        });
      }
    });
  }

  void submittestok() async {
    Map<String, String> params = {
      "order_sn": _payinfo['order_sn'],
      "transaction_id": DateTime.now().toString(),
      "pay_code": "apptest"
    };
    await HttpUtils.dioappi(
            widget.is_farm ? 'Cart/order_action/act/farm' : 'Cart/order_action',
            params,
            withToken: true,
            context: context)
        .then((response) async {
      await DialogUtils.showToastDialog(context, response['msg']);
      if (response['status'].toString() == '1') {
        await DataUtils.freshUserinfo(context);
        Application.run(context, "/home");
      } else {
        setState(() {
          _payed = false;
        });
      }
    });
  }

  Future wxsubmit() async {
    Map<String, dynamic> params = {
      "order_sn": _payinfo['order_sn'].toString(),
    };

    await HttpUtils.dioappi('WxAppPay/getWxpay', params,
            withToken: true, context: context)
        .then((response) async {
    print(response);
    if (response['status'] == 1) {
    var result = response['data'];

        /*
     * {"appid":"wx39e1569fa6461815","noncestr":"ZuWneIWJccaUT1Xsg7MzD5f9SYDNa9YA","package":"Sign=WXPay",
     * "partnerid":"1254837501","prepayid":"wx311745171449585cd648ac611956873300","timestamp":1564566317,"sign":"A0F7079F3A0726BA92A3C7B401AD00D2"},"config":*/
        await fluwx.pay(
        appId: result['appid'].toString(),
      partnerId: result['partnerid'].toString(),
      prepayId: result['prepayid'].toString(),
      packageValue: result['package'].toString(),
      nonceStr: result['noncestr'].toString(),
      timeStamp: int.tryParse(result['timestamp'].toString()),
      sign: result['sign'].toString(),
                extData: "买:$_payname")
            .then((data) async {
          print("---》$data");
          return data;
//    await DataUtils.freshUserinfo(context);
        }).whenComplete(() {
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => OrderListPage()),
          );
        });
      }
    });
  }



}
