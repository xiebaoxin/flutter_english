import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/HttpUtils.dart';
import '../model/cart.dart';
import 'userinfo.dart';
import 'goods.dart';


class globleModel extends Model {
  globleModel of(context) => ScopedModel.of(context);

  bool _showMini=false;
   String _url;
   Map<String, dynamic> _video; //字幕文件
   Map<String, dynamic> _info;

  bool get showMini=>_showMini;
  String get url=>_url;
  Map<String, dynamic> get video=>_video; //字幕文件
  Map<String, dynamic> get info=>_info;

  Future setVideoModel(String url,Map<String, dynamic> video,Map<String, dynamic> info ) async{
    _url=url;
    _video=video;
    _info=info;

  await  notifyListeners();
  }


  int _tempkey=1;
  double _point_rate=1.0; //积分对现1元可以换多少TML
  double _exchan_fee=0.0;
  double _withdraw_fee=0.0;

  int _regtype=0;
  bool _loginStatus = false;
  String _token = '';
  Userinfo _userinfo;

  int get tempkey => _tempkey;
  double get point_rate=> _point_rate;
  double get exchan_fee=> _exchan_fee;
  double get withdraw_fee=> _withdraw_fee;


  int get regtype=> _regtype;
  bool get loginStatus => _loginStatus;
  String get token => _token;
  Userinfo get userinfo => _userinfo;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future setlogin(String token, Map<String, dynamic> userinfo) async {
    _token = token;
    _userinfo = Userinfo.fromJson(userinfo);
    _loginStatus = true;
    notifyListeners();
  }

  Future setToken(String token) async {
    SharedPreferences prefs = await _prefs;
    await prefs.setString("token", token);
    print("===SharedPreferences getString :${prefs.getString("token")}---");
    _token = token;
    notifyListeners();
  }

  Future setuserinfo(Userinfo userinfo) async {
    _userinfo = userinfo;
    _loginStatus = true;
    notifyListeners();
  }

  freshUserinfo(context) async {
    await HttpUtils.dioappi(
        'User/userInfo', {},
        withToken: true,context: context)
        .then((response) {
      if (response["status"].toString() == '1') {
        _userinfo=Userinfo.fromJson(response["userinfo"]);
        notifyListeners();
      }
    });
  }


  Future setConfig(Map<String, dynamic> respon ) async{
    if (respon["point_rate"]!=null)
      _point_rate =  double.tryParse(respon["point_rate"])??1.0;
    if (respon["regtype"]!=null)
      _regtype =  int.tryParse(respon["regtype"])??0;

    if (respon["exchan_fee"]!=null)
      _exchan_fee =  double.tryParse(respon["exchan_fee"])??0.0;

    if (respon["withdraw_fee"]!=null)
      _withdraw_fee =  double.tryParse(respon["withdraw_fee"])??0.0;

    notifyListeners();
  }


  Future setlogout() async {
    SharedPreferences prefs = await _prefs;
    await prefs.remove('token');
    await prefs.clear(); //清空键值对-有其他参数保留
    _token = null;
    _loginStatus = false;
    _userinfo = Userinfo.fromJson({});
    print('setlogout');
    notifyListeners();
  }

  String _goodsId, _goodsName;
  GoodInfo _goodsinfo;
  List<GoodComment> _goodComments;

  String get goodsId => _goodsId;
  String get goodsname => _goodsName;
  GoodInfo get goodsinfo => _goodsinfo;
  List<GoodComment> get goodComments => _goodComments;

  Future getgoods(String goodsid) async {
    _goodsId = goodsid;
    Map<String, String> params = {"id": goodsid};
    await HttpUtils.dioappi('Shop/goodsInfo', params).then((response){
//      var data = json.decode(response.toString());
      _goodsinfo =GoodInfo.fromJson(response);
      _goodsName = _goodsinfo.goodsName;
      notifyListeners();
    });

  }
  Future setgoodInfo(GoodInfo goodsinfo) async {
    _goodsId = goodsinfo.goodsId;
    _goodsinfo = goodsinfo;
    _goodsName = _goodsinfo.goodsName;
    notifyListeners();
  }


  int _cartcount = 0;
  int get cartcount => _cartcount;

  Future setcartcount(int cartcount) async {
    _cartcount = cartcount;
    notifyListeners();
  }


//以下为购物车
  List<CartItemModel> _cartitems=List();
  List<CartItemModel> get items=>_cartitems;
  Future freshCartItem(context) async{
    await HttpUtils.dioappi('Cart/AsyncUpdateCart', {},withToken: true,context: context).then((response){
      if(response['result'] !=null){
        print("--------------------------------------------------------------");
        var json = response['result']["cart_list"];
        if(json!=null){
          _cartitems=List();
          json.forEach((ele) {
            if (ele.isNotEmpty) {
              _cartitems.add(CartItemModel.fromJson((ele)));
            }
          });
          notifyListeners();
        }
      }
    });

  }

  int get itemsCount {
    return _cartitems.length;
  }

  bool get isAllchecked {
    return _cartitems.every((i) => i.isSelected);
  }

  switchAllCheck() {
    if (this.isAllchecked) {
      _cartitems.forEach((i) => i.isSelected = false);
    } else {
      _cartitems.forEach((i) => i.isSelected = true);
    }
    notifyListeners();
  }

  double get sumTotal {
    double total = 0;
    _cartitems.forEach((item) {
      if (item.isDeleted == false && item.isSelected == true) {
        total = item.price * item.count + total;
      }
    });
    return total;
  }

  addCount(int index) {
    _cartitems[index].count = _cartitems[index].count + 1;
    notifyListeners();
    changnum(index);
  }

  downCount(int index) {
    _cartitems[index].count = _cartitems[index].count - 1;
    notifyListeners();
    changnum(index);
  }

  removeItem(index) {
    _cartitems.removeAt(index);

    HttpUtils.dioWithToken('Cart/delete/cart_id/${_cartitems[index].cartId.toString()}', {},_token)
        .then((response) {
      if(response['status'] ==1){
        notifyListeners();
      }
    });

  }

  switchSelect(i) {
    _cartitems[i].isSelected = !_cartitems[i].isSelected;

    String selectted=_cartitems[i].isSelected?"1":"0";
    HttpUtils.dioWithToken("Cart/selectted/cart_id/${_cartitems[i].cartId.toString()}/selectted/$selectted", {},_token)  .then((response) {
      if(response['status'] ==1){
        notifyListeners();
      }
    });
  }

  get totalCount {
    int count = 0;
    _cartitems.forEach((item) {
      if (item.isDeleted == false && item.isSelected == true) {
        count = item.count + count;
      }
    });
    return count;
  }

  Future changnum(int i) async{
    Map<String, String> params = {
      "cart_id":  _cartitems[i].cartId.toString(),
      "goods_num": _cartitems[i].count.toString(),
    };
    await HttpUtils.dioWithToken('Cart/changeNum', params,_token).then((response) {
      if(response['status'] ==1){
        notifyListeners();
      }
    });
  }

  Future addtocart(context,Map<String, String> params) async{
    await HttpUtils.dioappi('Cart/add', params,withToken: true,context: context).then((response) async{
      if(response['status'] ==1){
        await freshCartItem(context);
      }
     /* Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(response['msg'].toString()),
      ));*/

    });
  }


}
