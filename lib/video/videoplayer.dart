import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'chewie_list_item.dart';
import 'tx_video_player.dart';

class MyVideoPlayer extends  StatelessWidget {
  final String url;
  MyVideoPlayer({this.url="http://200024424.vod.myqcloud.com/200024424_709ae516bdf811e6ad39991f76a4df69.f20.mp4"});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  title: Text('视频播放'),
  ),
  body: ListView(
  children: <Widget>[
  ChewieListItem(
  videoPlayerController: VideoPlayerController.network(url,
  ),
  ),
  TxVideoPlayer(url),

  ],
  ),
  );
  }
  }