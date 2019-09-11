import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/loading_gif.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';
import 'video_detail_page.dart';
import '../routers/application.dart';
import '../utils/screen_util.dart';

class GoodsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final ValueChanged<String> onItemTap;
  final VoidCallback getNextPage;
  GoodsListWidget(this.list, {this.onItemTap,this.getNextPage});
  @override
  Widget build(BuildContext context) {
    return list.length == 0
        ? Center(
            child: Text("没有找到内容"),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: list.length,
            itemExtent: 105,
            itemBuilder: (BuildContext context, int i) {
              Map<String, dynamic> item = list[i];
              if((i+3)==list.length){
                getNextPage();
              }
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  color: KColorConstant.searchAppBarBgColor,
                  padding: EdgeInsets.all(10),
                  child:
                  InkWell(
                    onTap: (){
                       Application.goodsDetail(context, item['goods_id'],vdtype: item['videotype'],item: item);
                      },
                    child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                          errorWidget: (context, url, error) =>Container(
                            height: 75,
                            width: 75,
                            child:  Image.asset(
                              'images/logo_b.png',height: 30,width: 30,fit: BoxFit.fill,),
                          ),
                          placeholder: (context, url) =>  Loading(),
                          imageUrl:  item['pic_url'],//"http://testapp.hukabao.com:8008/public/upload/goods/thumb/236/goods_thumb_236_0_400_400.png",//
                          width: 80,
                          height:80,
                          fit: BoxFit.fill,
                        ),

                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                      style: KfontConstant.defaultSubStyle
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '￥${item['shop_price']}',
                                          style: KfontConstant.defaultSubStyle
                                      ),
                                    ],
                                  ),
                                    Text(
                              '5人评价 好评率80%',
                              style:
                                  KfontConstant.searchResultItemCommentCountStyle,
                            ),

                                ],
                              ),
                            ))
                      ],
                    ) ,
                  )
                 ,
                ),
              );
            },
          );
  }
}
