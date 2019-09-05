import 'package:flutter/material.dart';
import '../utils/fiexdAppbar.dart';
import 'package:video_player/video_player.dart';
import 'chewie_list_item.dart';
import 'tx_video_player.dart';
import 'video_web.dart';
import 'audioPlayerWithTxt.dart';
import 'audioplayer.dart';

class xiePlayer extends StatefulWidget {
  final String url;
  final Map<String, dynamic> video;
  final String type;
  final String vdhtml;

  xiePlayer(
      {this.type = 'mp4',
      this.video,
      this.url =
          "http://200024424.vod.myqcloud.com/200024424_709ae516bdf811e6ad39991f76a4df69.f20.mp4",
      this.vdhtml=''});
  @override
  PlayerState createState() => new PlayerState();
}

class PlayerState extends State<xiePlayer> {
  VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final Color bkgColor = Color.fromARGB(255, 237, 88, 84);
    var topBar = new Container(
      child: toplay(), //注意：加入了child，AppBar的高度会是Container的实际高度，而不是你指定的高度
      color: Colors.blue,
    );
    return Scaffold(
      appBar: new FiexdAppbar(
        contentChild: topBar,
        contentHeight: 250.0,
        statusBarColor: bkgColor,
      ),
      body: mainwt(),
    );
  }

  Widget toplay() {
    String url = widget.url;
    if (widget.type == 'mp4')
      return TxVideoPlayer(url);
    else if (widget.type == 'mp3')
      return AudioPlayerWuthTxt(url: url,video: widget.video,);
//      return AudioApp(url: url);
    else if (widget.type == 'web')
      return VideoWebPlayer(url);
    else
      return ChewieListItem(
        videoPlayerController: VideoPlayerController.network(
          url,
        ),
      );
  }

  Widget mainwt() {
    return ListView(
      children: <Widget>[
       Text("暂无简介"),
        Text("暂无相关"),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      // 播放状态
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      // 在初始化完成后必须更新界面
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(xiePlayer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
