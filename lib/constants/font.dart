import 'package:flutter/material.dart';
import '../utils/screen_util.dart';
import 'color.dart';
class KfontConstant {
  static TextStyle bigfontSize = TextStyle(
    fontSize: 14,
    color: KColorConstant.categoryDefaultColor,
    decoration: TextDecoration.none,
  );

  static TextStyle defaultStyle = TextStyle(
    fontSize: 14,
    color: KColorConstant.categoryDefaultColor,
    decoration: TextDecoration.none,
  );

  static TextStyle defaultSubStyle = TextStyle(
    fontSize:10,
    color: Colors.black45,
    decoration: TextDecoration.none,
  );

  static TextStyle defaultPriceStyle = TextStyle(
    fontSize:10,
    color: KColorConstant.priceColor,
    decoration: TextDecoration.none,
  );


  static TextStyle fLoorTitleStyle = TextStyle(
    fontSize:14,
    color: KColorConstant.floorTitleColor,
  );
  static TextStyle pinweiCorverSubtitleStyle = TextStyle(
    fontSize: 10,
    color: KColorConstant.pinweicorverSubtitleColor,
  );

  static TextStyle cartBottomTotalPriceStyle = TextStyle(fontSize: 12,color: KColorConstant.priceColor);


  static TextStyle searchResultItemCommentCountStyle = TextStyle(
                                fontSize: 12, color: Color(0xFF999999));
                          
}
