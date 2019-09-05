import 'package:flutter/material.dart';
import '../../utils/comUtil.dart';
import '../../model/globle_model.dart';
import '../../model/userinfo.dart';
import '../../utils/DialogUtils.dart';
import '../../utils/dataUtils.dart';
import '../../utils/HttpUtils.dart';
import '../../routers/application.dart';
import 'rechagelog.dart';
import '../pay_page.dart';

class reChargePage extends StatelessWidget {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _countCtrl = TextEditingController();
  num _count = 0;
  Userinfo _userinfo = Userinfo.fromJson({});
  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);
    if (model.token != '') {
      _userinfo = model.userinfo;
    }

    _countCtrl.text = '100';
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('充值'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.history),
              tooltip: '历史',
              onPressed: () {
                     Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) =>rechageLogPage()),
              );
              },
            ),
          ]
      ),
      body: Center(
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
                  ComFunUtil().buildMyButton(context, '确定', () {
                    submit(context);
                  }, disabled: _countCtrl.text !='' ? false : true),
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

      Application().checklogin(context, () async {
        await HttpUtils.dioappi('Cart/recharge', params,
            withToken: true, context: context)
            .then((response) async {
          await DialogUtils.showToastDialog(context, response['msg'].toString());
          if (response['status'].toString() == '1') {
            await DataUtils.freshUserinfo(context);
//            Navigator.of(context).pop(true);
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) =>PayPage(response['order_sn'].toString(),paytype: 1,)),
            ).then((v){
              Navigator.of(context).pop(true);
            });

          }
        });
      });
    }
    ;
  }
}
