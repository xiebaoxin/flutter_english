import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
class VideoWebPlayer extends StatelessWidget {
  final String content;
  VideoWebPlayer(this.content);

  @override
  Widget build(BuildContext context) {
    if (content!='') {
      return Html(data: content);
    } else {
      return Container(
        child: Text('暂时没有数据'),
      );
    };
  }
}
/*
* <iframe src="//1257053323.vod2.myqcloud.com/vod-player/1257053323/5285890791838109147/tcplayer/console/vod-player.html?autoplay=false&width=0&height=0"
frameborder="0" scrolling="no" width="100%" height="0" allowfullscreen >
</iframe>
*/