import 'dart:convert';
import 'dart:io' as H;

import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class PayPage extends StatefulWidget {
  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  String _url = "https://wxpay.wxutil.com/pub_v2/app/app_pay.php";

  String _result = "无";

  @override
  void initState() {
    super.initState();

    fluwx.responseFromPayment.listen((data) {
      setState(() {
        _result = "${data.errCode}";
      });
    });
  }
/*  fluwx.pay(WeChatPayModel(
  appId: 'wxd930ea5d5a258f4f',
  partnerId: '1900000109',
  prepayId: '1101000000140415649af9fc314aa427',
  packageValue: 'Sign=WXPay',
  nonceStr: '1101000000140429eb40476f8896f4c9',
  timeStamp: '1398746574',
  sign: '7FFECB600D7157C5AA49810D2D8F28BC2811827B',
  signType: '选填',
  extData: '选填'
  ));
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("pay"),
      ),
      body: Column(
        children: <Widget>[
          OutlineButton(
            onPressed: () async {
              var h = H.HttpClient();
              h.badCertificateCallback = (cert, String host, int port) {
                return true;
              };
              var request = await h.getUrl(Uri.parse(_url));
              var response = await request.close();
              var data = await response.transform(Utf8Decoder()).join();
              Map<String, dynamic> result = json.decode(data);
              print(result['appid']);
              print(result["timestamp"]);
              fluwx
                  .pay(
                appId: result['appid'].toString(),
                partnerId: result['partnerid'].toString(),
                prepayId: result['prepayid'].toString(),
                packageValue: result['package'].toString(),
                nonceStr: result['noncestr'].toString(),
                timeStamp: result['timestamp'],
                sign: result['sign'].toString(),
              )
                  .then((data) {
                print("---》$data");
              });
            },
            child: const Text("pay"),
          ),
          const Text("响应结果;"),
          Text(_result)
        ],
      ),
    );
  }
}