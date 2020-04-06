import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:image_picker/image_picker.dart';
//import 'package:tobias/tobias.dart';
import '../globleConfig.dart';
import '../model/globle_model.dart';
import '../model/userinfo.dart';
import '../routers/application.dart';
import '../utils/DialogUtils.dart';
import '../utils/HttpUtils.dart';
import '../utils/comUtil.dart';
import '../utils/dataUtils.dart';
import '../utils/screen_util.dart';
import 'person/order_list.dart';

class GoToPayPage extends StatefulWidget {
  final String order_sn;
  int paytype; //0订单支付 1充值
  bool is_farm;
  GoToPayPage(this.order_sn, {this.paytype = 0, this.is_farm = false});
  @override
  GoToPayPageState createState() => GoToPayPageState();
}

class GoToPayPageState extends State<GoToPayPage>
    with SingleTickerProviderStateMixin {
  File _image;
  int _objtype = 0;
  int _payofftype = 0;
  String _payname = "";
  Map<String, dynamic> _payinfo = {};
  Userinfo _userinfo = Userinfo.fromJson({});
  String _outpaytranceid;
  int _outpaed = 0;
  bool _payed = false;
  String _payInfo = "";

  num _totalmy;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      child: SafeArea(
          bottom: false,
          child: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: new BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  border:
                      null // Border.all(   width: 1.0, color: Colors.green),
                  ),
              height: 480,
              child:
              _payinfo.isEmpty
                ?
              Center(
                child: Text(
                  '正在加载……',
                  style: TextStyle(fontSize: 14),
                ),
              )
              :
              payselect(),
            ),
          )),
    );
  }


  Widget payselect() {
    _totalmy = widget.paytype == 1
        ? double.tryParse(_payinfo['account']) ?? 0
        : double.tryParse(_payinfo['order_amount']) ?? 0;
    
    return Container(
        width: ScreenUtil.screenWidth,
//        color: Colors.white,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 5, 5, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _totalmy > 0
                        ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                        : SizedBox(
                      width: 5,
                    ),
                    Text(
                      "确认付款",
                    ),
                    Icon(Icons.error_outline)
                  ],
                ),
              ),
              Divider(),
              Expanded(
              child:Container(
                child: ListView(
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "订单号：",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.order_sn),
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "￥：",
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "${_totalmy.toString()}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                /*     Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("支付剩余时间：",style: TextStyle(fontSize: 10),),
                    CountDownTimer(_payinfo['account'], type: 1),
                  ],
                ),
              ),*/


                _totalmy > 0
                    ?  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      "选择支付方式：",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 45,
                                child: ListTile(
                                  title: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 12.0,
                                        backgroundImage: AssetImage(
                                          "images/alipay.png",
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.only(left: 8, right: 8),
                                        child: Text(
                                          "支付宝(暂不支持)",
                                          style: KfontConstant.defaultSubStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Radio(
                                    value: 1,
                                    groupValue: _objtype,
                                    activeColor: Colors.blue,
                                    onChanged: (v) {
                                      setState(() {
                                        _objtype = v;
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _objtype = 1;
                                    });
                                  },
                                ),
                              ),
                              Divider(),
                              Container(
                                height: 45,
                                child: ListTile(
                                  title: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 12.0,
                                        backgroundImage:
                                        AssetImage("images/weixpay.png"),
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.only(left: 8, right: 8),
                                        child: Text(
                                          "微信",
                                          style: KfontConstant.defaultSubStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Radio(
                                    value: 0,
                                    groupValue: _objtype,
                                    activeColor: Colors.blue,
                                    onChanged: (v) {
                                      setState(() {
                                        _objtype = v;
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _objtype = 0;
                                    });
                                  },
                                ),
                              ),
/*                          Divider(),
                          Container(
                            height: 35,
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 12.0,
                                    backgroundImage: AssetImage("images/weixpay.png"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8,right:8),
                                    child: Text(
                                      "扫码支付",
                                      style: KfontConstant.defaultSubStyle,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Radio(
                                value: 3,
                                groupValue: _objtype,
                                activeColor: Colors.blue,
                                onChanged: (v){
                                  ;
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  _objtype = 3;
                                });                                      },
                            ),
                          ),

                              Container(
                                height: 35,
                                child: ListTile(
                                    title: Text(
                                      "线下支付",
                                      style: KfontConstant.defaultSubStyle,
                                    ),
                                    trailing: Radio(
                                      value: 2,
                                      groupValue: _objtype,
                                      activeColor: Colors.blue,
                                      onChanged: (v){
                                        ;
                                      },
                                    ),
                                  onTap: () {
                                    state(() {
                                      _objtype = 2;
                                    });                                      },
                                ),
                              ),*/
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ComFunUtil().buildMyButton(
                                    context,
                                    '确认支付',
                                        () {
                                      Application().checklogin(context, () {
                                        if (_objtype == 0) wxsubmit();
                                        if (_objtype == 1) {
                                           DialogUtils.showToastDialog(context, "暂不支持支付宝支付");
                                        };
                                     /*   if (_objtype == 2) {
                                          Navigator.of(context).pop();
                                          showofflinePayForm();
                                        }*/
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )),
                    )
                    : Container(
                  padding: EdgeInsets.all(10),
                  height: 55,
                  child: ComFunUtil().buildMyButton(
                    context,
                    '确认支付',
                    noPayForm,
                  ),
                ),
              ])),),

            ]));
  }


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
//        _goodslist = response['result']['goods_list'];
      });
    }else if (response['status']== 0) {
      await DialogUtils.showToastDialog(context, response['msg']);
      setState(() {
        _payname = response['result']['body'];
        _outpaytranceid ='';
        _payinfo = response['result']['order'];
//        _goodslist = response['result']['goods_list'];
        _outpaed=1;
      });
    }  else{
      await DialogUtils.showToastDialog(context, response['msg']);
      Navigator.of(context).pop(false);
    }
  }


  @override
  void initState() {
    _getdata();
    super.initState();

    fluwx.responseFromPayment.listen((data) {

      if (data.errCode == 0) {
        DataUtils.freshUserinfo(context);
        Navigator.of(context).pop();

      } else {
//        print("================2=======================");
        DialogUtils.showToastDialog(context, "微信支付失败");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _image?.delete();
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

  void showofflinePayForm() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, bstate) {
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
                          child: Text(
                        "合计支付：${_totalmy.toString()}元",
                        style: TextStyle(fontSize: 24),
                      )),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.all(8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
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
                                  bstate(() {
                                    _payofftype = 0;
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
                                  bstate(() {
                                    _payofftype = 1;
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
                            width: 200,
                            height: 34),
                      ),
                      Expanded(
                          child: Center(
                              child: Image.asset(
                        _payofftype == 0
                            ? 'images/alioffpay.jpg'
                            : 'images/wxoffpay.jpg',
                        height: 300,
                        fit: BoxFit.fill,
                      )))
                    ]));
          });
        });
  }

  void noPayForm() {
    Application().checklogin(context, () async {
      Map<String, String> params = {
        "order_sn": _payinfo['order_sn'],
      };
      await HttpUtils.dioappi('Cart/nomoneypay/', params,
              withToken: true, context: context)
          .then((response) async {
        await DialogUtils.showToastDialog(context, response['msg']);
        await DataUtils.freshUserinfo(context);
        final model = globleModel().of(context);
//        model.freshOrderCounts(context);
        await Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          new MaterialPageRoute(builder: (context) => OrderListPage()),
        );
        /* if (response['status'].toString() == '1') {
          await DataUtils.freshUserinfo(context);
          Navigator.of(context).pop();
        } else {
          setState(() {
            _payed = false;
          });
        }*/
      });
    });
  }

  void smsubmit() async {
    Application().checklogin(context, () async {
      String strurlprm =
          "order_sn=${widget.order_sn}&type=$_objtype&user=${_userinfo.id}&price=&money=${_totalmy.toString()}";
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
        final model = globleModel().of(context);
//        model.freshOrderCounts(context);
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
        final model = globleModel().of(context);
//        model.freshOrderCounts(context);

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

        }).whenComplete(() async{
          await DataUtils.freshUserinfo(context);
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => OrderListPage()),
          );
        });
      }
    });
  }


