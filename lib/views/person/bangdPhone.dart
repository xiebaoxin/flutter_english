import 'dart:async'; //timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/HttpUtils.dart';
import '../../utils/DialogUtils.dart';
import '../../utils/dataUtils.dart';
import '../../routers/application.dart';
import '../../utils/comUtil.dart';
import '../../globleConfig.dart';

class BandPhonePage extends StatefulWidget {
  BandPhonePage({Key key, this.phone =""})
      : super(key: key);

  final String phone;

  @override
  BandPhonePageState createState() => new BandPhonePageState();
}

class BandPhonePageState extends State<BandPhonePage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _phoneNoCtrl = TextEditingController();
  TextEditingController _verifyCodeCtrl = TextEditingController();
  TextEditingController _PasswordCtrl = TextEditingController();
  TextEditingController _payPasswordCtrl = TextEditingController();


  String _phoneNo;
  String _password = '';
  String _paypassword = '';
  bool _obscureText = true;
  bool _obscurepayText = true;

  int _seconds = 0;
  String _verifyStr = '获取验证码';
  String _verifyCode;
  Timer _timer;

  @override
  Widget build(BuildContext context) {
    if(widget.phone!="")
      _phoneNoCtrl.text=widget.phone;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('绑定手机号'),
      ),
      body: new Center(
        child: Container(
            margin: EdgeInsets.all(20.0),
            color: Colors.white,
            child:
            widget.phone!=""
                ?Text("您已绑定手机${widget.phone}")
                : Form(
              //绑定状态属性
              key: _formKey,
              child: ListView(
                children: [
                  _buildPhoneText(),
                  _buildVerifyCodeEdit(),
                  _buidPassword(),
                  _buidpayPassword(),
                  const SizedBox(height: 24.0),

                  ComFunUtil().buildMyButton(context, '确定', () {
                    _forSubmitted();
                  }, disabled: _phoneNoCtrl.text !='' ? false : true),
                ],
//                      child: RaisedButton(
//                          child: Text('添加'), onPressed: _forSubmitted),
//                    ),
              ),
            )),
      ),
    );
  }

  void _getsmsCode() async {
    _phoneNo= _phoneNoCtrl.text;
    if(_phoneNo.isEmpty ||  !ComFunUtil.isChinaPhoneLegal(_phoneNo) ) {
      await DialogUtils.showToastDialog(context, '手机号必须填写');
      return;
    }
    Map<String, String> params = {
      "phone": _phoneNo,
      "type": '2',
    };

    await HttpUtils.dioappi(
        "Api/smsSend", params,
        context: context).then((response) async {
      print(response);
      if (response['status'] == 1) {
        _seconds=int.tryParse(response['timeout'])??180;
        setState(() {
          _verifyStr = '${_seconds.toString()}(s)重新发送';
        });

        _startTimer();
      }else{
        setState(() {
          _seconds=0;
        });
      }
      await DialogUtils.showToastDialog(context, response['msg']);
    });
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
        hintText: "请输入登录密码，至少6位",
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
            !_obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? 'show password' : 'hide password',
          ),
        ),
      ),
    );
  }


  Widget _buidpayPassword() {
    return TextFormField(
      controller: _payPasswordCtrl,
      obscureText: _obscurepayText,
      keyboardType:TextInputType.number,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return '密码过短';
        }
        _paypassword = value;
      },
      onFieldSubmitted: (String value) {
        _paypassword = value;
      },
      onSaved: (String value) {
        _paypassword = value;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        filled: true,
        hintText: "请输入支付密码至少6位",
        icon: Icon(Icons.lock) ,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscurepayText = !_obscurepayText;
            });
          },
          child: Icon(
            !_obscurepayText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscurepayText ? 'show password' : 'hide password',
          ),
        ),
      ),
    );
  }

  _startTimer() {
    _seconds = 60;
    _timer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        return;
      }
      setState(() {
        _seconds--;
        _verifyStr = '${_seconds.toString()}(s)重新发送';
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
    _verifyCode=_verifyCodeCtrl.text;
    _phoneNo= _phoneNoCtrl.text.trim();

    form.save();

    if (_phoneNo!='' && _password!='') {

      Map<String, String> params = {
        "mobile": _phoneNo,
        "verify_code": _verifyCode,
        "password":_PasswordCtrl.text,
        "paypwd":_payPasswordCtrl.text,
      };

      Application().checklogin(context, () async {
        await HttpUtils.dioappi('User/bind_phone', params,
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
  }

  Widget _buildPhoneText() {
    var node = new FocusNode();
    return TextFormField(
      controller: _phoneNoCtrl,
      enabled: widget.phone!=""?false:true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        icon: Icon(Icons.phone) ,
        hintText:  "请输入手机号码",
        filled: true,
        fillColor: Colors.white,
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
          return '';
        } else {
          if (!ComFunUtil.isChinaPhoneLegal(value.trim())) return '号码有误';
        }
      },
      onSaved: (String value) {
        _phoneNo = value.trim();
      },
    );
  }

  Widget _buildVerifyCodeEdit() {
    var node = new FocusNode();
    Widget verifyCodeEdit = new TextFormField(
      controller: _verifyCodeCtrl,
//      autovalidate: true,
      decoration: new InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        icon: Icon(Icons.assignment_late) ,
        hintText:  "请输入验证码",
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
      maxLines: 1,
      maxLength: 4,
      //键盘展示为数字
      keyboardType: TextInputType.number,
      //只能输入数字
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],

      validator: (String value) {
        if (value.isEmpty) {
          return '请填写验证码';
        }
      },
      onSaved: (String value) {
        _verifyCode = value.trim();
      },

    );
    Widget verifyCodeBtn = new InkWell(
      onTap: (_seconds == 0) ? _getsmsCode : null,
      child: new Container(
//        alignment: Alignment.bottomRight,
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
          '$_verifyStr',
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
