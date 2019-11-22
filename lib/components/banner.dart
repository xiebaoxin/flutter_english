import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/screen_util.dart';
import '../components/loading_gif.dart';
import '../routers/application.dart';
import '../globleConfig.dart';

class RectSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color color;

  ///Size of the rect when activate
  final Size activeSize;

  ///Size of the rect
  final Size size;

  /// Space between rects
  final double space;

  final Key key;

  const RectSwiperPaginationBuilder(
      {this.activeColor,
        this.color,
        this.key,
        this.size: const Size(10.0, 2.0),
        this.activeSize: const Size(10.0, 2.0),
        this.space: 3.0});

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    List<Widget> list = [];

    int itemCount = config.itemCount;
    int activeIndex = config.activeIndex;

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      Size size = active ? this.activeSize : this.size;
      list.add(Container(
        width: size.width,
        height: size.height,
        color: active ? activeColor : color,
        key: Key("pagination_$i"),
        margin: EdgeInsets.all(space),
      ));
    }

    return new Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: list,
    );
  }
}

class SwipperBanner extends StatelessWidget {
  final List<String> banners;
  final List<String> urllinks;
  final bool potype;
  final double nheight;
  final int defindex;
  SwipperBanner({this.banners,this.nheight=0.0,this.defindex=0,this.urllinks,this.potype=false});
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height =this.nheight ?? ScreenUtil().H(115);
    return Container(
      width: width,
      height: height,
      child: Swiper(
        itemBuilder: (BuildContext context, index) {
          return  Container(
            margin: const EdgeInsets.all(8),
            decoration: new BoxDecoration(
              color: Colors.white,
          borderRadius: BorderRadius.all(
          Radius.circular(10.0),),
              image: new DecorationImage(image: new NetworkImage( banners[index]), fit: BoxFit.cover),
//              shape: BoxShape.circle,
            ),
          );/*CachedNetworkImage(
            errorWidget: (context, url, error) =>Container(
              height: height,
              width: width,
              child: Center(
                child:    Image.asset(
                  'images/logo-灰.png',),
              ),
            ),
            placeholder: (context, url) =>  Loading(),
            imageUrl:  banners[index],
            height: height,
            width: width,
            fit: BoxFit.fill,
          )*/;

        },
        itemCount: banners.length,
        //viewportFraction: 0.9,
        pagination:  SwiperPagination(
            alignment:potype?Alignment.bottomRight: Alignment.bottomCenter,
            builder: potype?FractionPaginationBuilder(
                color: Colors.grey,
                activeColor: Colors.redAccent,
                activeFontSize: 20
            ):DotSwiperPaginationBuilder(
//              RectSwiperPaginationBuilder
              color: Color(0xFF999999),
              activeColor: Colors.white,
//                size: Size(5.0, 2),
//                activeSize: Size(5, 5)
            )),


        scrollDirection: Axis.horizontal,
        autoplay: true,
        index: defindex,
        onTap: (index){
          print('点击了第$index个');

        }  ,
      ),
    );
  }

  Widget build11(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height =this.nheight ?? ScreenUtil().H(115);
    return Container(
      width: width,
      height: height,
      child: Swiper(
        itemBuilder: (BuildContext context, index) {
          return  CachedNetworkImage(
            errorWidget: (context, url, error) =>Container(
              height: height,
              width: width,
              child: Center(
                child:    Image.asset(
                  'images/logo-灰.png',),
              ),
            ),
            placeholder: (context, url) =>  Loading(),
            imageUrl:  banners[index],
            height: height,
            width: width,
            fit: BoxFit.fill,
          );
          /* return Image.network(
            banners[index],
            width: width,
            height: height,
          );*/
        },
        itemCount: banners.length,
        //viewportFraction: 0.9,
          pagination:  SwiperPagination(
            alignment:potype?Alignment.bottomRight: Alignment.bottomCenter,
            builder: potype?FractionPaginationBuilder(
                color: Colors.grey,
                activeColor: Colors.redAccent,
                activeFontSize: 20
            ):DotSwiperPaginationBuilder(
//              RectSwiperPaginationBuilder
                color: Color(0xFF999999),
                activeColor: Colors.white,
//                size: Size(5.0, 2),
//                activeSize: Size(5, 5)
            )),


        scrollDirection: Axis.horizontal,
        autoplay: true,
        index: defindex,
        onTap: (index){
          print('点击了第$index个');

        }  ,
      ),
    );
  }
}
