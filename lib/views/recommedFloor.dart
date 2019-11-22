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
          child: InkWell(
            onTap: () {
              Application.goodsDetail(context, i['goods_id'],
                  vdtype: i['videotype'], item: i);
            },
            child: Container(
              width: 88,
              height: 88,
            padding: EdgeInsets.all(2),
            decoration: new BoxDecoration(
            color:bgColor,
            border:  Border(right: BorderSide(color:KColorConstant.searchBarBgColor,width: 1.0)),
            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 88,
                  height: 88,
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child:  CachedNetworkImage(
                            errorWidget: (context, url, error) => Container(
                              width: 88,
                              height:88,
                              child: Image.asset(
                                'images/logo_b.png',
                                height: 88,
                                width: 88,
                                fit: BoxFit.fill,
                              ),
                            ),
                            placeholder: (context, url) => Loading(),
                            imageUrl: i[
                            'pic_url'], //"http://testapp.hukabao.com:8008/public/upload/goods/thumb/236/goods_thumb_236_0_400_400.png",//
                            width: 88,
                            height: 88,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:5.0,right:5),
                  child: Text(
                    i['title'],
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: KfontConstant.defaultSubStyle,
                  ),
                ),

              ],
            ),)
          ));
    }).toList();

    return Padding(
        padding: const EdgeInsets.only(top:8.0),
    child: Container(
        width: deviceWidth,
        color:bgColor,
        height: 135,
        child: ListView(
            children: listWidgets,
            scrollDirection: Axis.horizontal,
          ),
        ));
  }

}
