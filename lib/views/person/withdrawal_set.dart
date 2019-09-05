import 'dart:async'; //timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/HttpUtils.dart';
import '../../utils/DialogUtils.dart';
import '../../utils/dataUtils.dart';
import '../../routers/application.dart';
import '../../utils/comUtil.dart';
import '../../globleConfig.dart';

class WithdrawaSetPage extends StatefulWidget {
  WithdrawaSetPage({Key key, this.phone =""})
      : super(key: key);

  final String phone;

  @override
  WithdrawaSetPageState createState() => new WithdrawaSetPageState();
}

class WithdrawaSetPageState extends State<WithdrawaSetPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _phoneNoCtrl = TextEditingController();
  TextEditingController _verifyCodeCtrl = TextEditingController();


  String _phoneNo;
  String _verifyStr ;
  String _verifyCode;

  @override
  Widget build(BuildContext context) {
    if(widget.phone!="")
      _phoneNoCtrl.text=widget.phone;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('设置提现账户'),
        leading: InkWell(child: Icon(Icons.arrow_back),onTap: (){
          Navigator.of(context).pop(true);
        },),
      ),
      body: new Center(
        child: Container(
            margin: EdgeInsets.all(20.0),
            color: Colors.white,
            child: Form(
              //绑定状态属性
              key: _formKey,
              child: ListView(
                children: [
                  _buildZhifuText(),
                  ComFunUtil().buideStandInput(
                    context,
                    '账户名称:',
                    _verifyCodeCtrl,
                    valfun: (value) {
                      if (value.isEmpty) {
                        return '请填写账户名称';
                      }
                    },
                  ),
                  const SizedBox(height: 24.0),
                  ComFunUtil().buildMyButton(context, '确定', () {
                    _forSubmitted();
                  }),
                ],
//                      child: RaisedButton(
//                          child: Text('添加'), onPressed: _forSubmitted),
//                    ),
              ),
            )),
      ),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _forSubmitted() async{
    final form = _formKey.currentState;
    _verifyCode=_verifyCodeCtrl.text;
    _phoneNo= _phoneNoCtrl.text;

    form.save();
    print(_verifyCode);
    print(_phoneNo);
    if (_phoneNo!=''  && _verifyCode != '') {

      Map<String, String> params = {
        "card": _phoneNo,
        "cash_name": _verifyCode,
        'type':'0'
      };

      Application().checklogin(context, () async {
        await HttpUtils.dioappi('User/add_card', params,
            withToken: true, context: context)
            .then((response) async {
          await DialogUtils.showToastDialog(context, response['msg'].toString());
          if (response['status']==1) {
            await DataUtils.freshUserinfo(context);
            Navigator.of(context).pop(true);
          }
        });
      });

    }
  }

  Widget _buildZhifuText() {
    var node = new FocusNode();
    return TextFormField(
      controller: _phoneNoCtrl,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        icon: Icon(Icons.account_box) ,
        hintText:  "请输入支付宝账号",
        filled: true,
        fillColor: Colors.white,
      ),
//      style: Theme.of(context).textTheme.headline,
      maxLines: 1,
      onSaved: (String value) {
        _phoneNo = value.trim();
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
