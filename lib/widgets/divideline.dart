import 'package:flutter/material.dart';
import '../constants/index.dart';
import '../utils/screen_util.dart';

class DivideLineWidget extends StatelessWidget{
  final double width;
  DivideLineWidget({Key key,this.width}):super(key:key);
  @override
    Widget build(BuildContext context) {
      return Container(
//          height: ScreenUtil().H(width),
          alignment: Alignment.center,
          color: KColorConstant.divideLineColor,
          );
    }
}