/*
  Future alipayto() async {
    Map<String, String> params = {
      "order_sn": _payinfo['order_sn'],
      "farm": widget.is_farm ? '1' : '0',
    };

    await HttpUtils.dioappi('AliAppPay/getorderpay', params,
            withToken: true, context: context)
        .then((response) async {
//          print('zhifubao pay==========================');
//      print(response);
      if (response['status'] == 1 && response['code'] != null) {
        _payInfo = response['code'].toString().replaceAll("&amp;", "&");

        Map payResult;
        try {
//              print("The pay info is : " + _payInfo);
          if (_payInfo.isNotEmpty) {
            payResult = await aliPay(_payInfo);
//            print(payResult);
//            if(payResult['result']!=null){
//              print(payResult['result']['alipay_trade_app_pay_response']);
//              print(payResult['result']['alipay_trade_app_pay_response']['code']);
//            }

//            print(payResult['resultStatus']);
            if (payResult['resultStatus'] == 9000) {
//              print("------ddddd");
              DataUtils.freshUserinfo(context);

              final model = globleModel().of(context);
              await model.freshOrderCounts(context);

              Navigator.of(context).pop();
*//*
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(builder: (context) => OrderListPage()),
              );*//*

            } else {
              DialogUtils.showToastDialog(context, "支付宝支付失败");
              Navigator.of(context).pop();
            }
          }
        } on Exception catch (e) {
          payResult = {};
        }
      } else {
        await DialogUtils.showToastDialog(context, response['msg']);
      }
    });
  }*/
}
