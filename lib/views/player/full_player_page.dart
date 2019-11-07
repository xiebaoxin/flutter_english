import 'dart:ui';
import 'dart:io';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/base.dart';
import 'player_provide.dart';
import 'opacity_tap_widget.dart';
import '../../utils/comUtil.dart';
import '../../utils/DialogUtils.dart';
import '../../utils/screen_util.dart';
import 'audio_tool.dart';
import 'player_tool.dart';

class FullPlayerPage extends PageProvideNode {
  PlayerProvide provide = PlayerProvide();

  FullPlayerPage() {
    mProviders.provide(Provider<PlayerProvide>.value(provide));
  }

  @override
  Widget buildContent(BuildContext context) {
    return _FullPlayerContentPage(provide);
  }
}

class _FullPlayerContentPage extends StatefulWidget {
  PlayerProvide provide;

  _FullPlayerContentPage(this.provide);

  @override
  State<StatefulWidget> createState() {
    return _FullPlayerContentState();
  }
}

class _FullPlayerContentState extends State<_FullPlayerContentPage>
    with TickerProviderStateMixin {
  PlayerProvide _provide;
//  Animation<double> animationNeedle;
  Animation<double> animationRecord;
//  AnimationController controllerNeedle;
  AnimationController controllerRecord;
  final _rotateTween = new Tween<double>(begin: -0.05, end: 0);
  final _commonTween = new Tween<double>(begin: 0.0, end: 1.0);

  AnimationController ges_controller;
  CurvedAnimation ges_curve;
  Animation<double> ges_animation;

  final _subscriptions = CompositeSubscription();
  ScrollController _scrollController = ScrollController(); //listview的控制器

  int _txtid = 0;
  int _totalrows = 0;

  int _maxnum = 38; //一行多少个字符
//  _maxnum=2*(342/18).toInt();//(348/(ScreenUtil.textScaleFactory*18)).toInt();//一行多少个字符

  double _maxscrlen = 600.0;
  double _divhight = 540.0; //容器高度
  double _rowhight = 20; //行高

  Color backgrd = Colors.white;
  Color fontcolor = Colors.black54;
  String _statustext = "准备开始…";
//  FlutterDriver driver;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        backgroundColor: this.backgrd, // Color.fromRGBO(0, 0, 0, 0),
        body: _buildGesture());
  }

  Provide<PlayerProvide> _buildGesture() {
    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide value) {
      return new GestureDetector(
        onVerticalDragUpdate: (offset) {
          _provide.offsetY += offset.delta.dy;
        },
        onVerticalDragEnd: (offset) {
          if (_provide.offsetY > MediaQuery.of(context).size.height * 0.4) {
            animationToBottom();
          } else {
            this.animationToTop();
          }
        },
        child: new Transform.translate(
          offset: Offset(0, (_provide.offsetY >= 0.0 ? _provide.offsetY : 0.0)),
          child: _buildView(),
        ),
      );
    });
  }

  animationToTop() {
    ges_animation = Tween(begin: _provide.offsetY, end: 0.0).animate(ges_curve)
      ..addListener(() {
        _provide.offsetY = ges_animation.value;
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {}
      });
    ges_controller.forward(from: 0);
  }

  animationToBottom() {
    ges_animation =
        Tween(begin: _provide.offsetY, end: MediaQuery.of(context).size.height)
            .animate(ges_curve)
              ..addListener(() {
                _provide.offsetY = ges_animation.value;
              })
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  Navigator.of(context).pop();
                }
              });
    ges_controller.forward(from: 0);
  }

  Provide<PlayerProvide> _buildView() {
    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide value) {
      return _provide.currentSong != null
          ? _setupContent()
          : Container(
              color: this.backgrd,
              child: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset('images/disc.png'),
//                _setupContent()
                ],
              ),
            );
    });
  }

  Provide<PlayerProvide> _setupContent() {
    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide plyprvd) {
          _txtid = plyprvd.txtid;
          _goToElement(gettxtpositon());

          return Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 90.0, bottom: 125),
            child: Center(
              child: plyprvd.currentSong.txtlist != null
                  ? buildTxt(plyprvd)
                  : Text("抱歉，没有对应字幕文件！"),
            ),
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(color: Color(0xdfeeeeee), child: _setupTop())),
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Container(child: _setupBottom()),
          )
        ],
      );
    });
  }

  Provide<PlayerProvide> _setupTop() {
    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide value) {
      String titile = _provide.currentSong.video['video_name'] ?? "播放器";
      return new SafeArea(
          child: Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new Container(
              width: 40,
              child: new OpacityTapWidget(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Icon(
                    Icons.headset,
                    color: this.fontcolor,
                    size: 27,
                  ),
                ),
              ),
            ),
//                  _provide.currentSong.title ?? ''
            Expanded(
                child: Text(
              titile,
              softWrap: true, //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: this.fontcolor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ));
    });
  }

  int _jtindx=0;
  Widget buildTxt(PlayerProvide plyprvd) {
    List<Map<String, dynamic>> list = plyprvd.currentSong.txtlist;
    if (_totalrows == 0) {
      _totalrows = getTotalCols(list);
    }
    _maxscrlen = _totalrows * _rowhight;

  if( _jtindx!=_txtid){
    _jtindx=_txtid;
    if (_jtindx > list.length-1)
      _jtindx = list.length-1;
  }

    return Container(
        color: Colors.amber,
        height: _divhight,
        width: 348, //方便计算长度 一行32个字符
        child: ListView.builder(
//        padding: EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            itemCount: list.length,
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            itemBuilder: (BuildContext context, int i) {
              Map<String, dynamic> item = list[i];
              return Padding(
                  padding: const EdgeInsets.all(0),
                  child: GestureDetector(
                    onTap: () {
                      if (PlayerTools.instance.currentState !=
                          AudioToolsState.isEnd) {
                        if(i<_jtindx && i>0){
                          _txtid = i-1;
                          plyprvd.settxtid = i-1;
                        }else{
                          _txtid = i;
                          plyprvd.settxtid = i;
                        }

                        _goToElement(gettxtpositon());
                      } else {
                        plyprvd.play();
                      }
                    },
                    child: Column(
//                  mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      key: Key('item_${i.toString()}_text'),
                      children: <Widget>[
                        item['eng'].toString().length > 0
                            ? XbxText(item['eng'],
                                style: _jtindx == i
                                    ? TextStyle(
                                        color: Colors.green, fontSize: 18)
                                    : TextStyle(
                                        color: Colors.black45, fontSize: 18))
                            : SizedBox(
                                height: 0.1,
                              ),
                        plyprvd.currentSong.video['txt_type'] == 'txt'
                            ? item['cn'].toString().length > 0
                                ? XbxCnText(item['cn'],
                                    style: _jtindx == i
                                        ? TextStyle(
                                            color: Color(0xFFFF9933),
                                            fontSize: 16)
                                        : TextStyle(
                                            color: Colors.black45,
                                            fontSize: 16))
                                : SizedBox(
                                    height: 1,
                                  )
                            : SizedBox(
                                height: 0.1,
                              ),
                      ],
                    ),
                  ));
            }));
  }

  Widget _setupBottom() {
    return Container(
      height: 121,
      color: Color(0xdfcccccc),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _setupSlide(),
          Text(
            _statustext,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          _setupControl(),
        ],
      ),
    );
  }

  Provide<PlayerProvide> _setupSlide() {
    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide plyprvd) {
          _txtid = plyprvd.txtid;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 30,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            children: <Widget>[
              new Text(
                ComFunUtil.dealDuration(_provide.songProgress.toString(),
                    ismil: true),
                style: TextStyle(color: this.fontcolor, fontSize: 12),
              ),
              new Expanded(
                  child: Slider(
                activeColor: this.fontcolor,
                inactiveColor: Colors.grey,
                value: _provide.sliderValue(),
                min: 0,
                max: 1,
                onChanged: (newValue) {
                  print('onChanged:$newValue');
                },
                onChangeStart: (startValue) {
                  print('onChangeStart:$startValue');
                },
                onChangeEnd: (endValue) {
                  print('onChangeEnd:$endValue');
                  if (plyprvd.currentSong.txtlist.length > 0) {
                    _txtid =
                        (plyprvd.currentSong.txtlist.length * endValue).toInt();
                    plyprvd.settxtid = _txtid;
                  } else
                    plyprvd.seek(endValue);
                },
                semanticFormatterCallback: (newValue) {
                  return "${newValue.round()}---- ${_txtid}";
                },
              )),
              new Text(
                plyprvd.songDuration(),
                style: TextStyle(color: this.fontcolor, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _setupControl() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _setupItems(),
      ),
    );
  }

  List<OpacityTapWidget> _setupItems() {
    return new List<OpacityTapWidget>.generate(
        4, (int index) => _setupItem(index));
  }

  Widget _setupItem(int index) {
    return new OpacityTapWidget(
      onTap: () {
        /*  if (index == 0) {
          _provide.changeMode();
        }*/
        if (index == 0) {
          _provide.pre();
        }
        if (index == 1) {
          _provide.play();
        }
        if (index == 2) {
          _provide.next(context);
        }
        if (index == 3) {
          _provide.showMenu(context);
        }
      },
      child: _provide.controls[index],
    );
  }

  @override
  void initState() {
    super.initState();
    _provide ??= widget.provide;

    controllerRecord = new AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
/*
    animationRecord =
        new CurvedAnimation(parent: controllerRecord, curve: Curves.linear);
*/

    var s = PlayerTools.instance.stateSubject.listen((state) {
//      print("----------- AudioToolsState.${state}--------------");
      if (state == AudioToolsState.isPlaying) {
        hideLoadingDialog();
        controllerRecord.forward();
        _statustext = "正在播放中……(点击字幕可以点读)";
      } else if (state == AudioToolsState.beginPlay) {
        showLoadingDialog("加载中");
        controllerRecord.forward();
        _statustext = "播放准备…";
        _totalrows = 0;
        _txtid = 0;
        _cindex = 0;
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
      } else if (state == AudioToolsState.isError) {
        hideLoadingDialog();
        controllerRecord.stop(canceled: false);
        _statustext = "出错了";
      } else if (state == AudioToolsState.isCacheing) {
        showLoadingDialog('加载中…');
        controllerRecord.stop();
        _statustext = "加载中…";
      }
      /*   else if (state == AudioToolsState.isEnd) {
        hideLoadingDialog();
        controllerRecord.stop(canceled: false);
        _statustext = "已结束";

        _totalrows=0;
        _txtid=0;
        _cindex=0;
        _scrollController.animateTo(0,duration: const Duration(milliseconds: 200), curve: Curves.linear);

      }*/
      else {
        controllerRecord.stop(canceled: false);
        hideLoadingDialog();
        _statustext = "已停止";

        _totalrows = 0;
        _txtid = 0;
        _cindex = 0;
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
      }
      hideLoadingDialog();
      setState(() {
        ;
      });
    });

    _subscriptions.add(s);

/*
    animationRecord.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          PlayerTools.instance.currentState == AudioToolsState.isPlaying) {
        controllerRecord.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controllerRecord.forward();
      }
    });
*/

    ges_controller = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    ges_curve =
        new CurvedAnimation(parent: ges_controller, curve: Curves.linear);

    _scrollController = new ScrollController();
    _scrollController.addListener(() {
//      print( "-==========-----addListener---  scrollController.position:----------${_scrollController.position.pixels}-------------------$_txtid----------======--");

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部$_txtid');
      }
    });
  }

  @override
  void dispose() {
    controllerRecord.dispose();
    ges_controller.dispose();
    _subscriptions.dispose();
//    if (driver != null) {
//       driver.close();
//    }
    super.dispose();
  }

  bool _loading = false;
  // 显示加载进度条
  void showLoadingDialog(String msg) async {
    if (!_loading) {
      setState(() {
        _loading = true;
      });

      await DialogUtils.showLoadingDialog(context, text: msg);
    }
  }

  // 隐藏加载进度条
  hideLoadingDialog() {
    if (_loading) {
      Navigator.of(context).pop();
      setState(() {
        _loading = false;
      });
    }
  }

  int _cindex = 0;
  void _goToElement(double pxt) async {
    if (_scrollController != null) {
      if ( _txtid != _cindex &&  _jtindx < PlayerTools.instance.currentSong.txtlist.length-2) {
        _cindex = _txtid;
        _scrollController.animateTo(pxt - 60,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
      }
    }
  }

  double gettxtpositon() {
    int txtrows = 0;
    Map<String, dynamic> item;
    if (_txtid >= 0 && _txtid < PlayerTools.instance.currentSong.txtlist.length) {
      for (int i = 0; i <= _txtid; i++) {
        item = PlayerTools.instance.currentSong.txtlist[i];

        if (item['eng'] != null) {
          if (item['eng'].toString().length > 0) {
            _strlist = List();
            txtrows += Str2Item(item['eng'].toString()).length;
          }
        }
        if (item['cn'] != null) {
          if (item['cn'].toString().length > 0) {
            _strlist = List();
            txtrows += StrCn2Item(item['cn'].toString()).length;
          }
        }
      }
    }
    if(_txtid >= PlayerTools.instance.currentSong.txtlist.length)
      return _maxscrlen;

    double inndexoffset = txtrows * _rowhight;
//    print("---+++--总高度$_maxscrlen------当前位置$inndexoffset------当前段累计共$txtrows行------index-$index-------总$_totalrows---+++---");
    return inndexoffset;
  }

  Widget XbxText(String text, {TextStyle style = null}) {
    _strlist = List();
    List<String> liststr = Str2Item(text);
    return Column(
        children: liststr.map((String str) {
      return Container(
        height: _rowhight,
        child: Text(
          str,
          style: style,
        ),
      );
    }).toList());
  }

  Widget XbxCnText(String text, {TextStyle style = null}) {
    _strlist = List();
    List<String> liststr = StrCn2Item(text);
    return Column(
        children: liststr.map((String str) {
      return Text(
        str,
        style: style,
      );
    }).toList());
  }

  /**
   * 拆分行
   */
  List<String> _strlist = List();
  List<String> Str2Item(String str) {
    int rlen = _maxnum;
    RegExp exp = new RegExp(r"(\W)");
    int lidx = rlen - 1;
    if (str.length > rlen) {
      String str1 = str.substring(0, lidx);
      if (exp.hasMatch(str[lidx])) {
//      最后一个字母不是字符,可以换行
        _strlist.add(str1);

        str = str.substring(lidx + 1);
        return Str2Item(str);
      } else {
        int lastpt0 = str1.lastIndexOf(exp); //最后一个非字母位置
        if (lastpt0 > 0) {
          _strlist.add(str.substring(0, lastpt0));
          str = str.substring(lastpt0 + 1);
        } else {
          _strlist.add(str1);
          str = str.substring(rlen);
        }
        return Str2Item(str);
      }
    } else
      _strlist.add(str);
    return _strlist;
  }

  /**
   * 中文
   */
  List<String> StrCn2Item(String str) {
    int rlen = (_maxnum / 2).toInt();
    if(str!=''){
      String str1=byteCut(str,rlen);
      _strlist.add(str1);
       str=str.replaceFirst(str1, "");
      return StrCn2Item(str);
    }

    return _strlist;

  }

  int getTotalCols(List<Map<String, dynamic>> list) {
    int totalrows = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i]['eng'] != null) if (list[i]['eng'].toString().length > 0) {
        _strlist = List();
        totalrows += Str2Item(list[i]['eng'].toString()).length;
      }

      if (list[i]['cn'] != null) {
        if (list[i]['cn'].toString().length > 0) {
          _strlist = List();
          totalrows += StrCn2Item(list[i]['cn'].toString()).length;
        }
      }
    }
    return totalrows;
  }

  String byteCut (String str, int n) {      // str： 被截取字符串；n：截取长度else {
    int len = 0;
    String tmpStr = '';
    for (int i = 0; i < str.length; i++) { // 遍历字符串
      if (RegExp(r"/[\u4e00-\u9fa5]/").hasMatch(str[i])) { // 判断为中文  长度为三字节（可根据实际需求更换长度，将所加长度更改即可）
    len += 3;
    } else {  // 其余则长度为一字节
    len += 1;
    }
    if (len > n) { // 当长度大于传入的截取长度时，退出循环
    break;
    } else {
    tmpStr += str[i]; // 将每个长度范围内的字节加入到新的字符串中
    }
  }
    return tmpStr;    // 返回截取好的字符串
  }

}
