import 'package:flutter/material.dart';
import '../../constants/index.dart';
import 'cart_list.dart';
import 'cartbottom.dart';
import '../../model/globle_model.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CartState();
}

class CartState extends State<Cart> {
  @override
  void initState() {
     super.initState();
  }
  @override
  void dispose() {
    //重新整理更新购物车
    final model = globleModel().of(context);
    model.freshCartItem(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('购物车'),
          centerTitle: true,
          leading: SizedBox(width: 5,),
        ),
//          backgroundColor: Color(0xFF5FB419),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CartListWidget(),
            CartBottomWidget()
          ],
        ));
  }


  Widget buildtopbar(String title) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      alignment: Alignment.center,
      height: statusBarHeight + Klength.topBarHeight,
      decoration: BoxDecoration(
          border:
          Border(bottom: BorderSide(color: Color(0xFFe1e1e1), width: 1))),
      child:
      Text(title, style: TextStyle(color: Color(0xFF313131), fontSize: 18)),
    );
  }
}

