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
import 'person/address.dart';
import 'pay_page.dart';

class GoodsBuyPage extends StatefulWidget {
  final BuyModel buyparam;
  GoodsBuyPage(this.buyparam);

  @override
  GoodsBuyState createState() => new GoodsBuyState();
}

class GoodsBuyState extends State<GoodsBuyPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _pwdcontroller = new TextEditingController();

  ShapeBorder _shape = GlobalConfig.cardBorderRadius;

  Userinfo _userinfo = Userinfo.fromJson({});

  double _point_rate=1.0;
  bool _switchValue = false;
  bool _switchValueye = false;
  bool _switchValuejl = false;
  Map<String, dynamic> _prebuyinfo = {};

  @override
  Widget build(BuildContext context) {
    final model = globleModel().of(context);

    if (model.token != '') {
      _userinfo = model.userinfo;
      _point_rate=model.point_rate;
    }

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('订单确认'),
          centerTitle: true,
        ),
        body: Container(
            padding: EdgeInsets.all(5),
            child: Form(
                //绑定状态属性
                key: _formKey,
                autovalidate: true,
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: <Widget>[
                        shuomin(),
//                        dizhi(),
                        shuliang(),
                        const SizedBox(height: 10.0),
                        queren()
                      ],
                    )
                    ))));
  }


  Map<String, dynamic> _address;
  String _dee="";

  Widget dizhi() {

    try{
      _dee=   _address["consignee"];
    }
    catch(e){
      _dee="";
    }
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          // This ensures that the Card's children are clipped correctly.
            clipBehavior: Clip.antiAlias,
            shape: _shape, //,
            child: Padding(
                padding: EdgeInsets.all(5),
                child: ListTile(
                    leading: Icon(Icons.location_city),
                    title: _dee!="" ?Text(
                      "${_address['consignee']}[${_address['mobile']}]",
                    ):Text("请添加收获地址"),
                    subtitle: _dee!="" ?Text("${_address['address']}",
                        style: KfontConstant.defaultSubStyle):null,
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new AddressPage()),
                      ).then((v) {
                        _onRefreshAddress();
                      });
                    })

            )))
    ;
  }

  _onRefreshAddress() async {
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'User/ajaxAddress', {},
        withToken: true, context: context);
    if (response['status'].toString() == '1') {
      var dte=response['result'] as List;
      if(dte.length>0){
        setState(() {
          _address = response['result'][0];
        });
      }

    }
  }

  Widget shuomin() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:  Card(
            // This ensures that the Card's children (including the ink splash) are clipped correctly.
            clipBehavior: Clip.antiAlias,
            shape: _shape,
            child: Center(
              child: Stack(
                children: <Widget>[
                  Container(
                    width:ScreenUtil.screenWidthDp ,
                    child: Center(
                      child: CachedNetworkImage(
                        errorWidget: (context, url, error) =>Container(
                            height: 75,
                            width: 75,
                            child:
                            Image.asset(
                              'images/logo_b.png',)),
                        placeholder: (context, url) =>  Loading(),
                        imageUrl: widget.buyparam.imgurl,
                        width: ScreenUtil().L(100),
                        height: ScreenUtil().L(100),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: ScreenUtil().L(5),
                    left: ScreenUtil().L(20),
                    child: Text(_name)),
                ],
              ),
            ),
      ),
    );
  }

  Widget shuliang() {
    final ThemeData theme = Theme.of(context);
    return Card(
        // This ensures that the Card's children are clipped correctly.
        clipBehavior: Clip.antiAlias,
        shape: _shape, //,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Row(
                    children: <Widget>[
                      Text(
                        "共${_prebuyinfo['total_num']},",
                        style: KfontConstant.defaultStyle,
                      ),
                      Text(
                        "共需${_prebuyinfo['order_amount']}元",
                        style: KfontConstant.defaultStyle,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 2.0),
                Semantics(
                  container: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "使用积分(${_userinfo.point.toStringAsFixed(4)},[${(_userinfo.point/_point_rate).toStringAsFixed(2)}元])",
                        style: KfontConstant.defaultSubStyle,
                      ),
                      CupertinoSwitch(
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
                const SizedBox(height: 2.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "可用余额${_userinfo.money.toStringAsFixed(2)}",
                          style: KfontConstant.defaultSubStyle,
                        ),

                      ],
                    ),
                    CupertinoSwitch(
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

                const SizedBox(height: 2.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "可用奖金(${_userinfo.jiangli.toStringAsFixed(2)})",
                          style: KfontConstant.defaultSubStyle,
                        ),
                      ],
                    ),
                    CupertinoSwitch(
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
                const SizedBox(height: 2.0),
                payword(),
              ],
            )));
  }
