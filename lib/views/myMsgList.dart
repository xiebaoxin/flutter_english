import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/HttpUtils.dart';
import '../model/msg_model.dart';

class myMsgListPage extends StatefulWidget {
  @override
  myMsgListPagePageState createState() => new myMsgListPagePageState();
}

class myMsgListPagePageState extends State<myMsgListPage> {
  List<MyMsgCell> _payLogList = List();
  int _page = 1;
  bool loading = false;
  List<String> _yesIds = List();

  _loadData() async {
    if (loading) {
      return null;
    }
    loading = true;
    try {
    await HttpUtils.apipost(context, 'User/newsList/p/'+_page.toString(), {}, (response) {
      setState(() {
        print(response);
        _page += 1;
        print(_page);
        if (response['data']['newsList'].isNotEmpty) {
          if (_payLogList == null) {
            _payLogList =[];
          }
          response['data']['newsList'].forEach((ele) {
            if (ele.isNotEmpty) {
              print(ele);
              _payLogList.add(MyMsgCell.fromJson(ele));
            }
          });
        }
      });

      });
    } finally {
      loading = false;
    }
  }

  _getItem(MyMsgCell subject)  {
    var row = InkWell(
      onTap:()async{
        setState(() {
          if( _yesIds.indexOf(subject.id) < 0)
            _yesIds.add(subject.id);
          else
            _yesIds.removeLast();
        });

        } ,
      child: Container(
        margin: EdgeInsets.all(4.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "主题:${subject.title} ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        maxLines: 1,
                      ),
                    Divider(),

                          _yesIds.indexOf(subject.id) < 0
                          ?
                          const SizedBox(height: 5.0)
                          :
                          Column(
                            children: <Widget>[
                              Text(
                            '${subject.content}',
                            style: TextStyle(
                                fontSize: 16.0,
                            ),
                            maxLines: 8,
                          ),
                            Divider(),

                            ],
                      ),//

                      Text(
                          '时间：${subject.createtime}'
                      ),
                      const SizedBox(height: 5.0),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    )
    ;
    return Card(
      child: row,
    );
  }

  _getBody() {
    var length = _payLogList.length;
    return  ListView.builder(
//        itemCount: _payLogList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index >= length) {
          return null;
        }else{
          return _getItem(_payLogList[index]);
        }
      },
    );

  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知公告'),
      ),
      body: Center(
        child: _getBody(),
      ),
    );
  }
}