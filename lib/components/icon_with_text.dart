import 'package:flutter/material.dart';

class IconWidthText extends StatelessWidget {
  final Image icon;
  final String text;
  final Color color;

  IconWidthText({Key key, this.color, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: GestureDetector(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Expanded(
              child: new Container(
                constraints: new BoxConstraints.expand(),
                decoration: new BoxDecoration(
                  image: new DecorationImage(
//                    image: icon,
//                image: new NetworkImage('http://h.hiphotos.baidu.com/zhi6e06f06c.jpg'),
                  image: AssetImage('images/sysicon/icon_jilu.png'),
                  ),
                ),
              ),
            ),
            Expanded(child: Text(text))
          ],
        ),
        /*      onTap: () {
          print(11);
          Application.router.navigateTo(context, url);
        },*/
      ),
    );
  }
}
