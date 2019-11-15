import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scoped_model/scoped_model.dart';
import '../components/loading_gif.dart';
import '../utils/HttpUtils.dart';
import '../components/animation_text_component.dart';
import '../components/sliver_appbar_delegate.dart';
import '../utils/screen_util.dart';
import '../utils/DialogUtils.dart';
import '../utils/dataUtils.dart';
import '../routers/application.dart';
import '../model/globle_model.dart';
import '../model/buy_model.dart';
import '../model/goods.dart';
import '../components/tag_component.dart';
import '../components/video_detail_item_component.dart';
import 'package:video_player/video_player.dart';
import '../video/chewie_list_item.dart';
import '../views/cart/cart.dart';
import 'buygoods_page.dart';
import 'addcartItem.dart';
import '../video/tx_video_player.dart';
import '../video/player.dart';
import 'player/full_player_page.dart';
import 'player/player_tool.dart';
import '../model/song.dart';

class VideoDetailPage extends StatefulWidget {
  int videoId;
  String type;
  String vdurl;

  VideoDetailPage(this.videoId,{this.type='',this.vdurl=''});

  @override
  State<StatefulWidget> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  var _futureBuilderFuture;
  Map<String, dynamic> _goodsinfo;
  bool _favorate=false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //snapshot就是_calculation在时间轴上执行过程的状态快照
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return new Text(
                      'Press button to start'); //如果_calculation未执行则提示：请点击开始
                case ConnectionState.waiting:
                  return Loading();
                default: //如果_calculation执行完毕
                  if (snapshot.hasError) //若_calculation执行出现异常
                    return new Text('Error: ${snapshot.error}');
                  else {
                    if (snapshot.hasData) {
                      Map<String, dynamic> fdata=snapshot.data;
                      if(fdata['goods'] !=null) {
                        _goodsinfo = fdata['goods'];
                        return    Material(
                            child:  Scaffold(
                            body:NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              // 标题
                              SliverAppBar(
                                elevation: 0.0,
                                floating: false,
                                pinned: true,
                                expandedHeight: ScreenUtil.screenWidth * 1.05,
//                    DeviceUtil.getScreenSize(context).width * 1.05,
                                flexibleSpace: FlexibleSpaceBar(
                                  title: Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Theme
                                        .of(context)
                                        .primaryColor,
                                    period: Duration(milliseconds: 6000),
                                    child: Text(
                                      _goodsinfo['goods_name'],
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  centerTitle: true,
                                  background: HeaderBackGroundCover(
                                    _goodsinfo, vdurl: widget.vdurl,
                                    type: widget.type,),
                                ),
                                actions: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.favorite_border,
                                      color: _favorate ? Color(0xFFFF9933) : Colors
                                          .white12,),
                                    tooltip: '喜欢它',
                                    onPressed: () {
                                      Application().checklogin(context, () {
                                        _favorate
                                            ? cancel_favorite()
                                            : add_favorite();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              // Tab

                            ];
                          },
                          body: VideoDetailContent(fdata, _isbuyed),
                            ),
                            /*  floatingActionButton: FloatingActionButton(
                                backgroundColor:_isbuyed?Colors.green: Colors.deepOrange,
                                child: Icon(_isbuyed ?Icons.lock_open:Icons.lock),
                                onPressed: ()async{
                                  setState(() {
                                    _action = "0";
                                  });
                                  if(!_isbuyed)
                                  await Application().checklogin(context, () {
                                    GoodInfo _mgoodsinfo = GoodInfo.fromJson(fdata);
                                    BuyModel param = BuyModel(
                                        goodsinfo: _mgoodsinfo,
                                        goods_id: _mgoodsinfo.goodsId.toString(),
                                        goods_num: "1",
                                        imgurl: _mgoodsinfo.comPic,
                                        goods_price:
                                        double.tryParse(_mgoodsinfo.presentPrice));

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
//                            builder: (context) => BuyPage(param),
                                          builder: (context) => GoodsBuyPage(param),
                                        ));
                                  });

                                },
                              ),*/
                            )
                        );
                      }
                      else
                        return Text('Error: ${fdata['msg']}');
                    } else {
                      return Center(child: Container(child: Loading()) //Text("加载中"),
                      );
                    }
                  }
              }
            },
          );

