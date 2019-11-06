import 'dart:ui';
import 'dart:async';
import 'dart:core';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Testfun extends StatefulWidget {
  FullPlayerContentState createState() => new FullPlayerContentState();
}

class FullPlayerContentState extends State<Testfun>{

  ScrollController _scrollController = ScrollController(); //listview的控制器
  int _txtid = -1;

  Color backgrd = Colors.white;
  Color fontcolor = Colors.black54;
  int _totalrows=0;
  double _rowhight=50; //行高
  int _maxnum=32;//一行多少个字符
  double _txtpostion=0;
  double _maxscrlen =1000.0;
  double _divhight=1000.0; //容器高度

  List<Map<String, dynamic>> _list=[];
  @override
  Widget build(BuildContext context) {
    return Material(
      child:Scaffold(
        backgroundColor: Colors.black26,
          body: Stack(
      children: <Widget>[
      buildTxt(),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(color: Color(0xdfeeeeee), child:  Container(height:80,
            width: MediaQuery.of(context).size.width,
            color: Colors.green,
            child:Text("hhh"),))),
      Positioned(
        bottom: 2,
        left: 0,
        right: 0,
        child: Container(child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(onPressed: (){
                _txtid =50;
                _goToElement(gettxtpositon(50));
              }, child: Text("50")),
            ),
            FlatButton(onPressed: (){
              _txtid =80;
              _goToElement(gettxtpositon(80));
            }, child: Text("80")),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(onPressed: (){
                _txtid =100;
                _goToElement(_maxscrlen);
              }, child: Text("底部")),
            ),
          ],
        )),
      )
      ],
    )
    ) ,
    ) ;
  }


  Widget buildTxt() {
    _divhight=MediaQuery.of(context).size.height;
    _rowhight=_divhight/27;//每一页大约27行
    _maxnum=32;//一行多少个字符
    _maxscrlen=_totalrows*_rowhight;//-_divhight
    print("---+++----------------总行数--$_totalrows---------------------+++---");
    return Container(
      width: 348,//方便计算长度 一行32个字符
      child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          shrinkWrap: true,
          itemCount: _list.length,
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int i) {
            Map<String, dynamic> item = _list[i];

            return Padding(
                padding: const EdgeInsets.all(0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      _txtid =i;
                      _goToElement(gettxtpositon(i));
                    },
                    child:
                        item['eng'] != null
                            ? Text(item['eng'],
                            style: _txtid == i
                                ? TextStyle(color: Colors.green, fontSize: 18)
                                : TextStyle(color: Colors.black45, fontSize: 18))
                            : SizedBox(
                          height: 1,
                        ),

                  ),
                ));
          }),
    );
  }

  Widget XbxText(String text,TextStyle txtstyle){
    _strlist=List();
    List<String> liststr=stritem(text);
    return Column(children:
      liststr.map((String str){
        return Text(str,style: txtstyle,);
    }).toList()
   );
  }


  List<String> _strlist=List();
  List<String> stritem(String str){
    int rlen=32;
    RegExp exp = new RegExp(r"[\u3000-\u301e\ufe10-\ufe19\ufe30-\ufe44\ufe50-\ufe6b\uff01-\uffee]|\s*$");
    int lidx=rlen-1;
    if(str.length>rlen){
      String str1=str.substring(0,lidx);
      if(exp.hasMatch(str[lidx])){
//      最后一个字母不是字符
        _strlist.add(str1);
      }else{
        int lastpt0=str1.lastIndexOf(exp); //最后一个非字母位置
        if(lastpt0>0){
          _strlist.add(str.substring(0,lastpt0));
          str=str.substring(lastpt0);
        }else{
          _strlist.add(str1);
          str=str.substring(rlen);
        }
        return stritem(str);
      }
    }else
      _strlist.add(str);
    return _strlist;
  }

  int _cindex=0;
  double _oldpos=0.0;
  void _goToElement(double pxt) async{
    if(_scrollController!=null){
      if(_txtid<1) _cindex=0;
      if ( pxt>_divhight/2   && _txtid!=_cindex) {
      setState(() {
        print("-==========------------------$pxt-------------------$_txtid----------======--");
        _cindex=_txtid;
        _scrollController.animateTo(pxt-_divhight/2, //(index-_oldpos).abs() 100 is the height of container and index of 6th element is 5
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear);
        _oldpos=pxt;
      });
      }
    }
  }

//  int _oldindex=1;
  double gettxtpositon(int index){
//    if(index==0)_oldindex=1;
//    if(_oldindex==index)
//      return _txtpostion;
//    else
//      _oldindex=index;
    double inndexoffset=0;
    double txtpostion=0;

    Map<String, dynamic> item;
    int txtstrlen=0;
    if(index>=0&& index<100){

      for(int i=0;i<index;i++){
        item = _list[i];
//       字段长度--》几行--》高度--》位置
        if(item['eng'] != null)  txtstrlen=item['eng'].toString().length;
//        if(item['cn'] != null)   txtstrlen+=item['cn'].toString().length;
//       计算占用高度，超过

        if(txtstrlen>_maxnum){
          txtpostion+=(txtstrlen/_maxnum).ceil();
        }else{
          txtpostion+=1;//一行
        }
      }
    }

    inndexoffset =txtpostion*_rowhight;//(txtpostion * _maxscrlen) / _totalrows;//当前节点位于这段中的位置
    print("---+++--总高度$_maxscrlen-[${_scrollController.position.pixels}]-----------当前位置$inndexoffset---------当前累计共$txtpostion行---------index-$index-------总$_totalrows---+++---");
    return inndexoffset;
  }


  void initdd(){
    int  i=0;
    String rt='';
    Map<String, dynamic> trt={};
    for(i>0;i<100;i++){
      rt=rt + i.toString();
      trt={'eng':rt};
      _list.add(trt);
    };
    int maxnum=30;//2*maxnum;

    Map<String, dynamic> item;
    int txtstrlen=0;
    for(int i=0;i<100;i++){
      item = _list[i];
//       字段长度--》几行--》高度--》位置
      if(item['eng'] != null)  txtstrlen=item['eng'].toString().length;
//        if(item['cn'] != null)   txtstrlen+=item['cn'].toString().length;
//       计算占用高度，超过

      if(txtstrlen>maxnum){
        _totalrows+=(txtstrlen/maxnum).ceil();
      }else{
        _totalrows+=1;//一行
      }
    }

  }

  @override
  void initState() {

    initdd();
    // TODO: implement initState
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      print("=======当前滑动位置=${_scrollController.position.pixels}===========$_txtid============");
      if (_scrollController.position.pixels == _scrollController.position.pixels) {
        print('滑动到了最底部');
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget( oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
//
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

}
