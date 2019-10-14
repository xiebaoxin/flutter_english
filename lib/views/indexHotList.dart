import 'package:flutter/material.dart';
import '../globleConfig.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/loading_gif.dart';
import '../routers/application.dart';

class IndexHotListFloor extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final int cnum;
  IndexHotListFloor(this.data, {this.cnum = 3});
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth,
      color: Colors.white,
      padding: EdgeInsets.only(top: 7, bottom: 10, left: 7, right: 7),
      child: _build(deviceWidth, context),
    );
  }

  Widget _build(double deviceWidth, BuildContext context) {
    var bgColor = Color(0xFFFFFFFF); // string2Color(i.bgColor);
    double itemWidth = (deviceWidth / cnum) - 20; // deviceWidth * 100 / 360;
    ShapeBorder _shape = GlobalConfig.cardBorderRadius;
  /*  return GridView.count(
      crossAxisCount: cnum,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 7 / 9,
      children: data.map((item) {
        return Container(
            child: InkWell(
                onTap: () {
                  Application.goodsDetail(context, item['goods_id']);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: itemWidth + 3,
                          height: itemWidth + 3,
                          child: Card(
                              // This ensures that the Card's children are clipped correctly.
                              clipBehavior: Clip.antiAlias,
                              shape: _shape, //,
//                          elevation: 2.0,
                              child: CachedNetworkImage(
                                errorWidget: (context, url, error) => Container(
                                  width: itemWidth,
                                  height: itemWidth,
                                  child: Image.asset(
                                    'images/logo.png',
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                placeholder: (context, url) => Loading(),
                                imageUrl: item[
                                    'pic_url'], //"http://testapp.hukabao.com:8008/public/upload/goods/thumb/236/goods_thumb_236_0_400_400.png",//
                                width: itemWidth,
                                height: itemWidth,
                                fit: BoxFit.fill,
                              )),
                        ),
                        Expanded(
                            child: Text(
                          item['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        )),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '￥${item['shop_price']}',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${item['videotype']}',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                )));
      }).toList(),
    );*/

    List<Widget> listWidgets = data.map((i) {
      return Container(
          width: itemWidth,
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.only(top: 5, left: 5, bottom: 7),
          color: bgColor,
          child: InkWell(
            onTap: () {
              Application.goodsDetail(context, i['goods_id'],vdtype: i['videotype'],item: i);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            Container(
            width: itemWidth + 3,
              height: itemWidth + 3,
              child: Card(
                // This ensures that the Card's children are clipped correctly.
                clipBehavior: Clip.antiAlias,
                shape: _shape, //,
//                          elevation: 2.0,
                child: CachedNetworkImage(
                    errorWidget: (context, url, error) => Container(
                      width: itemWidth,
                      height: itemWidth,
                      child: Image.asset(
                        'images/logo_b.png',
                        height: 20,
                        width:20,
                        fit: BoxFit.fill,
                      ),
                    ),
                    placeholder: (context, url) => Loading(),
                    imageUrl: i[
                        'pic_url'], //"http://testapp.hukabao.com:8008/public/upload/goods/thumb/236/goods_thumb_236_0_400_400.png",//
                    width: itemWidth,
                    height: itemWidth,
                    fit: BoxFit.fill,
                  )),
                ),
                Text(
                  i['title'],
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: KfontConstant.defaultSubStyle,
                ),

              ],
            ),
          ));
    }).toList();

    return Center(
      child: Wrap(
        spacing: 3,
        children: listWidgets,
      ),
    );
  }
}
