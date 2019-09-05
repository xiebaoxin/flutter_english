import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../utils/comUtil.dart';
import '../../utils/screen_util.dart';
import '../../model/globle_model.dart';
import '../../model/userinfo.dart';
import '../../utils/HttpUtils.dart';
import 'recharge.dart';
import 'withdrawal.dart';
import '../../globleConfig.dart';

class BalanceButiePage extends StatelessWidget {

  Userinfo userinfo = Userinfo.fromJson({});
  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);
    userinfo=model.userinfo;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('补贴'),
        ),
        body: Center(child:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: _getdata(context),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    //snapshot就是_calculation在时间轴上执行过程的状态快照
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return new Text(
                            'Press button to start'); //如果_calculation未执行则提示：请点击开始
                      case ConnectionState.waiting:
                        return  Scaffold(
                            body:Column(
                              children: <Widget>[
                                SizedBox(height: 100,),
                                Text(
                                    '请稍候，正在加载...'),
                              ],
                            )); //如果_calculation正在执行则提示：加载中
                      default: //如果_calculation执行完毕
                        if (snapshot.hasError) //若_calculation执行出现异常
                          return new Text('Error: ${snapshot.error}');
                        else {
                          if (snapshot.hasData) {
                            Map<String, dynamic> acountinfo = snapshot.data;

                            return   Container(
                              width: ScreenUtil.screenWidthDp,
                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text("总额：${acountinfo['count0'].toStringAsFixed(2)}：",style: KfontConstant.bigfontSize,),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text("已提：${acountinfo['count1'].toStringAsFixed(2)}：",style: KfontConstant.bigfontSize,),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text("余额：${(acountinfo['count0']-acountinfo['count1']).toStringAsFixed(2)}：",style: KfontConstant.bigfontSize,),
                                    ),
                                    const SizedBox(height: 10.0),
                                    /*          ComFunUtil().buildMyButton(context, '充值', () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new reChargePage()),
                    ).then((response) async {

                    });
                  },),*/
                                    const SizedBox(height: 10.0),
                                    ComFunUtil().buildMyButton(context, '转余额', () {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) => new WithdrawalPage(type: 1,max: acountinfo['count0']-acountinfo['count1'],)),
                                      ).then((response) async {
//                      disabled: _userinfo.money >0.0 ? false : true
                                      });
                                    }, ),
                                    const SizedBox(height: 10.0),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(child: Container(child: Text("加载中")) ,
                            );
                          }
                        }
                    }
                  },
                )
    ))

    );


  }


  Future _getdata(BuildContext context) async {
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/getUserFarmAcount/type/1', {},
        context: context,withToken: true);
    return response;
  }

}