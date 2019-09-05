import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/comUtil.dart';
import '../../utils/HttpUtils.dart';
import '../../utils/DialogUtils.dart';
import '../../routers/application.dart';
import '../../model/globle_model.dart';
import '../../model/userinfo.dart';

class SetPasswordPage extends StatefulWidget {
  @override
  SetPasswordPageState createState() => SetPasswordPageState();
}

class SetPasswordPageState extends State<SetPasswordPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _PasswordCtrl = TextEditingController();
  TextEditingController _oldPasswordCtrl = TextEditingController();
  String _password = '';
  bool _passwordre = false;
  bool _obscureText = true;


  Userinfo _userinfo = Userinfo.fromJson({});

  void _initdata() async{
    final model = globleModel().of(context);
    if ( model.token!= '') {
      _userinfo = model.userinfo;
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    _initdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("修改密码"),
        ),
        body: Form(
            //绑定状态属性
            key: _formKey,
            autovalidate: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        initialValue: _userinfo.phone,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            icon: Icon(Icons.phone)),
                      ),
                    ),

                    _buidOldPassword(),
                    _buidPassword(),
                    _buidRePassword(),
                    const SizedBox(height: 10.0),
                    ComFunUtil().buildMyButton(context, '确定', () {
                      submit();
                    }, disabled: _oldPasswordCtrl.text != '' ? false : true),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            )));
  }

  Widget _buidPassword() {
    return TextFormField(
      controller: _PasswordCtrl,
      obscureText: _obscureText,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return '密码过短';
        }
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
  Widget _buidOldPassword() {
    return TextFormField(
      controller: _oldPasswordCtrl,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.trim().length < 6) {
          return '密码过短';
        }
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        filled: true,
        hintText: "请输入旧密码",
        icon: Icon(Icons.lock) ,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
    );
  }



  submit() async {
    final form = _formKey.currentState;

    String yuyueday = _oldPasswordCtrl.text;
    if (yuyueday.isEmpty) {
      DialogUtils.showToastDialog(context, "旧密码不能为空");
      return;
    }
    String dh = _PasswordCtrl.text;
    if (dh.isEmpty) {
      DialogUtils.showToastDialog(context, "，密码不能为空");
      return;
    }
    if(!_passwordre){
      DialogUtils.showToastDialog(context, "，密码确认不一致");
      return;
    }

    if (form.validate()) {
      form.save();

      Map<String, String> params = {
        "old_password": _oldPasswordCtrl.text.toString(),
        "new_password": _PasswordCtrl.text.toString(),
        "confirm_password": _PasswordCtrl.text.toString(),
      };

      Application().checklogin(context, () async {
        await HttpUtils.dioappi('User/password', params,
                withToken: true, context: context)
            .then((response) async {
          await DialogUtils.showToastDialog(context, response['msg'].toString());
          if (response['status'].toString() == '1') {
            Navigator.of(context).pop(true);
          }
        });
      });
    }
    ;
  }
}
