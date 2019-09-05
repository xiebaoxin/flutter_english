import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class video_player_demo extends StatefulWidget {
  @override
  video_player_demoState createState() => new video_player_demoState();
}

class video_player_demoState extends State<video_player_demo> {

  VideoPlayerController _controller;
  bool _isPlaying = false;
  String url = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(this.url)
    // 播放状态
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() { _isPlaying = isPlaying; });
        }
      })
    // 在初始化完成后必须更新界面
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: new Scaffold(
/*        body: Center(
          child: new Chewie(new VideoPlayerController.network(this.url),
            aspectRatio: 16 / 9,
            autoPlay: !true,
            looping: true,
            showControls: true,
            // 占位图
            placeholder: new Container(
              color: Colors.grey,
            ),
            // 是否在 UI 构建的时候就加载视频
            autoInitialize: !true,

            // 拖动条样式颜色
            materialProgressColors: new ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.blue,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.lightGreen,
            ),
          ),
        ),*/
        body: new Center(
          child: _controller.value.initialized
          // 加载成功
              ? new AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ) : new Container(),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _controller.value.isPlaying
              ? _controller.pause
              : _controller.play,
          child: new Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(video_player_demo oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}