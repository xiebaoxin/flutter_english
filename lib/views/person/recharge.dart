import 'package:flutter/material.dart';
import '../../utils/comUtil.dart';
import '../../model/globle_model.dart';
import '../../model/userinfo.dart';
import '../../utils/DialogUtils.dart';
import '../../utils/dataUtils.dart';
import '../../utils/HttpUtils.dart';
import '../../routers/application.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'rechagelog.dart';
import '../pay_page.dart';
import '../../globleConfig.dart';

class reChargePage extends StatefulWidget {
  @override
  rechgPageState createState() => rechgPageState();
}

class rechgPageState extends State<reChargePage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _countCtrl = TextEditingController();
  num _count = 0;
  int _objtype = 0;
  Userinfo _userinfo = Userinfo.fromJson({});
  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);
    if (model.token != '') {
      _userinfo = model.userinfo;
    }

    return new Scaffold(
      appBar: new AppBar(title: new Text('充值'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.history),
          tooltip: '历史',
          onPressed: () {
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => rechageLogPage()),
            );
          },
        ),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          child: Form(
              //绑定状态属性
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ComFunUtil().buideStandInput(
                      context,
                      '金额:',
                      _countCtrl,
                      valfun: (value) {
                        if (value.isEmpty) {
                          return '请填写整数金额';
                        }
                      },
                      iType: 'number',
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 45,
                          child: ListTile(
                              title: Text(
                                "支付宝",
                                style: KfontConstant.defaultSubStyle,
                              ),
                              trailing: Radio(
                                value: 1,
                                groupValue: _objtype,
                                activeColor: Colors.blue,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 45,
                          child: ListTile(
                              title: Text(
                                "微信",
                                style: KfontConstant.defaultSubStyle,
                              ),
                              trailing: Radio(
                                value: 0,
                                groupValue: _objtype,
                                activeColor: Colors.blue,
                              )),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("余额提现将会收取手续费20%"),
                  ),
                  ComFunUtil().buildMyButton(context, '确定', () {
                    Application().checklogin(context, () {
                      submit(context);
                    });
                  }, disabled: _countCtrl.text != '' ? false : true),
                  const SizedBox(height: 10.0),
                ],
              )),
        ),
      ),
    );
  }

  submit(context) async {
    final form = _formKey.currentState;
    String yue = _countCtrl.text;
    if (yue.isEmpty) {
      DialogUtils.showToastDialog(context, "充值金额不能为空");
      return;
    }

    if (form.validate()) {
      form.save();
      Map<String, String> params = {
        "account": yue.toString(),
      };
      bool oks = await DialogUtils().showMyDialog(context, '是否确定充值加油?');
      if (!oks) return;
      await HttpUtils.dioappi('Cart/recharge', params,
              withToken: true, context: context)
          .then((response) async {
        await DialogUtils.showToastDialog(context, response['msg'].toString());
        if (response['status'] == 1) {
          wxsubmit(response['order_sn'].toString(), context);
        }
      });
    }
    ;
  }

  Future wxsubmit(String order_sn, context) async {
    Map<String, dynamic> params = {
      "order_sn": order_sn,
    };

    await HttpUtils.dioappi('WxAppPay/getRechargeWxpay', params,
            withToken: true, context: context)
        .then((response) async {
      if (response['status'] == 1) {
        var result = response['data'];
        /*
     * {"appid":"wx39e1569fa6461815","noncestr":"ZuWneIWJccaUT1Xsg7MzD5f9SYDNa9YA","package":"Sign=WXPay",
     * "partnerid":"1254837501","prepayid":"wx311745171449585cd648ac611956873300","timestamp":1564566317,"sign":"A0F7079F3A0726BA92A3C7B401AD00D2"},"config":*/
        await fluwx
            .pay(
                appId: result['appid'].toString(),
                partnerId: result['partnerid'].toString(),
                prepayId: result['prepayid'].toString(),
                packageValue: result['package'].toString(),
                nonceStr: result['noncestr'].toString(),
                timeStamp: int.tryParse(result['timestamp'].toString()),
                sign: result['sign'].toString(),
                extData: "加油:${_countCtrl.text}")
            .then((data) async {
          print("---》$data");
          return data;
        }).whenComplete(() async {
          await DataUtils.freshUserinfo(context);
          Navigator.of(context).pop();
        });
      }
    });
  }
}
