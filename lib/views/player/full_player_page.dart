import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/base.dart';
import 'player_provide.dart';
import 'opacity_tap_widget.dart';
import '../../utils/comUtil.dart';
import '../../utils/DialogUtils.dart';
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

  int _txtid = -1;
  int _offsetPositonn = 0;
  Duration _curtNextDuration = Duration(seconds: 0);
  double _maxscrlen = 0.0;

  Color backgrd = Colors.white;
  Color fontcolor = Colors.black54;
  String _statustext = "准备开始…";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _provide ??= widget.provide;

    controllerRecord = new AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
/*
    animationRecord =
        new CurvedAnimation(parent: controllerRecord, curve: Curves.linear);
*/

    var s = PlayerTools.instance.stateSubject.listen((state) {
      print("----------- AudioToolsState.${state}--------------");
      if (state == AudioToolsState.isPlaying) {
        hideLoadingDialog();
        controllerRecord.forward();
        _statustext = "正在播放中……(点击字幕可以点读)";

      } else if (state == AudioToolsState.beginPlay) {
        controllerRecord.forward();
        _statustext = "播放准备…";
        _goToElement(0);
      } else if (state == AudioToolsState.isError) {
        controllerRecord.stop(canceled: false);
        _statustext = "出错了";
      } else if (state == AudioToolsState.isCacheing) {
        showLoadingDialog('加载中…');
        controllerRecord.stop();
        _statustext = "加载中…";
      } else if (state == AudioToolsState.isEnd) {
        controllerRecord.stop(canceled: false);
        _statustext = "已结束";
      } else {
        controllerRecord.stop(canceled: false);
        _statustext = "已停止";
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
      /*     if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
      }*/
    });
  }

  @override
  void dispose() {
    controllerRecord.dispose();
    ges_controller.dispose();
    _subscriptions.dispose();
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
          return Stack(
        children: <Widget>[
          _setupMiddle(),
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
                    Icons.close,
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

  Provide<PlayerProvide> _setupMiddle() {
    double widthd = MediaQuery.of(context).size.width;

    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide plyprvd) {
          _txtid = plyprvd.txtid;
//          print("------------------==${plyprvd.songProgress.toString()}======${plyprvd.txtid.toString()}========Provide=_setupMiddle==------------");
          return Padding(
        padding: const EdgeInsets.only(top: 90.0, bottom: 125),
        child: Container(
//          width: widthd,
          child: plyprvd.currentSong.txtlist.length > 0
              ? buildTxt(plyprvd)
              : Text("抱歉，没有对应字幕文件！"),
        ),
      );
    });
  }

  Widget buildTxt(PlayerProvide plyprvd) {
    List<Map<String, dynamic>> list=plyprvd.currentSong.txtlist;
    return ListView.builder(
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
                  _txtid =i;
                  plyprvd.settxtid=i;
                },
                child: Column(
                  children: <Widget>[
                    item['eng'] != null
                        ? Text(item['eng'],
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: _txtid == i
                                ? TextStyle(color: Colors.green, fontSize: 18)
                                : TextStyle(color: Colors.black45))
                        : SizedBox(
                            height: 1,
                          ),
                    plyprvd.currentSong.video['txt_type'] == 'txt'
                        ? item['cn'] != null
                            ? Text(item['cn'],
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: _txtid == i
                                    ? TextStyle(
                                        color: Color(0xFFFF9933), fontSize: 18)
                                    : TextStyle(color: Colors.black45))
                            : SizedBox(
                                height: 1,
                              )
                        : SizedBox(
                            height: 1,
                          ),
                  ],
                ),
              ));
        });
  }


  void _goToElement(double index) {
    if(_scrollController!=null){
      _scrollController.animateTo((index), // 100 is the height of container and index of 6th element is 5
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn);
    }

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
          _txtid=plyprvd.txtid;
      if (_scrollController != null) {
            if (_scrollController.position != null) {
              _maxscrlen = _scrollController.position.maxScrollExtent ?? 500.0;
              //当前大概位置,超过200就滚动一下
              double inndexoffset =
                  (plyprvd.txtid * _maxscrlen) / plyprvd.currentSong.txtlist.length;//当前节点位于这段中的位置
            if(inndexoffset>150 && inndexoffset<=_maxscrlen)
              _goToElement(inndexoffset);
//              print("-------${plyprvd.songProgress}-------_setupSlide--_txtid=$_txtid-----$_maxscrlen------$inndexoffset---_offsetPositonn$_tempidx-------");
            }
          }
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

                  if (plyprvd.currentSong.txtlist.length > 0 ) {
                  _txtid = (plyprvd.currentSong.txtlist.length * endValue)
                        .toInt();
                    plyprvd.settxtid=_txtid;

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
}
