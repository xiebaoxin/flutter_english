import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/HttpUtils.dart';
import '../../model/paylog_model.dart';

class WithdrawalsLogPage extends StatefulWidget {
  final int type;
  WithdrawalsLogPage({Key key, this.type =0}) : super(key: key);
  @override
  WithdrawalsPageState createState() => new WithdrawalsPageState();
}

class WithdrawalsPageState extends State<WithdrawalsLogPage> {
  ScrollController _scrollController = ScrollController(); //listview的控制器
  int _type=0;
  int _page = 1;
  bool loading = false;
  List<Map<String, dynamic>> _payLogList = List();
  _loadData() async {
    if (loading) {
      return null;
    }
    loading = true;
    try {
      await HttpUtils.dioappi('User/withdrawals_list/type/${widget.type}/p/${_page.toString()}/stt/${_type.toString()}"', {},
          withToken: true, context: context)
          .then((response) async {
        setState(() {
          if (response['result'].isNotEmpty) {
            _page += 1;
            response['result'].forEach((ele) {
              if (ele.isNotEmpty) {
                Map<String, dynamic> itemmap=ele;
                _payLogList.add(itemmap);
              }
            });
          }
        });
      });

    } finally {
      loading = false;
    }
  }

  _getItem(Map<String, dynamic> subject) {
    var row = Container(
      margin: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      trailing: Text(
                        '${subject['plus']==0?"+":"-"} ${subject['amount']}',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        maxLines: 8,
                      ),
                      title:  Text(
                        "${subject['desc']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        maxLines: 1,
                      ),
                      subtitle: Text(
                          '时间：${subject['create_time']}'
                      ),
                    ),

                  ],
                ),
              )
          )
        ],
      ),
    );
    return Card(
      child: row,
    );
  }

  _getBody() {
    int length = _payLogList.length??0;
    return _payLogList.isNotEmpty? ListView.builder(
        itemCount: _payLogList.length,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          if (index == length) {
            _loadData();
            return new Center(
              child: new Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 32.0,
                height: 32.0,
                child: const CircularProgressIndicator(),
              ),
            );
          } else if (index > length) {
            return null;
          }else{
            return _getItem(_payLogList[index]);
          }
        },
    ):
    Center(
      child: Text("什么都没有"),
    );

  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
        _loadData();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提现记录'),
      ),
      body: Center(
        child: _getBody(),
      ),
    );
  }
}