import 'package:flutter/material.dart';
import '../../data/base.dart';
import '../../model/song.dart';
import '../../utils/comUtil.dart';
import 'audio_tool.dart';
import 'player_tool.dart';
import '../../utils/dataUtils.dart';
import '../../utils/DialogUtils.dart';
import '../../routers/application.dart';
import '../../model/buy_model.dart';
import '../buygoods_page.dart';
import 'music_list_page.dart';

class PlayerProvide extends BaseProvide {

  PlayerProvide() {
    PlayerTools.instance.stateSubject.listen((state) {
      setControlls();
    });

    PlayerTools.instance.progressSubject.listen((progress) {
//      var ps= PlayerTools.instance.currentProgress;=progress
    if(PlayerTools.instance.currentState==AudioToolsState.isPlaying && _txtid==0 && progress>100){
        var endValue = (Duration(milliseconds:progress).inSeconds/PlayerTools.instance.duration) ?? 0.0;
        this.settxtid =endValue==0.0?1:( (_currentSong.txtlist.length * endValue) .toInt()??1)+1;
    }
    if (_currentSong.txtlist!=null && ( progress > _curtNextDuration.inMilliseconds &&
        _txtid <= _currentSong.txtlist.length)) {
        _txtid = _txtid + 1;

          _curtNextDuration = getTxtDuration(_currentSong.txtlist[_txtid + 1]);
    }

      this.songProgress =progress;
    });

    PlayerTools.instance.currentSongSubject.listen((song) {
      this.currentSong = song;
      this.notify();
    });


    setControlls();
  }

  List _controls = [];
  List get controls => _controls;
  set controls(List controls) {
    _controls = controls;
    notify();
  }

  double _offsetY = 0.0;
  double get offsetY => _offsetY;
  set offsetY(double offsetY) {
    _offsetY = offsetY;
    notify();
  }

  Song _currentSong = Song();
  Song get currentSong => _currentSong;
  set currentSong(Song currentSong) {
    _txtid = 0;
    _curtNextDuration = Duration(seconds: 0);
    _currentSong = currentSong;
  }

  /// 歌曲进度
  int _songProgress = 0;
  Duration _curtNextDuration = Duration(seconds: 0);
  int _txtid = 0;
  int get songProgress => _songProgress;
  int get txtid => _txtid;
  set settxtid(int txid){
    _txtid=txid;
    _curtNextDuration = getTxtDuration(_currentSong.txtlist[_txtid + 1]);
    seekmilscd(getTxtDuration(_currentSong.txtlist[_txtid]).inSeconds);
    notify();
  }
  set songProgress(int progress) {
    _songProgress = progress;
    notify();
  }



  /// 歌曲时长
  String songDuration() {
    return ComFunUtil.dealDuration('${PlayerTools.instance.duration}');
  }

  /// slider
  double sliderValue() {
    if (PlayerTools.instance.duration == 0) {
      return 0.0;
    }

    var value = (Duration(milliseconds:songProgress).inSeconds/PlayerTools.instance.duration) ?? 0.0;
//    var value = (PlayerTools.instance.currentProgress/PlayerTools.instance.duration) ?? 0.0;
    if (value > 1) {
      value = 1.0;
    }
    return value;
  }

  /// seek
  seek(double value) {
    int d = (value * PlayerTools.instance.duration).toInt();
    PlayerTools.instance.seek(d);
  }

  seekmilscd(int value) {
   PlayerTools.instance.seek(value);
  }


  pre() {
    if(_checkvdlistItem(PlayerTools.instance.currentSong.preid)){
      _txtid=0;
      this.songProgress=0;
      PlayerTools.instance.preAction();
    }
  }
  play() {
    if (PlayerTools.instance.currentState == AudioToolsState.isPlaying) {
      PlayerTools.instance.pause();
    }else if (PlayerTools.instance.currentState == AudioToolsState.isPaued) {
      PlayerTools.instance.resume();
    }else {
      _txtid=1;
      this.songProgress=0;
      PlayerTools.instance.play(_currentSong);
    }

  }
  next(BuildContext context) async{
    _txtid=0;
    this.songProgress=0;
    if (_currentSong.nextid > 0) {
      int ind=0;
      for(int i=0;i<_currentSong.vdlist.length;i++){
        if(_currentSong.vdlist[i]['video_id']==_currentSong.nextid)
        {ind=i;
        break;
        }
      }

      if(await DataUtils.isCheckedGoods(this._currentSong.info['goods_id'],videoid:ind,vd_level: this._currentSong.info['vd_level'])){
        PlayerTools.instance.nextAction();
      }
      else
        {
          if (await DialogUtils().showMyDialog(context, '需要购买才能收听或观看，是否去购买?')) {
            Application().checklogin(context, () {
              Navigator.pop(context);
              BuyModel param = BuyModel(
                  goods_id: _currentSong.info['goods_id'].toString(),
                  goods_num:"1",
                  item_id:"0",
                  imgurl:  _currentSong.info['original_img'],
                  goods_price: double.tryParse( _currentSong.info['shop_price']));
              Navigator.push(
                  context,
                  MaterialPageRoute(
//                            builder: (context) => BuyPage(param),
                    builder: (context) => GoodsBuyPage(param),
                  ));
            });
          }
        }
    }



  }
/*
  Widget _getModeWidget() {
    return
    PlayerTools.instance.mode == 0 ?
         new SvgPicture.asset("images/ic_spen.svg", width: 28, height: 28):
    PlayerTools.instance.mode == 1 ?
         new SvgPicture.asset("images/ic_rand.svg", width: 28, height: 28):
         new SvgPicture.asset("images/is_single.svg", width: 28, height: 28);
  }*/

