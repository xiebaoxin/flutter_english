import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/base.dart';
import 'player_provide.dart';
import 'opacity_tap_widget.dart';
import '../../utils/comUtil.dart';
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
  Animation<double> animationNeedle;
  Animation<double> animationRecord;
  AnimationController controllerNeedle;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _provide ??= widget.provide;

    controllerNeedle = new AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animationNeedle =
        new CurvedAnimation(parent: controllerNeedle, curve: Curves.linear);

    controllerRecord = new AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    animationRecord =
        new CurvedAnimation(parent: controllerRecord, curve: Curves.linear);

    var s = PlayerTools.instance.stateSubject.listen((state) {
      if (state == AudioToolsState.isPlaying) {
        controllerNeedle.forward();
        controllerRecord.forward();
      } else {
        controllerNeedle.reverse();
        controllerRecord.stop(canceled: false);
      }
    });
    _subscriptions.add(s);

    animationRecord.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          PlayerTools.instance.currentState == AudioToolsState.isPlaying) {
        controllerRecord.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controllerRecord.forward();
      }
    });

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
    controllerNeedle.dispose();
    controllerRecord.dispose();
    ges_controller.dispose();
    _subscriptions.dispose();
    super.dispose();
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
      return  _provide.currentSong.video != null
            ? _setupContent()
            : Container(
          color: this.backgrd,
          child:new Stack(
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
        builder: (BuildContext context, Widget child, PlayerProvide value) {
      if (_provide.songProgress < 1000) _txtid = 0;
      if (PlayerTools.instance.duration > 0) {
        int newid = (_provide.currentSong.txtlist.length *
                (Duration(milliseconds: _provide.songProgress).inSeconds /
                    PlayerTools.instance.duration))
            .toInt();
        if (_txtid < (newid - 10)) {
          _txtid = (newid - 10);
        }
      }

      return Container(
        color: this.backgrd,
        child: Column(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _setupTop(),
            _setupMiddle(),
            _setupBottom(),
          ],
        ),
      );
    });
  }

  Provide<PlayerProvide> _setupTop() {
    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide value) {
          String titile=_provide.currentSong.video['video_name']  ?? "播放器";
      return new SafeArea(
          child: new Row(
        children: <Widget>[
          new Container(
            width: 50,
            child: new OpacityTapWidget(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: new Icon(
                Icons.close,
                color: this.fontcolor,
                size: 27,
              ),
            ),
          ),
//                  _provide.currentSong.title ?? ''
          new Expanded(
              child: new Text(
                titile.length<=20 ? titile : titile.substring(0,20)+"…",
            style: TextStyle(
                color: this.fontcolor,
                fontWeight: FontWeight.bold,
                fontSize: 18),
            textAlign: TextAlign.center,
          )),
          new Container(
            width: 50,
          ),
        ],
      ));
    });
  }

  Provide<PlayerProvide> _setupMiddle() {
    double widthd = MediaQuery.of(context).size.width;

    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide value) {
      return Expanded(
          flex: 7,
          child: Container(
            color: Colors.white30,
            width: widthd,
            child: _provide.currentSong.txtlist.length > 0
                ? buildTxt(_provide.currentSong.txtlist)
                : Text("抱歉，没有对应字幕文件！"),
          ));
    });
  }

  Widget buildTxt(List<Map<String, dynamic>> list) {
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
                  _txtid = i;
                  _offsetPositonn =
                      ((((_txtid * _maxscrlen) / list.length).toInt() / 100)
                                  .toInt() /
                              4)
                          .toInt();
                  _curtNextDuration = getTxtDuration(list[i + 1]);

                  _provide.seekmilscd(getTxtDuration(item).inSeconds);
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
                    _provide.currentSong.video['txt_type'] == 'txt'
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
                        : Divider(
                            height: 1,
                          ),
                  ],
                ),
              ));
        });
  }

  Duration getTxtDuration(Map<String, dynamic> item) {
    Duration tempcurtDuration = Duration(seconds: 0);
    String vtype = _provide.currentSong.video['txt_type'] ?? 'txt';
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

  void _goToElement(double index) {
    _scrollController.animateTo(
        (60.0 +
            index), // 100 is the height of container and index of 6th element is 5
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut);
  }

  Widget _setupBottom() {
    return  Expanded(
        flex: 2,
        child:
        Container(
          color: Colors.black12,
          child: Column(
            children: <Widget>[
              _setupSlide(), _setupControl(),
            ],
          ),
        )
    );;
  }

  Provide<PlayerProvide> _setupSlide() {
    return Provide<PlayerProvide>(
        builder: (BuildContext context, Widget child, PlayerProvide value) {
      if (_provide.songProgress > _curtNextDuration.inMilliseconds &&
          _txtid < _provide.currentSong.txtlist.length) {
        _txtid = _txtid + 1;
        _curtNextDuration =
            getTxtDuration(_provide.currentSong.txtlist[_txtid + 1]);

        if (_scrollController != null) {
          if (_scrollController.position != null) {
            _maxscrlen = _scrollController.position.maxScrollExtent ?? 1000.0;
            //当前大概位置,超过400就滚动一下
            double inndexoffset =
                (_txtid * _maxscrlen) / _provide.currentSong.txtlist.length;
            int tempidx = ((inndexoffset.toInt() / 100).toInt() / 4).toInt();
            if ((inndexoffset.toInt() / 100).toInt() % 4 == 0 &&
                tempidx > _offsetPositonn) {
              _offsetPositonn = tempidx;
              _goToElement(inndexoffset);
            }
          }
        }
      }

      return new Container(
//        color: Colors.green,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: new Row(
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

                if (_provide.currentSong.txtlist.length > 0 &&
                    _scrollController.position != null) {
                  _goToElement(endValue * _maxscrlen);

                  _txtid =
                      (_provide.currentSong.txtlist.length * endValue).toInt();
                  _offsetPositonn =
                      (((endValue * _maxscrlen).toInt() / 100).toInt() / 4)
                          .toInt();
                  _curtNextDuration =
                      getTxtDuration(_provide.currentSong.txtlist[_txtid + 1]);
                  _provide.seekmilscd(
                      getTxtDuration(_provide.currentSong.txtlist[_txtid])
                          .inSeconds);
                } else
                  _provide.seek(endValue);
              },
              semanticFormatterCallback: (newValue) {
                return '${newValue.round()} dollars';
              },
            )),
            new Text(
              _provide.songDuration(),
              style: TextStyle(color: this.fontcolor, fontSize: 12),
            ),
          ],
        ),
      );
    });
  }

  Widget _setupControl() {
    return new SafeArea(
        child: new Container(
//          color: Colors.red,
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _setupItems(),
      ),
    ));
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
