import 'package:flutter/material.dart';
import '../utils/screen_util.dart';
import 'color.dart';
class KfontConstant {
  static TextStyle bigfontSize = TextStyle(
    fontSize: ScreenUtil().setSp(22),
    color: KColorConstant.categoryDefaultColor,
    decoration: TextDecoration.none,
  );

  static TextStyle defaultStyle = TextStyle(
    fontSize: ScreenUtil().setSp(20,true),
    color: KColorConstant.categoryDefaultColor,
    decoration: TextDecoration.none,
  );

  static TextStyle defaultSubStyle = TextStyle(
    fontSize:ScreenUtil().setSp(18,true),
    color: Colors.black45,
    decoration: TextDecoration.none,
  );

  static TextStyle defaultPriceStyle = TextStyle(
    fontSize:ScreenUtil().setSp(18,true),
    color: KColorConstant.priceColor,
    decoration: TextDecoration.none,
  );


  static TextStyle fLoorTitleStyle = TextStyle(
    fontSize: ScreenUtil().setSp(20),
    color: KColorConstant.floorTitleColor,
  );
  static TextStyle pinweiCorverSubtitleStyle = TextStyle(
    fontSize: ScreenUtil().setSp(16),
    color: KColorConstant.pinweicorverSubtitleColor,
  );

  static TextStyle cartBottomTotalPriceStyle = TextStyle(fontSize: ScreenUtil().setSp(20),color: KColorConstant.priceColor);


  static TextStyle searchResultItemCommentCountStyle = TextStyle(
                                fontSize: ScreenUtil().setSp(12), color: Color(0xFF999999));
                          
}
