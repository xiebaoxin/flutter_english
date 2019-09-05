import 'package:flutter/material.dart';
import '../../model/goods.dart';
import '../../utils/screen_util.dart';

class DetailsBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GoodInfo goodsInfo = null;

    var goodsCount = 3;//val.allGoodsCount; //购物车中数量
    return Container(
      width: ScreenUtil.screenWidth,
      height: ScreenUtil().L(60),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Stack(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: ScreenUtil().L(80),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.shopping_cart,
                    size: 35,
                    color: Colors.red,
                  ),
                ),
              ),

               Positioned(
                    top: 0,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${goodsCount}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(12),),
                      ),
                    ),
                  )

            ],
          ),
          Expanded(child:InkWell(
            onTap: () async {
              /*  await Provide.value<CartProvide>(context)
                  .save(goodsId, goodsName, count, price, images);*/
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.green,
              child: Text(
                '加入购物车',
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(16)),
              ),
//              width: ScreenUtil().L(120),
//              height: ScreenUtil().L(80),
            ),
          ) )
          ,
          Expanded(child:  InkWell(
            onTap: () async {
              /*  await Provide.value<CartProvide>(context).remove();*/
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: Text(
                '立即购买',
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(16)),
              ),
//              width: ScreenUtil().L(320),
//              height: ScreenUtil().L(80),
            ),
          )
         ),
        ],
      ),
    );
  }
}
