import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import '../components/loading_gif.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';
import '../routers/application.dart';
import '../utils/DialogUtils.dart';
import '../utils/comUtil.dart';
import '../utils/dataUtils.dart';
import '../utils/HttpUtils.dart';
import '../utils/screen_util.dart';
import '../model/userinfo.dart';

import 'person/address.dart';
import 'pay_page.dart';
import '../components/addplus.dart';

class CartsBuyPage extends StatefulWidget {
  @override
  GoodsBuyState createState() => new GoodsBuyState();
}

class GoodsBuyState extends State<CartsBuyPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController(); //listview的控制器

  TextEditingController _pwdcontroller = new TextEditingController();

  ShapeBorder _shape = GlobalConfig.cardBorderRadius;
  double _point_rate = 1.0;
  Userinfo _userinfo = Userinfo.fromJson({});

  int _count;
  num _money;

  bool _switchValue = false;
  bool _switchValueye = false;
  bool _switchValuejl = false;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<globleModel>(builder: (context, child, model) {
      return Scaffold(
          appBar: new AppBar(
            title: new Text('购物车确认'),
            centerTitle: true,
          ),
          body: Container(
              padding: EdgeInsets.all(5),
              child: Form(
                  //绑定状态属性
                  key: _formKey,
                  autovalidate: true,
                  child:_prebuyinfo!=null?
                  ListView.builder(
                    itemCount: _prebuyinfo['cartList'].length,
                    controller: _scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      if(index==0){
                        return Column(
                          children:[
                            dizhi(),
                            shuomin(_prebuyinfo['cartList'][0]),
                           _prebuyinfo['cartList'].length ==1 ? shuliang(): SizedBox(height: 5,),
                          ],
                        );
                      }else if(index==((_prebuyinfo['cartList'].length)-1)){
                        return Column(
                          children:[
                            shuomin(_prebuyinfo['cartList'][index]),
                            shuliang(),
                          ],
                        );
                      }else
                         return shuomin(_prebuyinfo['cartList'][index]);
                    },
                  )
                 :Text("加载中……")
                  )

              ),
          bottomNavigationBar: buildbottomsheet(
            context,
          ));
    });
  }

  Map<String, dynamic> _address;
  String _dee = "";
  Widget dizhi() {
    try {
      _dee = _address["consignee"];
    } catch (e) {
      _dee = "";
    }
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            ListTile(
                leading: Icon(Icons.location_city),
                title: _dee != ""
                    ? Text(
                        "${_address['consignee']}[${_address['mobile']}]",
                      )
                    : Text("请添加收获地址"),
                subtitle: _dee != ""
                    ? Text("${_address['address']}",
                        style: KfontConstant.defaultSubStyle)
                    : null,
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new AddressPage()),
                  ).then((v) {
                    _onRefreshAddress();
                  });
                }),
            Divider(
              height: 2,
            )
          ],
        ));
  }

  _onRefreshAddress() async {
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/ajaxAddress', {},
        withToken: true, context: context);
    if (response['status'].toString() == '1') {
      var dte = response['result'] as List;
      if (dte.length > 0) {
        setState(() {
          _address = response['result'][0];
        });
      }
    }
  }

  Widget shuomin(item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 85,
        child: Card(
          // This ensures that the Card's children (including the ink splash) are clipped correctly.
          clipBehavior: Clip.antiAlias,
          shape: _shape,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[

                    CachedNetworkImage(
                        errorWidget: (context, url, error) =>Container(
                            height: 75,
                            width: 75,
                            child:
                            Image.asset(
                              'images/logo_b.png',)),
                        placeholder: (context, url) => Loading(),
                        imageUrl:item['original_img'], //
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
                      ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(item['goods_name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: KfontConstant.defaultStyle),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 5,
                            ),
                            Text('￥${item['goods_price']}',
                                style: KfontConstant.defaultSubStyle),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              '数量：${item['goods_num'].toString()}',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(16, true),
                                color: Colors.black45,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget shuliang() {
    final ThemeData theme = Theme.of(context);
    return  Padding(
          padding: EdgeInsets.all(2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Center(
                  child: Row(
                    children: <Widget>[
                      Text(
                        "共${_count.toString()},",
                        style: KfontConstant.defaultStyle,
                      ),
                      Text(
                        "共需${_money.toString()}元",
                        style: KfontConstant.defaultStyle,
                      )
                    ],
                  ),
                ),
              ),
              Semantics(
                container: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "TML(${_userinfo.point.toStringAsFixed(4)},[${(_userinfo.point / _point_rate).toStringAsFixed(2)}元])",
                        style: KfontConstant.defaultSubStyle,
                      ),
                      Switch(
                        value: _switchValue,
                        activeColor: Colors.deepOrange,
                        onChanged: (bool value) {
                          setState(() {
                            _switchValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Semantics(
                container: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "现金卷(${_userinfo.money.toStringAsFixed(2)}元)",
                        style: KfontConstant.defaultSubStyle,
                      ),
                      Switch(
                        value: _switchValueye,
                        activeColor: Colors.deepOrange,
                        onChanged: (bool value) {
                          setState(() {
                            _switchValueye = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              Semantics(
                container: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "余额(${_userinfo.jiangli.toStringAsFixed(2)})",
                        style: KfontConstant.defaultSubStyle,
                      ),
                      Switch(
                        value: _switchValuejl,
                        activeColor: Colors.deepOrange,
                        onChanged: (bool value) {
                          setState(() {
                            _switchValuejl = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              payword(),
            ],
          ),
    );
  }

  Widget payword() {
    if (_switchValue || _switchValueye || _switchValuejl) {
      return TextField(
        controller: _pwdcontroller,
        cursorColor: GlobalConfig.mainColor,
        decoration: new InputDecoration(
          hintText: '请输入支付密码',
          contentPadding: EdgeInsets.all(10.0),
          suffixIcon: new IconButton(
            icon: new Icon(Icons.clear, color: GlobalConfig.mainColor),
            onPressed: () {
              _pwdcontroller.clear();
            },
          ),
        ),
        obscureText: true,
      );
    } else
      return const SizedBox(height: 2.0);
  }

  Widget buildbottomsheet(context) {
    if (_switchValue && _money >= (_userinfo.point / _point_rate))
      _money -= (_userinfo.point / _point_rate);
    if (_switchValueye && _money >= _userinfo.money) _money -= _userinfo.money;
    if (_switchValuejl && _money >= _userinfo.jiangli)
      _money -= _userinfo.jiangli;

    return Container(
      width: ScreenUtil.screenWidth,
      height: ScreenUtil().H(60),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: ScreenUtil().L(300),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "合计支付：${_money.toString()}元",
                style: KfontConstant.defaultStyle,
              ),
            ),
          ),
          Expanded(
              child: InkWell(
            onTap: () async {
              submit();
            },
            child: Container(
              alignment: Alignment.center,
              color: GlobalConfig.mainColor,
              child: Text(
                '提交订单',
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(16)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  var _prebuyinfo;
  Future _getdata() async {
    await _onRefreshAddress();
    await HttpUtils.dioappi('Cart/cart2', {}, withToken: true, context: context)
        .then((response) async{
      if (response['status'].toString() == "1") {
        if(response['result']!=null){
          if(response['result']['cartList']!=null){
            setState(() {
              _prebuyinfo = response['result'];
              _count = _prebuyinfo['cartPriceInfo']['goods_num'];
              _money = double.tryParse(
                  _prebuyinfo['cartPriceInfo']['total_fee'].toString()) ??
                  0;
            });
          }
        }

      } else{
        await DialogUtils.showToastDialog(context, response['msg']);
        Navigator.of(context).pop(false);
      }


    });
  }

  void submit() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      Map<String, String> params = {
        "pay_points": !_switchValue ? "" : _userinfo.point.toStringAsFixed(4),
        "user_money": _switchValueye ? _userinfo.money.toStringAsFixed(2) : "0",
        "user_jiangli":
            _switchValuejl ? _userinfo.jiangli.toStringAsFixed(2) : "0",
        "pay_pwd": (_switchValue || _switchValueye || _switchValuejl)
            ? _pwdcontroller.text
            : "",
        "address_id": _dee != '' ? _address['address_id'].toString() : "0",
      };
      Application().checklogin(context, () async {
        await HttpUtils.dioappi('Cart/cart3/act/submit_order', params,
                withToken: true, context: context)
            .then((response) async {
          if (response['status'].toString() == '1') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PayPage(response['result'].toString()),
              ),
            ).whenComplete(() async {
              await DataUtils.freshUserinfo(context);
            });
          } else
            await DialogUtils.showToastDialog(context, response['msg']);
        });
      });
    }
  }

  @override
  void initState() {
    _getdata();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
