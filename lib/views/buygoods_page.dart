import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import '../model/buy_model.dart';
import '../model/goods.dart';
import 'person/address.dart';
import 'pay_page.dart';
import '../components/addplus.dart';

class GoodsBuyPage extends StatefulWidget {
  final BuyModel buyparam;
  GoodsBuyPage(this.buyparam);

  @override
  GoodsBuyState createState() => new GoodsBuyState();
}

class GoodsBuyState extends State<GoodsBuyPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  ShapeBorder _shape = GlobalConfig.cardBorderRadius;
  double _point_rate = 1.0;
  Userinfo _userinfo = Userinfo.fromJson({});
  Map<String, dynamic> _geconfig={'rate':1.0,'max':0.0,'balance':0.0};

  int _count;
  int _optionValue=0;
/*
  bool _switchValue = false;
  bool _switchValuege = false;
  bool _switchValueye = false;
  bool _switchValuejl = false;*/

  Map<String, dynamic> _prebuyinfo = {};
  String _pwd = '';

  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);

    if (model.token != '') {
      _userinfo = model.userinfo;
      _point_rate = model.point_rate;
    }

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('确认订单'),
          centerTitle: true,
        ),
        body: Container(
            padding: EdgeInsets.all(5),
            child: Form(
              //绑定状态属性
                key: _formKey,
                autovalidate: true,
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      children: <Widget>[
                        dizhi(),
                        shuomin(),
                        shuliang(),
//                        const SizedBox(height: 10.0),
//                        queren()
                      ],
                    )))),
        bottomNavigationBar:
        buildbottomsheet(context, widget.buyparam.goodsinfo));
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.location_city),
                    title: Text(
                      _dee != ""
                          ? "${_address['consignee']}[${_address['mobile']}]"
                          : "请添加收获地址",
                      maxLines: 1,
                      softWrap:
                      true, //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: _dee != ""
                        ? Text("${_address['address']}",
                        maxLines: 1,
                        softWrap:
                        true, //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
                        overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
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

  Widget shuomin() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                  errorWidget: (context, url, error) => Container(
                      height: 75,
                      width: 75,
                      child: Image.asset(
                        'images/logo-灰.png',
                      )),
                  placeholder: (context, url) => Loading(),
                  imageUrl: widget.buyparam
                      .imgurl, //"http://testapp.hukabao.com:8008/public/upload/goods/thumb/236/goods_thumb_236_0_400_400.png",//
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
                          Text(widget.buyparam.goodsinfo.goodsName,
                              maxLines: 2,
                              softWrap:
                              true, //是否自动换行 false文字不考虑容器大小  单行显示   超出；屏幕部分将默认截断处理
                              overflow: TextOverflow.ellipsis,
                              style: KfontConstant.defaultStyle),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('￥${widget.buyparam.goods_price}',
                                  style: KfontConstant.defaultSubStyle),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: AddPlus(
                                    count: int.tryParse(widget.buyparam.goods_num),
                                    max:
                                    int.parse(widget.buyparam.goodsinfo.amount),
                                    callback: (v) {
                                      setState(() {
//                                      print(v);
                                        _count = v;
                                      });
                                    }),
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
    );
  }

  Widget shuliang() {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Semantics(
            container: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Card(
                  child: ListTile(
                      title: Text(
                        "直接支付",
                        style: KfontConstant.defaultSubStyle,
                      ),
                      trailing:  Radio(
                        value:0,
                        groupValue:_optionValue,
                        activeColor: Colors.blue,
                        onChanged:(v){
                          setState(() {
                            _optionValue = v;
                          });
                        },
                      )

                  )),
            ),
          ),
          _userinfo.point>0? Semantics(
            container: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Card(
                  child: ListTile(
                      title: Text(
                        "可用TML${_userinfo.point.toStringAsFixed(4)},[抵扣${(_userinfo.point / _point_rate).toStringAsFixed(2)}元]",
                        style: KfontConstant.defaultSubStyle,
                      ),
                      trailing:  Radio(
                        value:1,
                        groupValue:_optionValue,
                        activeColor: Colors.blue,
                        onChanged:(v){
                          setState(() {
                            _optionValue = v;
                          });
                        },
                      )
                    /*     Switch(
                  value: _switchValue,
                  activeColor: Colors.deepOrange,
                  onChanged: (bool value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),*/
                  )),
            ),
          ):SizedBox(height: 1,),

          _userinfo.money>0? Semantics(
              container: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Card(
                  child: ListTile(
                      title: Text(
                        "现金卷${_userinfo.money.toStringAsFixed(2)}元",
                        style: KfontConstant.defaultSubStyle,
                      ),
                      trailing: Radio(
                        value:3,
                        groupValue:_optionValue,
                        activeColor: Colors.blue,
                        onChanged:(v){
                          setState(() {
                            _optionValue = v;
                          });
                        },
                      )
                    /*   Switch(
                        value: _switchValueye,
                        activeColor: Colors.deepOrange,
                        onChanged: (bool value) {
                          setState(() {
                            _switchValueye = value;
                          });
                        },
                      )*/
                  ),
                ),
              )):SizedBox(height: 1,),
          _userinfo.jiangli>0? Semantics(
            container: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Card(
                child: ListTile(
                    title: Text(
                      "余额${_userinfo.jiangli.toStringAsFixed(2)}",
                      style: KfontConstant.defaultSubStyle,
                    ),
                    trailing: Radio(
                      value:4,
                      groupValue:_optionValue,
                      activeColor: Colors.blue,
                      onChanged:(v){
                        setState(() {
                          _optionValue = v;
                        });
                      },
                    )
                  /*   Switch(
                      value: _switchValuejl,
                      activeColor: Colors.deepOrange,
                      onChanged: (bool value) {
                        setState(() {
                          _switchValuejl = value;
                        });
                      },
                    )*/
                ),
              ),
            ),
          ):SizedBox(height: 1,),
        ],
      ),
    );
  }

  Widget queren() {
    num money = _prebuyinfo['total_amount'] ?? 0;
    if (_optionValue==1 && money >= (_userinfo.point / _point_rate))
      money -= (_userinfo.point / _point_rate);

    if (_optionValue==3 && money >= _userinfo.money) money -= _userinfo.money;
    if (_optionValue==4 && money >= _userinfo.jiangli)
      money -= _userinfo.jiangli;

   return Card(
      // This ensures that the Card's children are clipped correctly.
        clipBehavior: Clip.antiAlias,
        shape: _shape, //,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Text(
                  "合计支付：${money.toStringAsFixed(2)}元",
                  style: KfontConstant.defaultStyle,
                ),
                const SizedBox(height: 5.0),
                Text(
                  "说明文字",
                  style: KfontConstant.defaultSubStyle,
                ),
                const SizedBox(height: 10.0),
                ComFunUtil().buildMyButton(
                  context,
                  '立即支付并收货',
                      () {
                    submit();
                  },
                  width: 200,
//                disabled: _count > 0 ? false : true
                ),
                const SizedBox(height: 15.0),
              ],
            )));
  }

  Widget buildbottomsheet(context, GoodInfo goodsinfo) {
//    num money=double.tryParse(_prebuyinfo['total_amount'].toString())??0;
    num money = _count * widget.buyparam.goods_price;

    if (_optionValue==1 && money >= (_userinfo.point / _point_rate))
      money -= (_userinfo.point / _point_rate);

    if (_optionValue==3 && money >= _userinfo.money) money -= _userinfo.money;
    if (_optionValue==4 && money >= _userinfo.jiangli)
      money -= _userinfo.jiangli;

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
              child: Center(
                child: Row(
                  children: <Widget>[
                    Text(
                      "共${_count.toString()}件,",
                      style: KfontConstant.defaultStyle,
                    ),
                    Text(
                      "合计支付${money.toStringAsFixed(2)}元",
                      style: KfontConstant.defaultStyle,
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: InkWell(
                onTap: () async {
                  submit();
                },
                child:
                Container(
                  height: ScreenUtil().H(50),
                  width: 80,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Color(0xFFfe5400),
                    border: null,
                    gradient: const LinearGradient(
                        colors: [Colors.orange, Color(0xFFfe5400)]),
                    borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                  ),
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

  String _picurl = "";
  String _name = "";
  Future _getdata() async {
    await _onRefreshAddress();
//   print(_address);
//   print("=====================${_address['address_id']}===========================================");
    Map<String, String> params = {
      "goods_id": widget.buyparam.goods_id,
      "item_id": widget.buyparam.item_id,
      "goods_num": widget.buyparam.goods_num,
      "address_id": _address['address_id'].toString() ?? "0",
      "action": "buy_now" //立即购买
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'Cart/cart3', params,
        withToken: true, context: context);
//    {"status":1,"msg":"计算成功","result"://:'Cart/integralBuy'
// {"shipping_price":0,"coupon_price":0,"user_money":0,"integral_money":0,"pay_points":0,
// "order_amount":6,"total_amount":6,"goods_price":6,"total_num":3,"order_prom_amount":0}}
//    print(response);
    setState(() {
      _prebuyinfo = response['result'];
      _picurl = response['pic_url'];
      _name = response['name'];
    });
    return response['result'];
  }

  void submit() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      //      if (_switchValue || _switchValuege || _switchValueye || _switchValuejl) {
      if(_optionValue>0){
        if (_pwd.isEmpty) return ComFunUtil.getPassword(context, (String pwd) {
          setState(() {
            print("=====vv=$pwd===========");
            _pwd = pwd;
            submit();
          });
        });
      }
      DialogUtils.showLoadingDialog(context);
      form.save();
      Map<String, String> params = {
        "goods_id": widget.buyparam.goods_id,
        "item_id": widget.buyparam.item_id,
        "goods_num": widget.buyparam.goods_num,

        "pay_points":   _userinfo.point.toStringAsFixed(4) ,
        "money_type": _optionValue==2 ? "1" : "0",
        "user_money": _optionValue==3 ? _userinfo.money.toStringAsFixed(2) : "0",
        "user_jiangli":
        _optionValue==4 ? _userinfo.jiangli.toStringAsFixed(2) : "0",
        "pay_pwd": _pwd,
        "address_id": _dee != '' ? _address['address_id'].toString() : "0",
        "action": "buy_now" //立即购买
      };

/*      Map<String, String> params = {
        "goods_id": widget.buyparam.goods_id,
        "item_id": widget.buyparam.item_id,
        "goods_num": widget.buyparam.goods_num,
        "pay_points":!_switchValuege ? (!_switchValue ? "" : _userinfo.point.toStringAsFixed(4)): _userinfo.ge.balance.toStringAsFixed(4),
        "money_type": _switchValuege ? "1" :"0",
        "user_money": _switchValueye ? _userinfo.money.toStringAsFixed(2) : "0",
        "user_jiangli":
            _switchValuejl ? _userinfo.jiangli.toStringAsFixed(2) : "0",
        "pay_pwd": _pwd,
        "address_id": _dee != '' ? _address['address_id'].toString() : "0",
        "action": "buy_now" //立即购买
      };*/
      Application().checklogin(context, () async {
        await HttpUtils.dioappi('Cart/cart3/act/submit_order', params,
            withToken: true, context: context)
            .then((response) async {
          Navigator.of(context).pop();
          if (response['status'].toString() == '1') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PayPage(response['result'].toString()),
              ),
            ).whenComplete(() async {
              await DataUtils.freshUserinfo(context);
            });
          } else{
            await DialogUtils.showToastDialog(context, response['msg']);
            _pwd='';
          }

        });
      });
    }
  }

  @override
  void initState() {
    _count = int.tryParse(widget.buyparam.goods_num);
    _getdata();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
