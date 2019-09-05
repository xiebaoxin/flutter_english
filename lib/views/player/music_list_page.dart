import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'opacity_tap_widget.dart';
import 'player_tool.dart';
import '../../model/song.dart';
import '../../utils/dataUtils.dart';
import '../../utils/DialogUtils.dart';
import '../../routers/application.dart';
import '../../model/buy_model.dart';
import '../buygoods_page.dart';

class MusicListPage extends StatefulWidget {
  final  List<Map<String, dynamic>> vdlist;//列表集合
  final Song curSong;
  final int curindex;
  MusicListPage(this.vdlist,this.curindex,this.curSong);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MusicListState();
  }
}

class MusicListState extends State<MusicListPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      backgroundColor: Colors.black87.withOpacity(0.75),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child:  OpacityTapWidget(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: new Icon(Icons.close, color: Colors.white, size: 36,),
              ),
            ),
          ),
          new Expanded(
            child:_buildListView()
          )
        ],
      ),
    );
  }

  Widget _buildListView() {
    return new ListView.builder(
        padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.1, 0, 0),
        itemCount: widget.vdlist.length,
        itemBuilder: (context, i) {
          if (widget.vdlist.length > 0) {
            return getRow(widget.vdlist[i], i);
          }
        });
  }

  Widget getRow(Map<String, dynamic> item, int index) {
    return new Container(
      child: new OpacityTapWidget(
        onTap: () async {

          Map<String, dynamic> item = widget.curSong.vdlist[index];
//          print("===--MusicListPage====${item['video_name']}===preid=${widget.curSong.preid}=====nextid ${widget.curSong.nextid}==========55555555555=======");

          if (await DataUtils.isCheckedGoods(
              widget.curSong.info['goods_id'], videoid: index,
              vd_level: widget.curSong.info['vd_level'])) {

            await DataUtils.getmp3txt(item['video_id']).then((txlist) {
              Navigator.of(context).pop(true);
              PlayerTools.instance.setSong(Song(
                  vdlist: widget.curSong.vdlist,
                  url: item['video_url'],
                  video: item,
                  info: widget.curSong.info,
                  txtlist: txlist,
                  preid:
                  index > 0 ? widget.curSong.vdlist[index - 1]['video_id'] : 0,
                  nextid: index < widget.curSong.vdlist.length
                      ? widget.curSong.vdlist[index + 1 ]['video_id']
                      : 0));
            });
          }
          else {
            if (await DialogUtils().showMyDialog(
                context, '需要购买才能收听或观看，是否去购买?')) {
              Application().checklogin(context, () {
                Navigator.pop(context);
                BuyModel param = BuyModel(
                    goods_id: widget.curSong.info['goods_id'].toString(),
                    goods_num: "1",
                    item_id: "0",
                    imgurl: widget.curSong.info['original_img'],
                    goods_price: double.tryParse(
                        widget.curSong.info['shop_price']));
                Navigator.push(
                    context,
                    MaterialPageRoute(
//                            builder: (context) => BuyPage(param),
                      builder: (context) => GoodsBuyPage(param),
                    ));
              });
            }
          }
        },

        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              width: MediaQuery.of(context).size.width,
              child: new Text("${index+1}: ${item['video_name']}", style: TextStyle(color:index==widget.curindex? Colors.green:Colors.white),),
            ),
            new Divider(height: 1,)
          ],
        ),
      ),
    );
  }
}