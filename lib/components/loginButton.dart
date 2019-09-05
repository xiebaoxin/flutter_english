import 'package:flutter/material.dart';
import '../routers/application.dart';
import 'package:fluro/fluro.dart';

class LoginButton extends StatelessWidget {
  final String userName;
  final String userPic;

  LoginButton({Key key, this.userPic, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userName != '') {
      return FlatButton(
          onPressed: () {
            print('click loggout');
            Application.router.navigateTo(context, "/login",
                transition: TransitionType.fadeIn);
   /*         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen()), (//跳转到主页
                Route route) => route == null);
*/
          },
          child: Text(
            '登陆 . 注册',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w200,
            ),
          ));
    }
    return Container(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(userPic),
            child: Text(userName),
          ),
        ],
      ),
    );
  }
}
