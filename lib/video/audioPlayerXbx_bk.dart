import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../components/loading_gif.dart';
import '../utils/HttpUtils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../utils/fiexdAppbar.dart';
import 'anims/needle_anim.dart';
import 'anims/record_anim.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioPlayerXbx extends StatefulWidget {
  final String url;
  final Map<String, dynamic> video; //字幕文件
  final Map<String, dynamic> info;
  final bool isLocal;
  final PlayerMode mode;

  AudioPlayerXbx(
      {@required this.url,
      this.info,
      this.video,
      this.isLocal = false,
      this.mode = PlayerMode.MEDIA_PLAYER});

  @override
  State<StatefulWidget> createState() {
    return new _PlayerXbxWidgetState(url, isLocal, mode);
  }
}

class _PlayerXbxWidgetState extends State<AudioPlayerXbx>
    with TickerProviderStateMixin {
  AnimationController controller_record;
  Animation<double> animation_record;
  Animation<double> animation_needle;
  AnimationController controller_needle;
  final _rotateTween = new Tween<double>(begin: -0.15, end: 0.0);
  final _commonTween = new Tween<double>(begin: 0.0, end: 1.0);

  ScrollController _scrollController = ScrollController(); //listview的控制器

  String url;
  bool isLocal;
  PlayerMode mode;
  _PlayerXbxWidgetState(this.url, this.isLocal, this.mode);

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  int _txtid = 0; //文档位置

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  Map<String, dynamic> _txtinfo = {};

  @override
  Widget build(BuildContext context) {
    if (_isPlaying) {
      controller_record.forward();
      controller_needle.forward();
    } else {
      controller_record.stop(canceled: false);
      controller_needle.reverse();
    }
  /*  return new Scaffold(
      backgroundColor: Colors.transparent,
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Container(
          child: Text(
            widget.video['video_name'],
            style: new TextStyle(fontSize: 13.0),
          ),
        ),
      ),
      body:
      Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new NetworkImage("${widget.info['original_img']}"),
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(
                  Colors.black54,
                  BlendMode.overlay,
                ),
              ),
            ),
          ),
          new Container(
              child: new BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Opacity(
                  opacity: 0.6,
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              )),
          Stack(
            alignment: const FractionalOffset(0.5, 0.0),
            children: <Widget>[
              new Stack(
                alignment: const FractionalOffset(0.7, 0.1),
                children: <Widget>[
                  new Container(
                    child: RotateRecord(
                        animation: _commonTween.animate(controller_record)),
                    margin: EdgeInsets.only(top: 100.0),
                  ),
                  new Container(
                    child: new PivotTransition(
                      turns: _rotateTween.animate(controller_needle),
                      alignment: FractionalOffset.topLeft,
                      child: new Container(
                        width: 100.0,
                        child: new Image.asset("images/play_needle.png"),
                      ),
                    ),
                  ),
                ],
              ),
              new Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: _txtinfo['txtlist'] == null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Loading(),
                        Text(
                          "加载字幕中",
                          style: TextStyle(color: Colors.black26),
                        )
                      ],
                    ),
                  )
                      : buildTxt(_txtinfo['txtlist'])),
            ],
          ),
        ],
      ),
    bottomNavigationBar: buildPlayer(context)
    );*/
    return Stack(
      children: <Widget>[
        new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new NetworkImage("${widget.info['original_img']}"),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                Colors.black54,
                BlendMode.overlay,
              ),
            ),
          ),
        ),
        new Container(
            child: new BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Opacity(
            opacity: 0.6,
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.grey.shade900,
              ),
            ),
          ),
        )),
        new Scaffold(
            backgroundColor: Colors.transparent,
            appBar: new AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: Container(
                child: Text(
                  widget.video['video_name'],
                  style: new TextStyle(fontSize: 13.0),
                ),
              ),
            ),
            body:  Stack(
              alignment: const FractionalOffset(0.5, 0.0),
              children: <Widget>[
                new Stack(
                  alignment: const FractionalOffset(0.7, 0.1),
                  children: <Widget>[
                    new Container(
                      child: RotateRecord(
                          animation: _commonTween.animate(controller_record)),
                      margin: EdgeInsets.only(top: 100.0),
                    ),
                    new Container(
                      child: new PivotTransition(
                        turns: _rotateTween.animate(controller_needle),
                        alignment: FractionalOffset.topLeft,
                        child: new Container(
                          width: 100.0,
                          child: new Image.asset("images/play_needle.png"),
                        ),
                      ),
                    ),
                  ],
                ),
                new Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: _txtinfo['txtlist'] == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Loading(),
                                Text(
                                  "加载字幕中",
                                  style: TextStyle(color: Colors.black26),
                                )
                              ],
                            ),
                          )
                        : buildTxt(_txtinfo['txtlist'])),
              ],
            ),
            bottomNavigationBar: buildPlayer(context)
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _getMp3Text() async {
    Map<String, String> params = {"id": widget.video['video_id'].toString()};
    Map<String, dynamic> txtinfo =
        await HttpUtils.dioappi('Pub/getmp3txt', params);
    setState(() {
      _txtinfo = txtinfo;
      print(_txtinfo);
      _curtNextDuration = getTxtDuration(1);
      print("---------------------$_curtNextDuration--------");
    });
  }

  Widget buildPlayer(context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      height:90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
/*          SliderTheme(
            data: SliderTheme.of(context).copyWith(
//            data: theme.sliderTheme.copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
            activeTickMarkColor: Colors.white70,
              inactiveTickMarkColor: Colors.white70,
              overlayColor: Colors.grey,
              thumbColor: Colors.deepOrange,
              valueIndicatorColor: Colors.deepPurpleAccent,
              valueIndicatorTextStyle: theme.accentTextTheme.body2
                  .copyWith(color: Colors.white),
            ),
            child: Slider(
              value: (_position != null &&
                  _duration != null &&
                  _position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _duration.inMilliseconds)
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0.0,
              min: 0,
              max: 1,
//              activeColor: Colors.deepOrange,
              divisions: 100,
            ),
          ),*/
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new IconButton(
                  onPressed: () => _previous(),
                  iconSize: 32.0,
                  icon: new Icon(Icons.skip_previous),
                  color: Colors.white70),
              new IconButton(
                  onPressed: _isPlaying ? () => _pause() : () => _play(),
                  iconSize: 32.0,
                  icon: new Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.white70),
              new IconButton(
                  onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                  iconSize: 32.0,
                  icon: new Icon(Icons.stop),
                  color: Colors.white70),
              new IconButton(
                onPressed: () => _onNext(),
                icon: new Icon(
                  Icons.skip_next,
                  size: 32.0,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
              /*          new Padding(
                padding: new EdgeInsets.all(12.0),
                child: new Stack(
                  children: [
                    new CircularProgressIndicator(
                      value: 1.0,
                      valueColor: new AlwaysStoppedAnimation(Colors.grey[300]),
                    ),
                    new CircularProgressIndicator(
                      value: (_position != null &&
                              _duration != null &&
                              _position.inMilliseconds > 0 &&
                              _position.inMilliseconds < _duration.inMilliseconds)
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                      valueColor: new AlwaysStoppedAnimation(Colors.cyan),
                    ),
                  ],
                ),
              ),*/
           Text(
            _position != null
                ? '${_positionText ?? '--:--'} / ${_durationText ?? '--:--'}'
                : _duration != null ? _durationText : '',
            style: new TextStyle(fontSize: 16.0,color: Colors.white70),
          ),
//          Text("State: $_audioPlayerState"),
        ],
      ),
    );
  }

  void _goToElement(int index){
    _scrollController.animateTo((100.0 * index), // 100 is the height of container and index of 6th element is 5
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  Duration _curtDuration = Duration(seconds: 0); //指定的当前播放点
  Duration _curtNextDuration = Duration(seconds: 0);

  Widget buildTxt(list) {
    return list.length == 0
        ? Center(
            child: Text("没有相应字幕"),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: list.length,

            scrollDirection: Axis.vertical,
            controller: _scrollController,

            itemBuilder: (BuildContext context, int i) {
              Map<String, dynamic> item = list[i];
              if(_txtid>2 && i>(_txtid-2)){
                return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _txtid = i;
                          _curtNextDuration = getTxtDuration(i + 1);
                          getTxtDuration(i);
                        });
                        _seek();
                      },
                      child: Column(
                        children: <Widget>[
                          item['eng'] !=null ? Text(item['eng'],
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _txtid == i
                                      ? Color(0xFFFF9933)
                                      : Colors.white70)):SizedBox(height: 1,),
                          widget.video['txt_type'] == 'txt'
                              ? item['cn']!=null ?Text( item['cn'],
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _txtid == i
                                      ? Color(0xFFFF9933)
                                      : Colors.white70)):SizedBox(height: 1,)
                              : Divider(
                            height: 1,
                          ),
                        ],
                      ),
                    ));
              }else
                return SizedBox(height: 1,);

            }
          );
  }

  Duration getTxtDuration(int index) {
    Map<String, dynamic> item = _txtinfo['txtlist'][index];
    if (widget.video['txt_type'] == "txt" ||
        widget.video['txt_type'] == "lrc") {
      List<String> dtime = item['st'].toString().split(":");
      if (dtime.length == 3) {
        _curtDuration = Duration(
            hours: int.tryParse(dtime[0]),
            minutes: int.tryParse(dtime[1]),
            milliseconds: widget.video['txt_type'] == 'txt'
                ? int.tryParse(dtime[2].replaceAll(",", "").trim())
                : (int.tryParse(dtime[2].split(".")[0]) * 1000 +
                    int.tryParse(dtime[2].split(".")[1]) * 10));
      } else if (dtime.length == 2) {
        _curtDuration = Duration(
            minutes: int.tryParse(dtime[0]),
            milliseconds: widget.video['txt_type'] == 'txt'
                ? int.tryParse(dtime[1].replaceAll(",", "").trim())
                : (int.tryParse(dtime[1].split(".")[0]) * 1000 +
                    int.tryParse(dtime[1].split(".")[1]) * 10));
      } else if (dtime.length == 1) {
        _curtDuration = Duration(
            milliseconds: widget.video['txt_type'] == 'txt'
                ? int.tryParse(dtime[0].replaceAll(",", "").trim())
                : (int.tryParse(dtime[0].split(".")[0]) * 1000 +
                    int.tryParse(dtime[0].split(".")[1]) * 10));
      }
    }

    return _curtDuration;
  }

  @override
  void initState() {
    _getMp3Text();
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      print(_scrollController.offset); //打印滚动位置
      print(_scrollController.position.pixels);
      print("------------------------------------");
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
      }
    });

    controller_record = new AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    animation_record =
        new CurvedAnimation(parent: controller_record, curve: Curves.linear);

    controller_needle = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation_needle =
        new CurvedAnimation(parent: controller_needle, curve: Curves.linear);

    animation_record.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller_record.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controller_record.forward();
      }
    });

    _initAudioPlayer();
    _play();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _scrollController=null;
    super.dispose();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen((duration) => setState(() {
              _duration = duration;
            }));

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
              if (_position.inMilliseconds > _curtNextDuration.inMilliseconds) {
                _txtid = _txtid + 1;
                _curtNextDuration = getTxtDuration(_txtid + 1);
              }
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      Scaffold.of(context).showSnackBar(
        new SnackBar(
          content: new Text(msg),
        ),
      );
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
        _curtDuration = Duration(seconds: 0);
        _txtid = 0;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result =
        await _audioPlayer.play(url, isLocal: isLocal, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    return result;
  }

//int result = await audioPlayer.seek(Duration(milliseconds: 1200));int sposition  Duration(seconds: sposition)
  Future<int> _seek() async {
    final result =
        await _audioPlayer.play(url, isLocal: isLocal, position: _curtDuration);
    //      await _audioPlayer.seek(_curtDuration);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
        _curtDuration = Duration(seconds: 0);
        _txtid = 0;
      });
    }
    return result;
  }

  Future _previous() async {
    await _stop();
  }

  Future _onNext() async {
    await _stop();
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