  changeMode() {
    if (PlayerTools.instance.mode == 0) {
      PlayerTools.instance.mode = 1;
      setControlls();
      return;
    }
    if (PlayerTools.instance.mode == 1) {
      PlayerTools.instance.mode = 2;
      setControlls();
      return;
    }
    if (PlayerTools.instance.mode == 2) {
      PlayerTools.instance.mode = 0;
      setControlls();
      return;
    }
  }

  bool _checkvdlistItem(int index){
    bool ttt=false;
    if(PlayerTools.instance.currentSong.vdlist!=null){
      PlayerTools.instance.currentSong.vdlist.forEach((ele) {
        if(ele['video_id']==index)
        {
          ttt= true;
        }
      });
    }

    return ttt;
  }

  setControlls() {
    this.controls = [
      new Icon(Icons.skip_previous, color:_checkvdlistItem(PlayerTools.instance.currentSong.preid)? Colors.black54 :Colors.white70,size: 27,),
      PlayerTools.instance.currentState == AudioToolsState.isPlaying ? new Icon(Icons.pause_circle_outline, color: Colors.black54,size: 27,):new Icon(Icons.play_circle_outline, color: Colors.black54,size: 27,),
      new Icon(Icons.skip_next, color:_checkvdlistItem(PlayerTools.instance.currentSong.nextid) ? Colors.black54:Colors.white70,size: 27,),
      new Icon(Icons.menu, color: Colors.black54,size: 27,)
    ];


    /*
//    Colors.white
    this.controls = [
//      _getModeWidget(),
      new Icon(Icons.skip_previous, color: Colors.white,size: 27,),
      PlayerTools.instance.currentState == AudioToolsState.isPlaying ? new Icon(Icons.pause_circle_outline, color: Colors.white,size: 46,):new Icon(Icons.play_circle_outline, color: Colors.white,size: 46,),
      new Icon(Icons.skip_next, color: Colors.white,size: 27,),
//      new Icon(Icons.menu, color: Colors.white,size: 27,)
    ];*/
  }

  showMenu(BuildContext context) {

//    Navigator.push(context, MaterialPageRoute(
//        builder: (_) => MusicListPage())).then((value) {
//      if (value) {
//        this.loginedOrNot();
//      }
//    });
//    pageBuilder: (BuildContext context, _, __) => MusicListPage())).then((value) {
//    if (value) {
//    }
//    },
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
            return new FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          pageBuilder: (BuildContext context, _, __) => MusicListPage(_currentSong.vdlist,_currentSong),
        )
    ).then((value) {
      if (value) {
        this.notify();
      }
    });
  }

  notify() {
    notifyListeners();
  }


  Duration getTxtDuration(Map<String, dynamic> item) {
    Duration tempcurtDuration = Duration(seconds: 0);
    String vtype = PlayerTools.instance.currentSong.video['txt_type'] ?? 'txt';
    if (vtype == "txt" || vtype == "lrc") {
      List<String> dtime = item['st'].toString().split(":");
      if (dtime.length == 3) {
        tempcurtDuration = Duration(
            hours: int.tryParse(dtime[0]),
            minutes: int.tryParse(dtime[1]),
            milliseconds: vtype == 'txt'
                ? int.tryParse(dtime[2].replaceAll(",", "").trim())
                : (int.tryParse(dtime[2].split(".")[0]) * 1000 +
                int.tryParse(dtime[2].split(".")[1]) * 10));
      } else if (dtime.length == 2) {
        tempcurtDuration = Duration(
            minutes: int.tryParse(dtime[0]),
            milliseconds: vtype == 'txt'
                ? int.tryParse(dtime[1].replaceAll(",", "").trim())
                : (int.tryParse(dtime[1].split(".")[0]) * 1000 +
                int.tryParse(dtime[1].split(".")[1]) * 10));
      } else if (dtime.length == 1) {
        tempcurtDuration = Duration(
            milliseconds: vtype == 'txt'
                ? int.tryParse(dtime[0].replaceAll(",", "").trim())
                : (int.tryParse(dtime[0].split(".")[0]) * 1000 +
                int.tryParse(dtime[0].split(".")[1]) * 10));
      }
    }
//    _curtDuration = tempcurtDuration;
    return tempcurtDuration;
  }
}