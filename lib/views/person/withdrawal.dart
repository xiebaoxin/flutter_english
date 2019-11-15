import 'package:flutter/material.dart';
import '../../utils/comUtil.dart';
import '../../model/globle_model.dart';
import '../../model/userinfo.dart';
import '../../utils/DialogUtils.dart';
import '../../utils/dataUtils.dart';
import '../../utils/HttpUtils.dart';
import '../../routers/application.dart';
import '../../globleConfig.dart';
import 'withdrawals.dart';
import 'withdrawal_set.dart';
import '../../globleConfig.dart';

class WithdrawalPage extends StatefulWidget {
  final int type;
  final num max;
  WithdrawalPage({Key key, this.type =0, this.max = 0}) : super(key: key);

  @override
  WithdrawalPageState createState() => new WithdrawalPageState();
}

class WithdrawalPageState extends State<WithdrawalPage> {

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _countCtrl = TextEditingController();
  TextEditingController _pwdcontroller = TextEditingController();

  String _count = '0';
  ShapeBorder _shape = GlobalConfig.cardBorderRadius;
  Userinfo _userinfo = Userinfo.fromJson({});
  double _withdraw_fee=0.0;

  Map<String, dynamic> _response={};

 void _loadData() async {
    Map<String, String> params = {};
      _response = await HttpUtils.dioappi(
          'User/withdrawalsInit/type/${widget.type}', params,
          withToken: true, context: context);
      setState(() {
        ;
    });

  }

  @override
  void initState() {
    _loadData();
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);
    if (model.token != '') {
      _userinfo = model.userinfo;
      _withdraw_fee=model.withdraw_fee;
    }

//    _countCtrl.text = '0';
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('余额'),
          actions: <Widget>[
           IconButton(
              icon: Icon(Icons.settings),
              tooltip: '提现设置',
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) =>WithdrawaSetPage()),
                ).then((v){
                  _loadData();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
              tooltip: '历史',
              onPressed: () {
                     Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) =>WithdrawalsLogPage(type:widget.type)),
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
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("可提现总金额${widget.max.toStringAsFixed(2)}",style: KfontConstant.bigfontSize,),),
                  ),
//                  Center(child: Text("单日额度${_response['cash_config']['count_cash']??'0'}"),),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:  _response['user_extend'] != null ?
                    Center(child: Text("提现账户-支付宝${_response['user_extend']['realname']}${_response['user_extend']['cash_alipay']}"),)
                    :
                    ComFunUtil().buildMyButton(context, '设置提现账户', () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(builder: (context) =>WithdrawaSetPage()),
                      ).then((v){
                        _loadData();
                      });
                    }, ),
//                    Center(child: Text("请先设置提现账户"),),
                  ),

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
                  payword(),
                  Center(child: Text("手续费20%"),),
//                  shuomin(),${(_withdraw_fee*double.tryParse(_countCtrl.text)??0.0).toStringAsFixed(2)}
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
/*
  Widget shuomin() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:
    Card(
          clipBehavior: Clip.antiAlias,
          shape: _shape, //,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
        Text("温馨提示"),
                _response['cash_config']!=null? new Text(
                  "单次可提最大金额:${_response['cash_config']['max_cash']??'0'},1.提现金额须大于${_response['cash_config']['min_cash']??'0'}  元，3.手续费提现收取${_response['cash_config']['service_ratio']??'0'}%的手续费，每笔最低${_response['cash_config']['min_service_money']??'0'}元手续费在到账金额中扣除； 4.提现审核一般3 - 5个工作日到账",

                  style: KfontConstant.defaultSubStyle,
                ):Text('kong')
              ],
            ),
          )),,
    );
  }*/


  Widget payword(){
      return
        TextField(
          controller: _pwdcontroller,
          cursorColor: GlobalConfig.mainColor,
          decoration: new InputDecoration(
            hintText: '请输入支付密码',
            contentPadding: EdgeInsets.all(10.0),
            suffixIcon: new IconButton(
              icon: new Icon(Icons.clear,
                  color: GlobalConfig.mainColor),
              onPressed: () {
                _pwdcontroller.clear();
              },
            ),
          ),
          obscureText: true,
        )
    ;
  }

  submit(context) async {
    _count=_countCtrl.text;
    final form = _formKey.currentState;
    String paypwd = _pwdcontroller.text;
    if (paypwd.isEmpty) {
      DialogUtils.showToastDialog(context, "密码不能为空");
      return;
    }

    if (form.validate()) {
      form.save();
      Map<String, String> params = {
        "money": _count,
        "paypwd":paypwd,
        "taxfee":'0',
      };

      Application().checklogin(context, () async {
        await HttpUtils.dioappi('User/withdrawals/stype/${widget.type}', params,
            withToken: true, context: context)
            .then((response) async {
          await DialogUtils.showToastDialog(context, response['msg'].toString());
          if (response['status'].toString() == '1') {
            await DataUtils.freshUserinfo(context);
            Navigator.of(context).pop(true);
          }
        });
      });
    }
    ;
  }
}
