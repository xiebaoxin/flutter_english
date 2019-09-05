import 'package:flutter/material.dart';
import '../../components/banner.dart';
import '../../utils/screen_util.dart';
import '../../model/goods.dart';
import '../../model/globle_model.dart';

class DetailsTopArea extends StatelessWidget {
  GoodInfo goodsInfo = null;
  double _width=ScreenUtil.screenWidth;

  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);
    goodsInfo=model.goodsinfo;
//    print(goodsInfo.images);
     return  SwipperBanner(banners:goodsInfo.images,nheight: _width);
        }
  }
