import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/loading_gif.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';
import '../routers/application.dart';
import '../utils/screen_util.dart';
import '../utils/comUtil.dart';

class noticeMessgeList extends StatelessWidget {
  final List<Map<String, dynamic>> list;
  final String txt;
  final VoidCallback getNextPage;
  noticeMessgeList(this.txt,this.list, { this.getNextPage});
  @override
  Widget build(BuildContext context) {
    Widget imgtop;
   Widget maindd=
        list.length == 0
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text("空空如也"),
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemCount: list.length,
          itemExtent: 75,
          itemBuilder: (BuildContext context, int i) {
            Map<String, dynamic> item = list[i]['message'];
            if ((i + 3) == list.length) {
              getNextPage();
            }
            String titile=item['message_title'].toString();
            titile= titile.length<=12 ? titile : titile.substring(0,16)+"…";
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                color: KColorConstant.searchAppBarBgColor,
                padding: EdgeInsets.all(5),
                child:
                    InkWell(
                      onTap: (){ComFunUtil().alertMsg(context, item);},
                      child: ListTile(
                        title:  Text(item['message_title'],style: KfontConstant.bigfontSize,),
                        trailing: new Text(
                          ComFunUtil.getTimeDuration(item['send_time'].toString()),
                          style: KfontConstant.defaultStyle,
                        ),
                    )
                ,
                ),
              ),
            );
          },
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(txt),
      ),
      body: Center(
        child: maindd,
      ),
    );
  }
}
