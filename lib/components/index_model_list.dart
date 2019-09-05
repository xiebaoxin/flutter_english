import 'package:flutter/material.dart';
import '../model/model_cell.dart';
import '../routers/application.dart';
import 'dart:core';

class IndexModelList extends StatelessWidget {
  IndexModelList(this.listData);
  final List<ModelCell> listData ;
//  ,this.token String token;


//  IndexModelList({Key key, this.listData}) : super(key: key);

  List<Widget> buildItemList(
    BuildContext context,
  ) {
    int number = listData.length;
    List<Widget> widgetList = new List();
    for (int i = 0; i < number; i++) {
      ModelCell item = listData[i];
      widgetList.add(setItemWidget(context, item));
    }
    return widgetList;
  }

  Widget setItemWidget(BuildContext context, ModelCell cellItem) {
    String txt = cellItem.modName;
    Container itemContainer = new Container(
      child: GestureDetector(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Expanded(
              child: new Container(
                constraints: new BoxConstraints.expand(),
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: cellItem.modtype == '0'
                        ? AssetImage('images/' + cellItem.iconname)
                        : NetworkImage(cellItem.icon),
//                image: new NetworkImage('http://h.hiphotos.baidu.com/zhi6e06f06c.jpg'),
//                  image: AssetImage('images/sysicon/icon_jilu.png'),
                  ),
                ),
              ),
            ),
            Expanded(child: Text(txt))
          ],
        ),
        /*      onTap: () {
           Application.run(context, url);;
        },*/
      ),
    );

    return InkWell(
        onTap: () {
          if (cellItem.modtype == '0') {
            Application.run(context, cellItem.fluUrl);
          } else {
            Application.run(context, "/web",url: cellItem.url,title:txt);
          }
        },
        child: itemContainer);
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        children: buildItemList(context),
      ),
    );
  }
}
