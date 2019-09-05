import 'goods.dart';
class BuyModel{
  String goods_id;
  String goods_num;
  String item_id;
  String action;
  String imgurl;
  GoodInfo goodsinfo;
  double goods_price;
  BuyModel({this.goods_id,this.goods_num,this.item_id,this.goods_price,this.goodsinfo,this.imgurl,this.action="buy_now"});

}