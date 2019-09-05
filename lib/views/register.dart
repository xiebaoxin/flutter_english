import 'dart:async'; //timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../utils/comUtil.dart';
import '../routers/application.dart';
import '../globleConfig.dart';

class register extends StatefulWidget {
  @override
  registerState createState() => new registerState();
}

class registerState extends State<register> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _phoneNoCtrl = TextEditingController();
  TextEditingController _PasswordCtrl = TextEditingController();
  String _phoneNo;
  String _password = '';
  String _inviteCode;
  bool _termsChecked = true;
  bool _passwordre = false;

  bool _obscureText = true;

  int _seconds = 0;
  String _verifyStr = '获取验证码';
  String _verifyCode;
  Timer _timer;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('注册'),
      ),
      body: new Center(
        child: Container(
            margin: EdgeInsets.all(20.0),
            color: Colors.white,
            child: Form(
              //绑定状态属性
              key: _formKey,
//              autovalidate: true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    _buildPhoneText(),
                    _buildVerifyCodeEdit(),
                    _buidPassword(),
                    _buidRePassword(),
                    _buildFromCodeText(),
                    _buideRegtxt(),
                    FlatButton(
                      color: GlobalConfig.mainColor,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          '确定',
                          style:
                              new TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ),
                      onPressed: () {
                        _termsChecked ?
                        _forSubmitted():null;
                      },
                    ),
                  ],
//                      child: RaisedButton(
//                          child: Text('添加'), onPressed: _forSubmitted),
//                    ),
                ),
              ),
            )),
      ),
    );
  }

  void _getsmsCode() async {
    _phoneNo= _phoneNoCtrl.text;
    if(_phoneNo==null ||_phoneNo=='' ||  !ComFunUtil.isChinaPhoneLegal(_phoneNo) ){
      DialogUtils.showToastDialog(context,  '手机号必须填写');
      return;
    }

      Map<String, String> params = {
        "phone": _phoneNo,
        "type": '1',
      };
    await HttpUtils.dioappi(
        "Api/smsSend", params, context: context).then((response) async{
        if (response['status'] == 1) {
         setState(() {
           _startTimer();
         });
        }
        await DialogUtils.showToastDialog(context, response['msg']);
      });

  }

  _startTimer() {
    _seconds = 120;
    _timer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        return;
      }
      setState(() {
      _seconds--;
      _verifyStr = "$_seconds(s)";
      if (_seconds == 0) {
        _verifyStr = '重新发送';
      }
      });
    });
  }

  _cancelTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _forSubmitted() async{
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      Map<String, String> params = {
        "phone": _phoneNo,
        "password": _password,
        "fromcode": _inviteCode,
        "code": _verifyCode,
        "agentid":GlobalConfig.agentid
      };
      await HttpUtils.dioappi(
          "Pub/register", params, context: context).then((response) async{
       await DialogUtils.showToastDialog(context, response['msg']);
        if (response['status']== 1)
           Application.run(context, "/login");
//        关闭当前页面并返回添加成功通知
      });
    }
  }

  Widget _buideRegtxt() {
    return new CheckboxListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
             Row(
               children: <Widget>[
                 Text(
                  '注册表示同意',
                  style: TextStyle(fontSize: 12),
            ),  InkWell(
                   onTap: () {
                     Application.run(context, "/web",url: '${GlobalConfig.base}/Api/regText',title: '用户协议',withToken: false);
                   },
                   child: new Text(
                     '注册协议',
                     style: TextStyle(fontSize: 12, color: Colors.blue),
                   ),
                 )
               ],
             ),

             Container(
               child:  Padding(
                 padding: const EdgeInsets.all(10.0),
                 child: InkWell(
                   onTap: () {
                     Application.run(context, "/web",url: '${GlobalConfig.base}/Api/serviceText',title: '隐私政策',withToken: false);
                   },
                   child: new Text(
                     '隐私政策',
                     style: TextStyle(fontSize: 12, color: Colors.blue),
                   ),
                 ),
               ) ,
             )
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        value: _termsChecked,
        onChanged: (bool value) => setState(() => _termsChecked = value));
  }


  Widget _buidPassword() {
    return TextFormField(
      controller: _PasswordCtrl,
      obscureText: _obscureText,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return '密码过短';
        }
         _password = value;
      },
      onFieldSubmitted: (String value) {
        _password = value;
      },
      onSaved: (String value) {
        _password = value;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        filled: true,
        hintText: "请输入至少6位密码",
        icon: Icon(Icons.lock) ,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? 'show password' : 'hide password',
          ),
        ),
      ),
    );
  }

  Widget _buidRePassword() {
    return TextFormField(
//      enabled: _password != '' && _password.isNotEmpty,
      obscureText: true,
      decoration: const InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        hintText: "请再输入一次密码",
        icon: Icon(Icons.lock) ,
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
      validator: (String value) {
        _passwordre = false;
        _password=_PasswordCtrl.text.trim();
        if (_password == '') return "请先输入密码";
        if (_password != value)
          return "密码不一致";

        _passwordre = true;
      },
    );
  }

  Widget _buildFromCodeText() {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        helperText: '选填',
        hintText: "邀请码(邀请者手机号)，选填",
        filled: true,
        icon: Icon(Icons.camera_front) ,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
      autovalidate: true,
      validator: (String value) {},
      onSaved: (String value) {
        _inviteCode = value;
      },
    );
  }

  Widget _buildPhoneText() {
    var node = new FocusNode();
    return TextFormField(
      controller: _phoneNoCtrl,
//      autovalidate: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        icon: Icon(Icons.phone) ,
        hintText:  "请输入手机号码",
//        hintStyle: TextStyle(fontSize: 10),
        filled: true,
        fillColor: Colors.white,
//        errorStyle: TextStyle(fontSize: 8),
      ),
//      style: Theme.of(context).textTheme.headline,
      maxLines: 1,
      maxLength: 11,
      //键盘展示为号码
      keyboardType: TextInputType.phone,
      //只能输入数字
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      validator: (String value) {
        if (value.isEmpty) {
          return '请填写手机号码';
        } else {
          if (!ComFunUtil.isChinaPhoneLegal(value.trim())) return '号码有误';
        }
      },
      onSaved: (String value) {
        _phoneNo = value;
      },

    );
  }

  Widget _buildVerifyCodeEdit() {
    var node = new FocusNode();
    Widget verifyCodeEdit = new TextFormField(
//      autovalidate: true,
      style: KfontConstant.defaultSubStyle,
      decoration: new InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        icon: Icon(Icons.assignment_late) ,
        hintText:  "请输入验证码",
//        hintStyle: TextStyle(fontSize: 10),
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
      maxLines: 1,
      maxLength: 6,
      //键盘展示为数字
      keyboardType: TextInputType.number,
      //只能输入数字
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],

      validator: (String value) {
        if (value.isEmpty) {
          return '';
        }
      },
      onSaved: (String value) {
        _verifyCode = value.trim();
      },

    );
    Widget verifyCodeBtn = new InkWell(
      onTap: (_seconds == 0) ? _getsmsCode : null,
      child: new Container(
       alignment: Alignment.center,
        width: 80.0,
        height: 26.0,
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        decoration: BoxDecoration(
            border: new Border.all(
              width: 1.0,
              color: Colors.grey,
            )
        ),
        child: Text(
          _verifyStr,
          style: new TextStyle(fontSize: 11),
        ),
      ),
    );

    return new Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
        top: 5.0,
      ),
      child: new Stack(
        children: <Widget>[
          verifyCodeEdit,
          new Align(
            alignment: Alignment.topRight,
            child: verifyCodeBtn,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(register oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