//          bottomNavigationBar:buildbottomsheet(context,_isloaddate)

  }

  bool _isload=false;
  Map<String, dynamic> _isloaddate={};
  Future<Map<String, dynamic>> _getVideo() async {
    Map<String, String> params = {"id": widget.videoId.toString()};
    if(!_isload){
      _isloaddate= await HttpUtils.dioappi('Shop/goodsInfo', params);
      await isBuyedGoods();
      await isCollectGoods();
      _isload=true;
    }
    return _isloaddate;

  }

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _getVideo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isload=null;
    _goodsinfo=null;
    _isloaddate=null;
  }

  void isCollectGoods()async{
    Map<String, String> params = {
      "goods_id":widget.videoId.toString()
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/isCollectGoods', params,
        withToken: true, context: context);

    if (response['status'] == 1) {
      setState(() {
        _favorate=true;
      });

    }
  }

  bool _isbuyed=false;
  void isBuyedGoods()async{
    _isbuyed= await DataUtils.isBuyedGoods(widget.videoId);
  }

  add_favorite() async{
    Map<String, String> params = {
      "goods_id":widget.videoId.toString()
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/collect_goods', params,
        withToken: true, context: context);

    if (response['status'].toString() == '1'|| response['status'].toString() =='-3') {
      setState(() {
        _favorate=true;
      });

    }

  }
  cancel_favorite() async{
    Map<String, String> params = {
      "goods_id":widget.videoId.toString()
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/cancel_collect', params,
        withToken: true, context: context);

    if (response['status'].toString() == '1') {
      setState(() {
        _favorate=false;
      });
    }

  }

  String _action="1";
  Widget buildbottomsheet(context, var goodsinfo) {
    return Container(
      width: ScreenUtil.screenWidth,
      height: ScreenUtil().L(60),
      color: Colors.white,
      child: !_isbuyed ?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              Application().checklogin(context, () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>  Cart()),
                );
              });
            },
            child:  Stack(
              children: <Widget>[
                Container(
                  width: ScreenUtil().L(80),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.shopping_cart,
                    size: 35,
                    color: Colors.red,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 10,
                  child:
                  ScopedModelDescendant<globleModel>(
                      builder: (context, child, model) {
                        return  Container(
                          padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${model.totalCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(12),),
                          ),
                        );}),
                )

              ],
            ),
          ),
          Expanded(child:InkWell(
            onTap: () async {
              setState(() {
                _action = "1";
              });
              shaoaddform(goodsinfo);
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.green,
              child: Text(
                '加入购物车',
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(16)),
              ),
            ),
          ) )
          ,
          Expanded(child:  InkWell(
            onTap: () async {
              setState(() {
                _action = "0";
              });
              shaoaddform(goodsinfo);
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: Text(
                '立即购买',
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(16)),
              ),
            ),
          )
          ),
        ],
      )
          :
      Text("已购买"),

    );
  }

  void shaoaddform(Map<String, dynamic>  goodsinfo) {
    GoodInfo _mgoodsinfo = GoodInfo.fromJson(goodsinfo);
    final model = globleModel().of(context);
    model.setgoodInfo(_mgoodsinfo);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AddCartItemWidget(
                _mgoodsinfo,
                action: _action,
              ),
            ),
          );
        });
  }


}


/**
 * 头部
 */
class HeaderBackGroundCover extends StatelessWidget {
  final Map<String, dynamic> video;
  String type;
  String vdurl;
  HeaderBackGroundCover(this.video,{this.type='',this.vdurl=''});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          // 底图
          Positioned.fill(
              child: CachedNetworkImage(
                placeholder: (context, url) => Loading(),
                errorWidget: (context, url, error) =>Container(
                    height: 75,
                    width: 75,
                    child:
                    Image.asset(
                      'images/logo_b.png',)),
                imageUrl: video['original_img'],
                width: 80,
                height: 80,
                fit: BoxFit.fill,
              )),
          // 毛玻璃
          Positioned(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withAlpha(60)),
                ),
              )),
          // 内容
          Positioned(
              left: 0.0,
              top: 60.0,
              right: 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    /*   width: 200.0,*/
                    height: 290.0,
                    margin: EdgeInsets.only(left: 10.0),
                    child: HeroImageComponent(
                      vdid: video['goods_id'].toString(),
                      type: type,
                      url:video['original_img'],
                      /*  imageWidth: 200.0,*/
                      imageHeight: 300.0,
                    ),
                    decoration: BoxDecoration(boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.black.withAlpha(50),
                          offset: Offset(0.0, 2.0),
                          blurRadius: 6.0),
                      BoxShadow(
                          color: Colors.black.withAlpha(20),
                          offset: Offset(0.0, 3.0),
                          blurRadius: 8.0)
                    ]),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

class VideoDetailContent extends StatelessWidget {
  final Map<String, dynamic> video;
  final bool isbuyed;
  VideoDetailContent(this.video,this.isbuyed);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> videoinfo = video['goods'];
    List<Map<String, dynamic>> retvdlistinfo = List();

    if (video['data']['goods_videos_list']!=null) {
      video['data']['goods_videos_list'].forEach((ele) {
        if (ele.isNotEmpty) {
          retvdlistinfo.add(ele);
        }
      });
    }

    if(isbuyed)
      videoinfo['vd_level']=0;

