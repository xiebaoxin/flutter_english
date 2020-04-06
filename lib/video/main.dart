import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
//import 'package:chewie/chewie.dart';
import 'chewie_list_item.dart';
import 'tx_video_player.dart';
import '../views/webView.dart';

class videoApp extends StatefulWidget {
  @override
  videoAppState createState() => new videoAppState();
}

class videoAppState extends State<videoApp> {
  VideoPlayerController _controller;
  bool _isPlaying = false;
  String _url =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(_url)
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: new Scaffold(
          body:
          /*Center(
              child: new Chewie(
        controller: ChewieController(
          videoPlayerController: _controller,
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
      ))*/
              new Center(
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
  void didUpdateWidget(videoApp oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}

class MyVideoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:WebView("视频", "https://v.qq.com/txp/iframe/player.html?vid=k0899kt5pal") ,//MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: ListView(
        children: <Widget>[
           /*      ChewieListItem(
            videoPlayerController: VideoPlayerController.asset(
              'videos/IntroVideo.mp4',
            ),
            looping: true,
          ),*/
          ChewieListItem(
            videoPlayerController: VideoPlayerController.network(
              'http://200024424.vod.myqcloud.com/200024424_709ae516bdf811e6ad39991f76a4df69.f20.mp4',
            ),
          ),
          TxVideoPlayer("http://200024424.vod.myqcloud.com/200024424_709ae516bdf811e6ad39991f76a4df69.f20.mp4"),

//          TxVideoPlayer("https://github.com/RandyWei/flt_video_player/blob/master/example/SampleVideo_1280x720_30mb.mp4?raw=true"),
//          TxVideoPlayer("http://5815.liveplay.myqcloud.com/live/5815_89aad37e06ff11e892905cb9018cf0d4_900.flv"),
//          TxVideoPlayer("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
          TxVideoPlayer("https://f.us.sinaimg.cn/0033RqdKlx07sVBJOsSI01041202qG6T0E010.mp4?label=mp4_720p&template=1280x720.27.0&Expires=1562832602&ssig=GI%2F%2BwM41l1&KID=unistore,video"),//优酷地址
          ChewieListItem(
            videoPlayerController: VideoPlayerController.network(
              'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            ),
          ),
       /*   ChewieListItem(
            // This URL doesn't exist - will display an error
            videoPlayerController: VideoPlayerController.network(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            ),
          ),*/
        ],
      ),
    );
  }
}
