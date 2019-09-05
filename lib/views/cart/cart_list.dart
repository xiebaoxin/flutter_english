import 'package:flutter/material.dart';
import '../../constants/index.dart';
import '../../model.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/globle_model.dart';
import '../../constants/color.dart';
import 'cartItem.dart';

class CartListWidget extends StatelessWidget {
  globleModel model;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<globleModel>(
        builder: (context, child, model) {
          this.model = model;
      if(model.items.isEmpty)
        return Text("空空如也");
      else
      return Expanded(
          child:  ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: model.itemsCount,
          itemExtent: 93,
          itemBuilder: (BuildContext context, int index) {
            CartItemModel item = model.items[index];
            return Dismissible(
              resizeDuration: Duration(milliseconds: 100),
              key: Key(item.productName),
              onDismissed: (direction) {
                model.removeItem(index);
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("${item.productName}   成功移除"),
                  backgroundColor: KColorConstant.themeColor,
                  duration: Duration(seconds: 1),
                ));
              },
              background: Container(color: KColorConstant.themeColor),
              child: CartItemWidget(model.items[index],
             /*     addCount: (int i) {
                    model.addCount(i);
                  },
                  downCount: (int i) {
                  model.downCount(i);
                  },
                  index: index,
                  switchChaned: (i){ model.switchSelect(i);}*/
                  addCount: _addCount,
                  downCount: _downCount,
                  index: index,
                  switchChaned: _switchChanged
                  ),
            );
          },

      ));
    }) ;
  }

  _switchChanged(int i) {
    model.switchSelect(i);
  }

  _addCount(int i) {
    model.addCount(i);
  }

  _downCount(int i) {
    model.downCount(i);
  }
}