    return  ListView.builder(
          itemCount: retvdlistinfo.length,
          itemExtent: 38,
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> item = retvdlistinfo[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                  title: Text("${(index+1).toString()}:${item['video_name']??"集"}",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color:(videoinfo['vd_level']>0 && videoinfo['vd_level']<(index+1))? Colors.black26: Colors.black54)),
                  onTap:() async{
                    if( videoinfo['vd_level']>0 && videoinfo['vd_level']<(index+1)){
                      if (await DialogUtils().showMyDialog(context, '需要购买才能收听或观看，是否去购买?')) {
                        Application().checklogin(context, () {
                          Navigator.pop(context);
                          GoodInfo _mgoodsinfo = GoodInfo.fromJson(video);
                          BuyModel param = BuyModel(
                              goodsinfo: _mgoodsinfo,
                              goods_id: _mgoodsinfo.goodsId.toString(),
                              goods_num: "1",
                              imgurl: _mgoodsinfo.comPic,
                              goods_price:
                              double.tryParse(_mgoodsinfo.presentPrice));

                          Navigator.push(
                              context,
                              MaterialPageRoute(
//                            builder: (context) => BuyPage(param),
                                builder: (context) => GoodsBuyPage(param),
                              ));

                        });
                      }
                    }
                    else{
                      if(videoinfo['videotype']=='web'){
                        Application.run(context, "/web",url: item['video_url'],title: item['video_name'],withToken: false);

                      }else if(videoinfo['videotype']=='mp4'){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => xiePlayer(url:item['video_url'],type: videoinfo['videotype'],video: item,)
                          ),
                        );
                      }else{
                        await DataUtils.getmp3txt(item['video_id'],context: context).then((txlist) {

                          PlayerTools.instance.setSong(Song(
                              id:item['video_id'],
                              vdlist:retvdlistinfo,
                              url: item['video_url'], video: item, info: videoinfo,txtlist: txlist,preid: index>0 ? retvdlistinfo[index-1]['video_id']:0,nextid:index<retvdlistinfo.length? retvdlistinfo[index+1]['video_id']:0));

                          Navigator.pushReplacement(context, PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (BuildContext context, _, __) {
                                return FullPlayerPage();
                              },
                              transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                      begin: Offset(0.0, 1.0),
                                      end:Offset(0.0, 0.0)
                                  ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.fastOutSlowIn
                                  )),
                                  child: child,
                                );
                              }
                          ));
                        });
                      }

//                    await globleModel().setVideoModel(item['video_url'], item, videoinfo);
                      /*    Navigator.push(
                     context,
                     MaterialPageRoute(
//                      builder: (context) =>videoinfo['videotype']=='mp4'? xiePlayer(url:item['video_url'],type: videoinfo['videotype'],video: item,):AudioPlayerWuthTxt(url: item['video_url'],video: item,)//VideoDetailPage(videoinfo['goods_id'],vdurl:item['video_url'].toString(),type:videoinfo['videotype'] ,),
                         builder: (context) =>videoinfo['videotype']=='mp4'? xiePlayer(url:item['video_url'],type: videoinfo['videotype'],video: item,):FullPlayerPage(url: item['video_url'],video: item,info:videoinfo ,)//VideoDetailPage(videoinfo['goods_id'],vdurl:item['video_url'].toString(),type:videoinfo['videotype'] ,),

                     ),
                   );*/
                    }

                  }
              ),
            );
          },
        );

  }
}

class HeroImageComponent extends StatelessWidget {
  final String vdid;
  final String type,url;
  final double imageWidth, imageHeight;

  const HeroImageComponent({
    @required this.vdid,
    this.type='',
    this.url='',
    this.imageWidth = 200.0,
    this.imageHeight = 400.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget mwt= CachedNetworkImage(
      placeholder: (context, url) => Loading(),
      imageUrl: url, //
      width: ScreenUtil().L(100),
      height: ScreenUtil().H(100),
      fit: BoxFit.fill,
    );
/*
    if(type=='mp4')
      mwt= Container(
        width: ScreenUtil.screenWidth,
        height: ScreenUtil().H(200),
        child:
        TxVideoPlayer(url),
//        ChewieListItem(
//          videoPlayerController: VideoPlayerController.network(url,
//          ),
//        )//TxVideoPlayer(url),
      );
    else if(type=='mp3')
      mwt= Container(
        width: ScreenUtil.screenWidth,
        height: ScreenUtil().H(200),
        child: AudioApp(url: url),
      );
*/

    return SafeArea(
      child: Container(
        width: imageWidth,
        height: imageHeight,
        child: Hero(
          key: Key(vdid),
          tag: "tag$vdid",
          child:mwt
          ,
        ),
      ),
      /*   */
    );
  }
}
