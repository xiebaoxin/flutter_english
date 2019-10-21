import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart';
//import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import '../components/loading_gif.dart';
import '../utils/HttpUtils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/fiexdAppbar.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioPlayerWuthTxt extends StatefulWidget {
  final String url;
  final Map<String, dynamic> video; //字幕文件
  final bool isLocal;
  final PlayerMode mode;

  AudioPlayerWuthTxt(
      {@required this.url,
      this.video,
      this.isLocal = false,
      this.mode = PlayerMode.MEDIA_PLAYER});

  @override
  State<StatefulWidget> createState() {
    return new _PlayerWidgetState(url, isLocal, mode);
  }
}

class _PlayerWidgetState extends State<AudioPlayerWuthTxt> {
  String url;
  bool isLocal;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  int _txtid = 0;//文档位置

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

  _PlayerWidgetState(this.url, this.isLocal, this.mode);
  Map<String, dynamic> _txtinfo = {};

  @override
  Widget build(BuildContext context) {
    final Color bkgColor =Color.fromARGB(255, 237, 88, 84);
    var topBar = new Container(
      child: buildPlayer(), //注意：加入了child，AppBar的高度会是Container的实际高度，而不是你指定的高度
      color: Colors.deepOrange ,
    );
    return Scaffold(
        appBar: new FiexdAppbar(
          contentChild: topBar,
          contentHeight: 300,
          statusBarColor: bkgColor,
        ),
        body:_txtinfo['txtlist']==null? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Loading(),
                Text("加载字幕中",style: TextStyle(color: Colors.black26),)
              ],
            ),
          )
       :
        buildTxt(_txtinfo['txtlist']));
  }

  Future<Map<String, dynamic>> _getMp3Text() async {
    Map<String, String> params = {"id": widget.video['video_id'].toString()};
    Map<String, dynamic> txtinfo =
        await HttpUtils.dioappi('Pub/getmp3txt', params);
    setState(() {
      _txtinfo = txtinfo;
      _curtNextDuration = getTxtDuration(1);
      print("---------------------$_curtNextDuration--------");
    });
  }

  Widget buildPlayer() {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new IconButton(
                onPressed: _isPlaying ? null : () => _play(),
                iconSize: 64.0,
                icon: new Icon(Icons.play_arrow),
                color: Colors.white70),
            new IconButton(
                onPressed: _isPlaying ? () => _pause() : null,
                iconSize: 64.0,
                icon: new Icon(Icons.pause),
                color: Colors.white70),
            new IconButton(
                onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                iconSize: 64.0,
                icon: new Icon(Icons.stop),
                color: Colors.white70),
          ],
        ),
        new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            new Padding(
              padding: new EdgeInsets.all(12.0),
              child: SliderTheme(
                data: theme.sliderTheme.copyWith(
                  activeTrackColor: Colors.deepOrange,
                  inactiveTrackColor: Colors.grey[300],
                  activeTickMarkColor: Colors.white70,
                  inactiveTickMarkColor: Colors.black,
                  overlayColor: Colors.black12,
                  thumbColor: Colors.deepOrange,
                  valueIndicatorColor: Colors.deepPurpleAccent,
                  valueIndicatorTextStyle: theme.accentTextTheme.body2
                      .copyWith(color: Colors.black87),
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
                  divisions: 100,
                  onChanged: (v){
                    ;
                  },
                ),
              ),
            ),
            new Text(
              _position != null
                  ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                  : _duration != null ? _durationText : '',
              style: new TextStyle(fontSize: 24.0),
            ),
          ],
        ),
        new Text("State: $_audioPlayerState"),
      ],
    );
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
            itemBuilder: (BuildContext context, int i) {
              Map<String, dynamic> item = list[i];
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
                        Text(item['eng']??"none english",
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _txtid == i
                                    ? Color(0xFFFF9933)
                                    : Colors.black54)),
                        widget.video['txt_type'] == 'txt'
                            ? Text(item['cn']??"无中文",
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: _txtid == i
                                        ? Color(0xFFFF9933)
                                        : Colors.black54))
                            : Divider(
                                height: 1,
                              ),
                      ],
                    ),
                  ));
            },
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
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
