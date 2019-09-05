import 'package:flutter/material.dart';
import '../../utils/screen_util.dart';
import '../../model/goods.dart';
import '../../model/globle_model.dart';
import '../../globleConfig.dart';

class DetailsExplain extends StatelessWidget {
  final GoodInfo goodsInfo ;
  DetailsExplain(this.goodsInfo);
  double _width=ScreenUtil.screenWidth;

  @override
  Widget build(BuildContext context) {
    if (this.goodsInfo != null) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
    child: Card(
    // This ensures that the Card's children are clipped correctly.
    clipBehavior: Clip.antiAlias,
    shape: GlobalConfig.cardBorderRadius, //,
    elevation: 5.0,
    child: Padding(
    padding: const EdgeInsets.all(15.0),
    child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            goodsName(this.goodsInfo.goodsName),
            goodsPrice(this.goodsInfo.presentPrice, this.goodsInfo.oriPrice),
            goodsNumber(this.goodsInfo),
          ],
        ),))
      );
    } else {
      return Container(
        child: Text('正在加载中......'),
      );
    }
  }
  /// 商品详情页的名称
  Widget goodsName(name) {
    return Container(
      width: _width,
      padding: EdgeInsets.only(left: 15),
      child: Text(
        name,
        style: KfontConstant.defaultStyle,
      ),
    );
  }

  /// 商品详情页的编号
  Widget goodsNumber(GoodInfo goods) {
    return Container(
      width: _width,
      padding: EdgeInsets.only(left: 15),
      margin: EdgeInsets.only(top: 8),
      child: Text(
        '编号：${goods.goodsSerialNumber.toString()},库存：${goods.amount.toString()}',
        style: TextStyle(
          fontSize: ScreenUtil().setSp(14),
          color: Colors.black12,
        ),
      ),
    );
  }

  /// 商品详情页的价格页面
  Widget goodsPrice(oldPrice, newPrice) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            '¥${oldPrice}',
            style: KfontConstant.defaultPriceStyle,
          ),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: RichText(
              text: TextSpan(
                  text: '市场价：',
                  style: TextStyle(color: Colors.black45),
                  children: <TextSpan>[
                    TextSpan(
                      text: '¥${newPrice}',
                      style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black12),
                    ),
                  ]),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 15, top: 10),
    );
  }
}
