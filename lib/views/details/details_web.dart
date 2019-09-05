import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../model/goods.dart';

class DetailsWeb extends StatelessWidget {
  final GoodInfo goodsinfo;
  DetailsWeb(this.goodsinfo);

  @override
  Widget build(BuildContext context) {
    var goodsDetails = this.goodsinfo.content;
//    print(goodsDetails);
        bool isLeft =true;
        if (isLeft) {
          return Html(data: goodsDetails);
        } else {
          return Container(
            child: Text('暂时没有数据'),
          );
        };
  }
}