Widget payword(){
    if (_switchValue|| _switchValueye || _switchValuejl){
      return
          TextField(
            controller: _pwdcontroller,
            cursorColor: GlobalConfig.mainColor,
            decoration: new InputDecoration(
              hintText: '请输入支付密码',
              contentPadding: EdgeInsets.all(10.0),
              suffixIcon: new IconButton(
                icon: new Icon(Icons.clear,
                    color: GlobalConfig.mainColor),
                onPressed: () {
                  _pwdcontroller.clear();
                },
              ),
            ),
            obscureText: true,
          )
      ;
    }else
      return const SizedBox(height: 2.0);
}
  Widget queren() {
    num money=double.tryParse(_prebuyinfo['total_amount'].toString())??0;
    if(_switchValue && money>=(_userinfo.point/_point_rate))
      money-=(_userinfo.point/_point_rate);
    if(_switchValueye && money>=_userinfo.money)
      money-=_userinfo.money;
    if(_switchValuejl && money>=_userinfo.jiangli)
      money-=_userinfo.jiangli;
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
                  '去支付',
                  () {
                    submit();
                  },
                ),
                const SizedBox(height: 15.0),
              ],
            )));
  }


  String _picurl="";
  String _name="";
  Future _getdata() async {
    await _onRefreshAddress();
    print(_address);
    print("=====================${_address['address_id']}===========================================");
    Map<String, String> params = {
      "goods_id": widget.buyparam.goods_id,
      "item_id": widget.buyparam.item_id,
      "goods_num": widget.buyparam.goods_num,
      "address_id":_address['address_id'].toString()??"0",
      "action":"buy_now"//立即购买
    };
    Map<String, dynamic> response = await HttpUtils.dioappi(
        'Cart/cart3', params,
        withToken: true, context: context);
//    {"status":1,"msg":"计算成功","result"://:'Cart/integralBuy'
// {"shipping_price":0,"coupon_price":0,"user_money":0,"integral_money":0,"pay_points":0,
// "order_amount":6,"total_amount":6,"goods_price":6,"total_num":3,"order_prom_amount":0}}
    print(response);
    setState(() {
      _prebuyinfo = response['result'];
      _picurl= response['pic_url'];
      _name=response['name'];
    });
    return response['result'];
  }

  void submit() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      Map<String, String> params = {
        "goods_id": widget.buyparam.goods_id,
        "item_id": widget.buyparam.item_id,
        "goods_num": widget.buyparam.goods_num,
        "pay_points":!_switchValue?"":_userinfo.point.toStringAsFixed(4),
        "user_money":_switchValueye?_userinfo.money.toStringAsFixed(2):"0",
        "user_jiangli":_switchValuejl?_userinfo.jiangli.toStringAsFixed(2):"0",
        "pay_pwd": (_switchValue|| _switchValueye || _switchValuejl) ? _pwdcontroller.text:"",
        "address_id":_dee!=''?_address['address_id'].toString():"0",
        "action":"buy_now"//立即购买
      };
      Application().checklogin(context, () async{
        await HttpUtils.dioappi(
            'Cart/cart3/act/submit_order', params,
            withToken: true, context: context).then((response) async{

              print(response);
              print("==============================");
          if (response['status'].toString() == '1') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PayPage(response['result'].toString()),
              ),
            ).whenComplete(() async{
              await DataUtils.freshUserinfo(context);
            });
          }
          else
            await DialogUtils.showToastDialog(context, response['msg']);
        });
      });


    }
  }


  @override
  void initState() {
    _getdata();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
