import 'package:flutter/material.dart';
import '../../constants/index.dart';
import '../../model.dart';
import '../../constants/color.dart';
import '../../utils/screen_util.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel data;
  final int index;
  final Function(int i) switchChaned;
  final Function(int i) addCount;
  final Function(int i) downCount;

  CartItemWidget(this.data,
      {this.switchChaned, this.index, this.addCount, this.downCount});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenUtil().L(15),
          bottom: ScreenUtil().L(4),
          right: ScreenUtil().L(10),
          left: ScreenUtil().L(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
              onTap: () => switchChaned(index),
              child: Icon(
                data.isSelected
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: KColorConstant.themeColor,
              )),
          Container(
            margin: EdgeInsets.only(
                left: 8, right:8),
            width: 60,
            height:60,
          
            child: Image.network(data.imageUrl, fit: BoxFit.fill),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(data.productName),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '￥${data.price}',
                          style: TextStyle(
                              fontSize: 14, color: KColorConstant.priceColor),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => data.count>1?downCount(index):false,
                              child: Container(
                                width: 25,
                                height: 20,
                                decoration:
                                    BoxDecoration(border: _getRemoveBtBorder()),
                                child: Icon(Icons.remove,size: 10,
                                    color: _getRemovebuttonColor()),
                              ),
                            ),
                            Container(
                                alignment: Alignment.center,
                                width: 30,
                                height: 20,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: KColorConstant.cartItemCountTxtColor,
                                        width: 1)),
                                child: Text(
                                  data.count.toString(),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: KColorConstant.cartItemCountTxtColor),
                                )),
                            GestureDetector(
                              onTap: () => data.count<data.buyLimit ? addCount(index):false,
                              child: Container(
                                alignment: Alignment.center,
                                width: 25,
                                height:20,
                                decoration:
                                    BoxDecoration(border: _getAddBtBorder()),
                                child: Icon(Icons.add,size: 10, color: _getAddbuttonColor()),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Color _getRemovebuttonColor() {
    return data.count > 1
        ? KColorConstant.cartItemChangenumBtColor
        : KColorConstant.cartDisableColor;
  }

  Border _getRemoveBtBorder() {
    return Border(
        bottom: BorderSide(width: 1, color: _getRemovebuttonColor()),
        top: BorderSide(width: 1, color: _getRemovebuttonColor()),
        left: BorderSide(width: 1, color: _getRemovebuttonColor()));
  }

  Border _getAddBtBorder() {
    return Border(
        bottom: BorderSide(width: 1, color: _getAddbuttonColor()),
        top: BorderSide(width: 1, color: _getAddbuttonColor()),
        right: BorderSide(width: 1, color: _getAddbuttonColor()));
  }

  _getAddbuttonColor() {
    return data.count >= data.buyLimit
        ? KColorConstant.cartDisableColor
        : KColorConstant.cartItemCountTxtColor;
  }
}
