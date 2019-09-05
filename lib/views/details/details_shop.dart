import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/screen_util.dart';
import '../../model/goods.dart';
import '../../model/globle_model.dart';
import '../../globleConfig.dart';

class DetailsShop extends StatefulWidget {
  final GoodInfo goodsInfo;
  DetailsShop(this.goodsInfo);

  @override
  DetailsShopState createState() => new DetailsShopState();
}

class DetailsShopState extends State<DetailsShop> {

  double _width = ScreenUtil.screenWidth;
bool _showweixin=false;
  @override
  Widget build(BuildContext context) {
    if (widget.goodsInfo != null) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            // This ensures that the Card's children are clipped correctly.
              clipBehavior: Clip.antiAlias,
              shape: GlobalConfig.cardBorderRadius, //,
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "images/logo.png",
                              height: 25,
                              width: 25,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            /*Text(
                              int.tryParse(widget.goodsInfo.shopId)>0 ?widget.goodsInfo.shopName:"毕学",
                              style: KfontConstant.defaultStyle,
                            ),*/
                          ],
                        ),
                        Text(int.tryParse(widget.goodsInfo.shopId)>0 ?"":"自营",
                            style: TextStyle(
                              color: Colors.deepOrange,
                            )),
                   /*     widget.goodsInfo.shop.weixin!=''?
                        InkWell(
                          onTap: (){
                            setState(() {
                            _showweixin=true;
                          });},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(int.tryParse(widget.goodsInfo.shopId)>0 ?"":"微信客服",style: KfontConstant.defaultLittleStyle,),
                          ),
                        ):SizedBox(width: 1,),*/

                      ],
                    ),
                 /*   _showweixin?
                    Center(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 50.0),
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              QrImage(
                                data: widget.goodsInfo.shop.weixin,
                                size: 120.0,
                              ),
                            Text("微信扫一扫加我${ widget.goodsInfo.shop.link??""}",style: KfontConstant.defaultLittleStyle,)
                            ],

                          ),
                        )):Divider(),*/
                  ],
                ),
              )));
    } else {
      return Container(
        child: Text('正在加载中......'),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget( oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}