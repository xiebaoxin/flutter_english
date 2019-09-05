import 'package:flutter/material.dart';
import './utils/screen_util.dart';
export  './constants/index.dart';

class GlobalConfig {
  static final String appName = '护卡宝';
  static final String agentid='0';
  static final  bool dark = true;
//  static ThemeData themeData = new ThemeData.dark();
  static final  Color mainColor = Colors.red;
  static Color searchBackgroundColor = Colors.white10;
  static Color cardBackgroundColor = new Color(0xFF222222);
  static Color fontColor = Colors.white30;

  static final  String server='http://123.207.127.127/';
  static final  String webbase='http://123.207.127.127/Appi/WxAuth/';
  static final  String base='http://123.207.127.127/Appi/';
  static final String wxAppId='wx002f0547fa2ff202';

  static final double cardWidth =ScreenUtil().L(650);//卡片统一宽度
  static final double cardCircularWidth = 8;//卡片圆角高度

  static final ShapeBorder cardBorderRadius = const RoundedRectangleBorder(
    side: BorderSide(color: Colors.white12),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
    ),
  );
}