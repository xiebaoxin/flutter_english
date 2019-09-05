import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../../components/loading_gif.dart';
import '../../utils/HttpUtils.dart';
import 'audio_tool.dart';
import 'player_tool.dart';
import 'package:rxdart/rxdart.dart';
import '../../model/globle_model.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class FullPlayerPage extends StatefulWidget {
  final String url;
  final Map<String, dynamic> video; //字幕文件
  final Map<String, dynamic> info;
  final bool isLocal;
  final PlayerMode mode;

  FullPlayerPage(
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

class _PlayerXbxWidgetState extends State<FullPlayerPage>
    with TickerProviderStateMixin {
  ScrollController _scrollController = ScrollController(); //listview的控制器

  String url;
  bool isLocal;
  PlayerMode mode;
  _PlayerXbxWidgetState(this.url, this.isLocal, this.mode);

  Map<String, dynamic> _video; //字幕文件
  Map<String, dynamic> _info;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  int _txtid = 0; //文档位置


  Animation<double> animationNeedle;
  Animation<double> animationRecord;
  AnimationController controllerNeedle;
  AnimationController controllerRecord;

//  final _subscriptions = CompositeSubscription();


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
    return Scaffold(
//            backgroundColor: Colors.transparent,
        appBar: new AppBar(
          automaticallyImplyLeading: false,
//              backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Container(
            child: Text(
              url!=null? _video['video_name']:"播放器",
              style: new TextStyle(fontSize: 13.0),
            ),
          ),
        ),
        body: url!=null? (_txtinfo['txtlist'] == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Loading(),
              Text(
                "加载字幕文件",
                style: TextStyle(color: Colors.black26),
              )
            ],
          ),
        )
            : buildTxt(_txtinfo['txtlist'])):Text("什么都没有"),
        bottomNavigationBar:url!=null?  buildPlayer(context):Text("哈哈"));
  }

  Future<Map<String, dynamic>> _getMp3Text() async {
    Map<String, String> params = {"id": _video['video_id'].toString()};
    Map<String, dynamic> txtinfo =
    await HttpUtils.dioappi('Pub/getmp3txt', params);
    setState(() {
      _txtinfo = txtinfo;
//      print(_txtinfo);
//      _curtNextDuration = getTxtDuration(1);
//      print("---------------------$_curtNextDuration--------");
    });
  }

  Widget buildPlayer(context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
//            data: theme.sliderTheme.copyWith(
              activeTrackColor: Colors.black45,
              inactiveTrackColor: Colors.grey[300],
              activeTickMarkColor: Colors.black54,
              inactiveTickMarkColor: Colors.white70,
              overlayColor: Colors.grey,
              thumbColor: Colors.deepOrange,
              valueIndicatorColor: Colors.deepPurpleAccent,
              valueIndicatorTextStyle:
              theme.accentTextTheme.body2.copyWith(color: Colors.black45),
            ),
            child: Slider(
              onChanged: (double value) {
                _pause();
//               _curtDuration = Duration(
//                    milliseconds:
//                        (_duration.inMilliseconds * value~/100).toInt());

//                _txtid = getitemid((_duration.inMilliseconds * value~/100).toInt());
//                print("==${_duration.inMilliseconds }=Slider==${value}====[$_txtid]== ${_curtDuration.inMilliseconds}==${_duration.inMilliseconds}==");
//              找出当前对应的字幕位置
                _txtid=(_txtinfo['txtlist'].length * value~/100).toInt();
                print(_txtid);
                if (_txtid > 0) {
                  setState(() {
                    _curtNextDuration = getTxtDuration(_txtid + 1);
                    _curtDuration=getTxtDuration(_txtid );
                    _offsetPositonn = 0;
                  });
                  _seek();
                }

              },
              value: (_position != null &&
                  _duration != null &&
                  _position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _duration.inMilliseconds)
                  ? _position.inMilliseconds * 100 / _duration.inMilliseconds
                  : 0.0,
              min: 0.0,
              max: 100,
              activeColor: Colors.deepOrange,
              divisions: 100,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new IconButton(
                  onPressed: () => _previous(),
                  iconSize: 32.0,
                  icon: new Icon(Icons.skip_previous),
                  color: Colors.black45),
              new IconButton(
                  onPressed: _isPlaying ? () => _pause() : () => _play(),
                  iconSize: 32.0,
                  icon: new Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.black45),
              new IconButton(
                  onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                  iconSize: 32.0,
                  icon: new Icon(Icons.stop),
                  color: Colors.black45),
              new IconButton(
                onPressed: () => _onNext(),
                icon: new Icon(
                  Icons.skip_next,
                  size: 32.0,
                  color: Colors.black45,
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
            style: new TextStyle(fontSize: 16.0, color: Colors.black45),
          ),
//          Text("State: $_audioPlayerState"),
        ],
      ),
    );
  }

  void _goToElement(double index) {
    _scrollController.animateTo(
        (60.0 +
            index), // 100 is the height of container and index of 6th element is 5
        duration: const Duration(milliseconds: 200),
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

          return Padding(
              padding: const EdgeInsets.all(2.0),
              child: InkWell(
                onTap: () {
                  _pause();
                  setState(() {
                    _txtid = i;
                    _curtNextDuration = getTxtDuration(i + 1);
                    _curtDuration=getTxtDuration(i);
                  });
                  _seek();
                },
                child: Column(
                  children: <Widget>[
                    item['eng'] != null
                        ? Text(item['eng'],
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: _txtid == i
                            ? TextStyle(
                            color: Colors.green, fontSize: 18)
                            : TextStyle(color: Colors.black45))
                        : SizedBox(
                      height: 1,
                    ),
                    _video['txt_type'] == 'txt'
                        ? item['cn'] != null
                        ? Text(item['cn'],
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: _txtid == i
                            ? TextStyle(
                            color: Color(0xFFFF9933),
                            fontSize: 18)
                            : TextStyle(color: Colors.black45))
                        : SizedBox(
                      height: 1,
                    )
                        : Divider(
                      height: 1,
                    ),
                  ],
                ),
              ));
        });
  }

  Duration getTxtDuration(int index) {
    Duration tempcurtDuration = Duration(seconds: 0);
    Map<String, dynamic> item = _txtinfo['txtlist'][index];
    if (_video['txt_type'] == "txt" ||
        _video['txt_type'] == "lrc") {
      List<String> dtime = item['st'].toString().split(":");
      if (dtime.length == 3) {
        tempcurtDuration = Duration(
            hours: int.tryParse(dtime[0]),
            minutes: int.tryParse(dtime[1]),
            milliseconds: _video['txt_type'] == 'txt'
                ? int.tryParse(dtime[2].replaceAll(",", "").trim())
                : (int.tryParse(dtime[2].split(".")[0]) * 1000 +
                int.tryParse(dtime[2].split(".")[1]) * 10));
      } else if (dtime.length == 2) {
        tempcurtDuration = Duration(
            minutes: int.tryParse(dtime[0]),
            milliseconds: _video['txt_type'] == 'txt'
                ? int.tryParse(dtime[1].replaceAll(",", "").trim())
                : (int.tryParse(dtime[1].split(".")[0]) * 1000 +
                int.tryParse(dtime[1].split(".")[1]) * 10));
      } else if (dtime.length == 1) {
        tempcurtDuration = Duration(
            milliseconds: _video['txt_type'] == 'txt'
                ? int.tryParse(dtime[0].replaceAll(",", "").trim())
                : (int.tryParse(dtime[0].split(".")[0]) * 1000 +
                int.tryParse(dtime[0].split(".")[1]) * 10));
      }
    }
    _curtDuration = tempcurtDuration;
    return tempcurtDuration;
  }

  int getitemid(int curration) {
    if (_txtinfo['txtlist'].isNotEmpty) {
      int i=0;
      for(var index=1;index<_txtinfo['txtlist'].length;index++){
        i= _txtinfo['txtlist'].length-index-1;

        if (curration >=
            getTxtDuration(i).inMilliseconds) {
          print( getTxtDuration(i).inMilliseconds);
          _txtid = i;
          break;
        }
      }
    }
    return _txtid;
  }

  @override
  void initState() {
    _video=widget.video;
    _info=widget.info;

    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
      }
    });
    /*
    controllerNeedle = new AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animationNeedle = new CurvedAnimation(parent: controllerNeedle, curve: Curves.linear);

    controllerRecord = new AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    animationRecord = new CurvedAnimation(parent: controllerRecord, curve: Curves.linear);


    var s = PlayerTools.instance.stateSubject.listen((state) {
      if (state == PlayerState.playing) {
        controllerNeedle.forward();
        controllerRecord.forward();
      } else {
        controllerNeedle.reverse();
        controllerRecord.stop(canceled: false);
      }
    });
    _subscriptions.add(s);

    animationRecord.addStatusListener((status) {
      if (status == AnimationStatus.completed && PlayerTools.instance.currentState == PlayerState.playing) {
        controllerRecord.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controllerRecord.forward();
      }
    });
*/

    _getMp3Text();
    _initAudioPlayer();
    _play();

  }

  @override
  void dispose() {
    /*_audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _scrollController = null;
    _txtid = null;
    super.dispose();*/
  }

  int _offsetPositonn = 0;
  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen((duration) => setState(() {
          _duration = duration;
        }));

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
          _position = p;
          if (_curtNextDuration.inMilliseconds>0 && _position.inMilliseconds > _curtNextDuration.inMilliseconds) {
            _txtid = _txtid + 1;
            _curtNextDuration = getTxtDuration(_txtid + 1);

            //当前大概位置,超过400就滚动一下
            double inndexoffset =
                (_txtid * _scrollController.position.maxScrollExtent) /
                    _txtinfo['txtlist'].length;
            int tempidx=((inndexoffset.toInt() / 100).toInt() / 4).toInt();
            if ((inndexoffset.toInt() / 100).toInt() % 4 == 0 && tempidx > _offsetPositonn) {
              _offsetPositonn =tempidx;
              _goToElement(inndexoffset);
            }

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
        _offsetPositonn=0;
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
    setState(() {_playerState = PlayerState.stopped;_offsetPositonn=0; _txtid = 0;});
  }
}
