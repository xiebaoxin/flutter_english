import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
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
  int _objtype = 2;
  int _payofftype=0;
  String _payname = "";
  Map<String, dynamic> _payinfo = {};
  ShapeBorder _shape = GlobalConfig.cardBorderRadius;
  Userinfo _userinfo = Userinfo.fromJson({});
  String _outpaytranceid;
  int _outpaed=0;
  bool _payed=false;

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
        _outpaytranceid=response['result']['outpay_transid'];
        _payinfo = response['result']['order'];
        _outpaed=response['result']['outpaed'];
      });
    } else{
      await DialogUtils.showToastDialog(context, response['msg']);
      Navigator.of(context).pop(false);
    }
  }
  String _result = "无";
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _getdata();
    super.initState();


    fluwx.responseFromPayment.listen((data) {
      setState(() {
        _result = "${data.errCode}";
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
        body: Container(
            padding: EdgeInsets.all(5),
            child: Card(
              // This ensures that the Card's children are clipped correctly.
                clipBehavior: Clip.antiAlias,
                shape: _shape, //,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "购买：$_payname",
                                style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                              ),
                            ),

                            Text(
                              "订单金额： ${_payinfo['total_amount']}元",
                              style: KfontConstant.bigfontSize,
                            ),
                            Text("商品合计：${_payinfo['goods_price']}元",
                                style: KfontConstant.bigfontSize),
                            Divider(),
                            Text(
                              "收货人： ${_payinfo['consignee']}[${_payinfo['mobile']}]",
                              style: KfontConstant.bigfontSize,
                            ),
                            Divider(
                              height: 1,
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              "运费： ${_payinfo['shipping_price']}元",
                              style: KfontConstant.bigfontSize,
                            ),
                            Text("团购：${_payinfo['coupon_price']}元",
                                style: KfontConstant.bigfontSize),
                            Text("余额抵扣:${_payinfo['user_money']}元",
                                style: KfontConstant.bigfontSize),
                           /* Text("余额支付:${_payinfo['integral_money']}元",
                                style: KfontConstant.bigfontSize),*/
                            Text("积分支付: ${_payinfo['integral']}元",
                                style: KfontConstant.bigfontSize),
                            Divider(
                              height: 1,
                            ),
                            Text("订单时间: ${_payinfo['add_time']}",
                                style: KfontConstant.bigfontSize),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "还需支付：$amount",
                                style: KfontConstant.bigfontSize,
                              ),
                            ),
                            SizedBox(height: 5,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(child: Divider(height: 2,),width: ScreenUtil.screenWidthDp/2-100,),
                                Text( _outpaed==0?"选择支付":"已经支付，待确认",style: KfontConstant.defaultSubStyle,),
                                Container(child: Divider(height: 2,),width: ScreenUtil.screenWidthDp/2-100,),
                              ],
                            ),

                            _outpaed==0?
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Wrap(spacing: 8, runSpacing: 8, children: [
                                ChoiceChip(
                                  key: ValueKey<int>(1),
                                  label: Text(
                                    "支付宝",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                  //未选定的时候背景
                                  selectedColor: GlobalConfig.mainColor,
                                  //被禁用得时候背景
//                            disabledColor: Colors.grey,
                                  backgroundColor: Colors.grey,
                                  selected: _objtype == 1,
                                  onSelected: (bool value) {
//                              parent.onSelectedChanged(index);
                                    setState(() {
                                      _objtype = 1;
                                    });
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text('暂不支持支付宝支付，正在加紧开发中…'),
                                    ));
//                                        submit();
                                  },
                                ),
                                ChoiceChip(
                                  key: ValueKey<int>(2),
                                  label: Text(
                                    "微信",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                  //未选定的时候背景
                                  selectedColor: GlobalConfig.mainColor,
                                  //被禁用得时候背景
//                            disabledColor: Colors.grey,
                                  backgroundColor: Colors.grey,
                                  selected: _objtype == 0,
                                  onSelected: (bool value) {
//                              parent.onSelectedChanged(index);
                                    setState(() {
                                      _objtype = 0;
                                    });
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text('正在加紧开发中…'),
                                    ));
//                                        wxsubmit();
                                  },
                                ),
                                ChoiceChip(
                                  key: ValueKey<int>(0),
                                  label: Text(
                                    "线下支付",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                  //未选定的时候背景
                                  selectedColor: GlobalConfig.mainColor,
                                  //被禁用得时候背景
//                            disabledColor: Colors.grey,
                                  backgroundColor: Colors.grey,
                                  selected: _objtype == 2,
                                  onSelected: (bool value) {
//                              parent.onSelectedChanged(index);
                                    setState(() {
                                      _objtype = 2;
                                    });

                                  },
                                ),
                              ]),
                            ):SizedBox(height: 10.0),
                            const SizedBox(height: 10.0),
                            Divider(
                              height: 1,
                            ),
                            _objtype == 2? Column(
                              children: <Widget>[
                                /*     Row(
                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Center(
                                            child: Image.asset(
                                              'images/alioffpay.jpg',
                                              height: 200,
                                              fit: BoxFit.fill,
                                            )),
                                        Center(
                                            child: Image.asset(
                                              'images/wxoffpay.jpg',
                                              height: 200,
                                              fit: BoxFit.fill,
                                            )),
                                      ],
                                    ),*/
                                const SizedBox(height: 10.0),

                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: ComFunUtil()
                                      .buildMyButton(context, _payed ? '上传中……':'请上传已支付凭证图片', _payed?null:() {
                                    _openImage();
                                  },width: 200),
                                ),
                                const SizedBox(height: 10.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Wrap(spacing: 8, runSpacing: 8, children: [
                                        ChoiceChip(
                                          key: ValueKey<int>(0),
                                          label: Text(
                                            "支付宝",
                                            style:
                                            TextStyle(fontSize:ScreenUtil().setSp(20),fontWeight: FontWeight.w300,  fontFamily: 'FZLanTing',color: Colors.white),
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
                                            });
                                          },
                                        ),
                                        ChoiceChip(
                                          key: ValueKey<int>(1),
                                          label: Text(
                                            "微信",
                                            style:
                                            TextStyle(fontSize:ScreenUtil().setSp(20),fontWeight: FontWeight.w300,  fontFamily: 'FZLanTing',color: Colors.white),
                                          ),
                                          //未选定的时候背景
                                          selectedColor: GlobalConfig.mainColor,
                                          backgroundColor: Colors.grey,
                                          selected: _payofftype == 1,
                                          onSelected: (bool value) {
                                            setState(() {
                                              _payofftype = 1;
                                            });
                                          },
                                        )
                                      ]),
                                    ],
                                  ),
                                ),
                                _payofftype==0?
                                Center(
                                    child: Image.asset(
                                      'images/alioffpay.jpg',
                                      height: 300,
                                      fit: BoxFit.fill,
                                    )):Center(
                                    child: Image.asset(
                                      'images/wxoffpay.jpg',
                                      height: 300,
                                      fit: BoxFit.fill,
                                    )),
                                SizedBox(height: 20.0)
                              ],
                            ):SizedBox(height: 10.0),
