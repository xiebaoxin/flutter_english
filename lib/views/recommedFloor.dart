import 'package:flutter/material.dart';
import '../globleConfig.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/loading_gif.dart';
import '../routers/application.dart';

class RecommendFloor extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  RecommendFloor(this.data);
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    var bgColor = Color(0xFFFFFFFF); // string2Color(i.bgColor);
    ShapeBorder _shape = GlobalConfig.cardBorderRadius;

    List<Widget> listWidgets = data.map((i) {
      return Container(
          width: 100,
          height: 100,
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.all(5),
          child: InkWell(
            onTap: () {
              Application.goodsDetail(context, i['goods_id'],
                  vdtype: i['videotype'], item: i);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child:  CachedNetworkImage(
                            errorWidget: (context, url, error) => Container(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                'images/logo_b.png',
                                height: 20,
                                width: 20,
                                fit: BoxFit.fill,
                              ),
                            ),
                            placeholder: (context, url) => Loading(),
                            imageUrl: i[
                            'pic_url'], //"http://testapp.hukabao.com:8008/public/upload/goods/thumb/236/goods_thumb_236_0_400_400.png",//
                            width: 80,
                            height: 80,
                            fit: BoxFit.fill,
                          ),
                  ),
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

    return Container(
        width: deviceWidth,
        color:bgColor,
        height: 165,
        child: ListView(
          children: listWidgets,
          scrollDirection: Axis.horizontal,
        ));
  }

}
