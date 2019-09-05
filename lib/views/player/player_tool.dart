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
        this.nextAction(true);
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
  int _mode = 0;
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
    this._currentSong = song;
//    print("====setSong=======${song.preid}====${song.video['video_id']}==${song.nextid}========================");
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
     if (this.currentSong.preid >= 0) {
        int index = this.currentSong.preid;
        Map<String, dynamic> item = index>=1?this.currentSong.vdlist[index-1]:this.currentSong.vdlist[0];

        await DataUtils.getmp3txt(item['video_id']).then((txlist) {
        setSong(Song(
            vdlist: this.currentSong.vdlist,
            url: item['video_url'],
            video: item,
            info: this.currentSong.info,
            txtlist: txlist,
            preid:
                index > 1 ? this.currentSong.vdlist[index - 2]['video_id'] : 0,
            nextid: index < this.currentSong.vdlist.length
                ? this.currentSong.vdlist[index]['video_id']
                : 0));
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
    int endid=_currentSong.nextid?? (_currentSong.vdlist!=null ?_currentSong.vdlist.length:0);
    int maxend=_currentSong.vdlist!=null ?_currentSong.vdlist.length:0;

    if (this.currentSong.nextid > 0 && endid<=maxend) {
      int index = this.currentSong.nextid;
      Map<String, dynamic> item = this.currentSong.vdlist[index];
//print("===--PlayerTools====${item['video_name']}===preid=${this.currentSong.preid}=====nextid ${this.currentSong.nextid}=================4444444444444444===============");

      await DataUtils.getmp3txt(item['video_id']).then((txlist) {
        setSong(Song(
            vdlist: this.currentSong.vdlist,
            url: item['video_url'],
            video: item,
            info: this.currentSong.info,
            txtlist: txlist,
            preid:
            index > 0 ? this.currentSong.vdlist[index -1]['video_id'] : 0,
            nextid: index < this.currentSong.vdlist.length
                ? this.currentSong.vdlist[index+1]['video_id']
                : maxend));
      });

    }
    /* if (isAutoend && this.mode == 2) {
      return this.play(songArr[currentPlayIndex]);
    }
    if (this.mode == 1) { // 随机
      this.currentPlayIndex = Random().nextInt(this.songArr.length - 1);
    } else {
      this.currentPlayIndex += 1;
      if (this.currentPlayIndex >= this.songArr.length) {
        this.currentPlayIndex = 0;
      }
    }
    return this.play(songArr[currentPlayIndex]);*/
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
