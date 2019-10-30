import 'dart:async';
import 'audio_tool.dart';
import '../../main_provide.dart';
import 'package:rxdart/rxdart.dart';
import '../../model/song.dart';
import '../../utils/comUtil.dart';
import '../../utils/dataUtils.dart';
import '../../utils/HttpUtils.dart';

class PlayerTools {
  final stateSubject =
      new BehaviorSubject<AudioToolsState>.seeded(AudioToolsState.isStoped);
  final progressSubject = new BehaviorSubject<int>.seeded(0);
  final timerDownSubject = new BehaviorSubject<String>.seeded('');
  final currentSongSubject = new BehaviorSubject<Song>.seeded(Song());

  AudioTools audio;

  // 工厂模式
  factory PlayerTools() => _getInstance();
  static PlayerTools get instance => _getInstance();
  static PlayerTools _instance;
  static PlayerTools _getInstance() {
    if (_instance == null) {
      _instance = new PlayerTools._internal();
    }
    return _instance;
  }

  PlayerTools._internal() {
    // 初始化
    audio = AudioTools();

    audio.stateSubject.listen((state) {
      this.currentState = state;
      this.stateSubject.value = state;
      if (state == AudioToolsState.isEnd) {
        if (this.mode == 1) { // 下一首
          this.nextAction(true);
        }
      }

    });
    audio.progressSubject.listen((progress) {
      this.currentProgress = progress;
      this.progressSubject.value = progress;
    });
    audio.durationSubject.listen((duration) {
      this.duration = duration;
    });
  }

  Song _currentSong = Song();
  Song get currentSong => _currentSong;
  set currentSong(Song currentSong) {
    _currentSong = currentSong;
    currentSongSubject.value = currentSong;
  }

  int _currentProgress = 0;
  int get currentProgress => _currentProgress;
  set currentProgress(int progress) {
    _currentProgress = progress;
  }

  int _duration = 0;
  int get duration => _duration;
  set duration(int duration) {
    _duration = duration;
  }

  /// 0顺序 1随机  2单曲
  int _mode = 2;
  int get mode => _mode;
  set mode(int mode) {
    _mode = mode;
  }

  AudioToolsState _currentState = AudioToolsState.isStoped;
  AudioToolsState get currentState => _currentState;
  set currentState(AudioToolsState state) {
    _currentState = state;
  }

  // 设置数据源
  setSong(Song song) {
    this.stop();
    this._currentState=AudioToolsState.isEnd;
    this._currentState=AudioToolsState.isStoped;
    this._currentSong = song;

    this.play(song);
    MainProvide.instance.showMini = true;
  }

  /// 播放
  Future<int> play(Song song) async {
    this.currentSong = song;
    String songurl = song.url;
    return audio.play(songurl);
  }

  /// 暂停
  Future<int> pause() async {
    return audio.pause();
  }

  Future<int> resume() async {
    return audio.resume();
  }

  /// 停止
  Future<int> stop() async {
    return audio.stop();
  }

  /// seek
  Future<int> seek(int value) async {
    return audio.seek(value);
  }

  /// 上一首
  Future<int> preAction() async {
    if (this._currentSong.preid >= 0) {
      int index = this._currentSong.preid;
      Map<String, dynamic> item = getvdlistItem(index);
      await DataUtils.getmp3txt(this._currentSong.preid).then((txlist) {
        return this.setSong(Song(
            id:this._currentSong.preid,
            vdlist: this._currentSong.vdlist,
            url: item['video_url'],
            video: item,
            info: this._currentSong.info,
            txtlist: txlist,
            preid: this._currentSong.preid-1,
            nextid: this._currentSong.id));
      });
    }
/*
    if (this.mode == 1) { // 随机
      this.currentPlayIndex = Random().nextInt(this.songArr.length - 1);
    } else {
      this.currentPlayIndex -= 1;
      if (this.currentPlayIndex < 0) {
        this.currentPlayIndex = this.songArr.length - 1;
      }
    }

    return this.play(songArr[currentPlayIndex]);*/
  }

  /// 下一首
  Future<int> nextAction([bool isAutoend = false]) async {
    if (this._currentSong.nextid > 0) {
      int index = this._currentSong.nextid;
      Map<String, dynamic> item = getvdlistItem(index);

      await DataUtils.getmp3txt(this._currentSong.nextid).then((txlist) {
        return this.setSong(Song(
            id:this._currentSong.nextid,
            vdlist: this._currentSong.vdlist,
            url: item['video_url'],
            video: item,
            info: this._currentSong.info,
            txtlist: txlist,
            preid: this._currentSong.id ,
            nextid: this._currentSong.nextid+1));
      });

    }

  }

  Map<String, dynamic> getvdlistItem(int index){
    Map<String, dynamic> ddd={};
     this._currentSong.vdlist.forEach((ele) {
       if (ele.isNotEmpty) {
         if(index==ele['video_id'])
           ddd= ele;
       }
     });
     return ddd;
  }
  /// 定时器
  Timer _countdownTimer;
  int _countdownNum = 0;
  int get countdownNum => _countdownNum;
  set countdownNum(int countdownNum) {
    _countdownNum = countdownNum;
    if (countdownNum > 0) {
      this.startTimer();
    } else {
      this.stopTimer();
    }
  }

  /// 开启定时器
  startTimer() {
    stopTimer();
    _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      print(timer);
      this.countdownNum = this.countdownNum - 1;
      String text = ComFunUtil.dealDuration('${this.countdownNum}');
      String downText = text + '后播放器关闭';
      timerDownSubject.value = downText;
      if (this.countdownNum == 0) {
        this.pause();
      }
    });
  }

  /// 关闭定时器
  stopTimer() {
    if (_countdownTimer != null) {
      _countdownTimer.cancel();
      _countdownTimer = null;
    }
  }
}