/*
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: ComFunUtil()
                                      .buildMyButton(context, '支付完成', () {
                                    submitteOutPay(_image);
                                  }),
                                )*/
                          ],
                        ))))));
  }


  Future<void> _openImage() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(file!=null){
      setState(() {
        _image=file;
      });
      submitteOutPay(file);
    }


  }

  void submit() async {
    Application().checklogin(context, () async {
      String strurlprm = "order_sn=${widget.order_sn}&type=$_objtype&user=${_userinfo
          .id}&price=&money=${_payinfo['order_amount'].toString()}";
      Application.webto(context, "/web", url: '${GlobalConfig
          .server}/plugins/codepay/tmlcodepay.php?$strurlprm', title: '扫码支付')
          .then((response) {
        _getdata();
      });
    });
  }

  void submitteOutPay(File image) async {
    setState(() {
      _payed=true;
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
        widget.is_farm
            ? 'Cart/offline_pay/act/farm'
            : 'Cart/offline_pay',
        formData,
        withToken: true,
        context: context)
        .then((response) async {
      await DialogUtils.showToastDialog(context, response['msg']);
      if (response['status'].toString() == '1') {
        await DataUtils.freshUserinfo(context);
        Navigator.pop(context);
      }  else{
        setState(() {
          _payed=false;
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
        widget.is_farm
            ? 'Cart/order_action/act/farm'
            : 'Cart/order_action',
        params,
        withToken: true,
        context: context)
        .then((response) async {
      await DialogUtils.showToastDialog(context, response['msg']);
      if (response['status'].toString() == '1') {
        await DataUtils.freshUserinfo(context);
        Application.run(context, "/home");
      }
      else{
        setState(() {
          _payed=false;
        });
      }
    });
  }
  Future wxsubmit()async{
    Map<String, String> params = {
      "order_sn": _payinfo['order_sn'],
      "farm": widget.is_farm ? '0':'1',
    };
    await HttpUtils.dioappi('WxAppPay/getWxpay',
        params,
        withToken: true,
        context: context)
        .then((response) async {
      if (response['status'] == 1) {
        var result= response['data'];
        /*
     * {"appid":"wx39e1569fa6461815","noncestr":"ZuWneIWJccaUT1Xsg7MzD5f9SYDNa9YA","package":"Sign=WXPay",
     * "partnerid":"1254837501","prepayid":"wx311745171449585cd648ac611956873300","timestamp":1564566317,"sign":"A0F7079F3A0726BA92A3C7B401AD00D2"},"config":*/
        await  fluwx.pay(
            appId: result['appid'].toString(),
            partnerId: result['partnerid'].toString(),
            prepayId: result['prepayid'].toString(),
            packageValue: result['package'].toString(),
            nonceStr: result['noncestr'].toString(),
            timeStamp:int.tryParse( result['timestamp'].toString()),
            sign: result['sign'].toString(),
            extData: "买:$_payname"
        ).then((data) async{
          print("---》$data");
          return data;
//    await DataUtils.freshUserinfo(context);
        }).whenComplete((){
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => OrderListPage()),
          );
        });
      }
    });

  }
}
