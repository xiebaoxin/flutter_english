import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/HttpUtils.dart';
import '../model/paylog_model.dart';

class payLogPage extends StatefulWidget {
  @override
  payLogPageState createState() => new payLogPageState();
}

class payLogPageState extends State<payLogPage> {
  List<PayLogCell> _payLogList = List();
  int _page = 1;
  bool loading = false;

  _loadData() async {
    if (loading) {
      return null;
    }
    loading = true;
    try {
    HttpUtils.apipost(context, 'Pay/payList/p/'+_page.toString(), {}, (response) {
      setState(() {
        print('=================Pay/payList======================');
        print(response);
        _page += 1;
        print(_page);
        if (response['data']['payList'].isNotEmpty) {
          if (_payLogList == null) {
            _payLogList =[];
          }
          response['data']['payList'].forEach((ele) {
            if (ele.isNotEmpty) {
              print(ele);
              _payLogList.add(PayLogCell.fromJson(ele));
            }
          });
        }
      });

      });
    } finally {
      loading = false;
    }


  }


  _getItem(PayLogCell subject) {
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
//                    电影名称
                    Text(
                      "卡号:${subject.orderNo}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      maxLines: 1,
                    ),
                    Divider(),
                    Text(
                      '交易金额：${subject.orderMoney}',
                      style: TextStyle(
                          fontSize: 16.0
                      ),
                    ),
//                    类型
                    Text(
                        "入账金额：${subject.orderBond}"
                    ),
//                    导演
                    Text(
                        '手续费：${subject.orderCharge}'
                    ),
                    Text(
                        '操作时间：${subject.orderTime}'
                    ),
                    Text(
                        '结果：${subject.status}'
                    ),
                    const SizedBox(height: 5.0),
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
    var length = _payLogList.length;
    return  ListView.builder(
//        itemCount: _payLogList.length,
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
        title: Text('交易记录'),
      ),
      body: Center(
        child: _getBody(),
      ),
    );
  }
}