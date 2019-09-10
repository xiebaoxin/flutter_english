import 'package:flutter/material.dart';
import 'dart:async' show Future;
import '../utils/HttpUtils.dart';
//import '../model/book_cell.dart';
import '../model/model_cell.dart';
import '../routers/application.dart';
import '../model/globle_model.dart';
import '../model/userinfo.dart';
import '../model/index_model.dart';
import '../utils/DialogUtils.dart';

class DataUtils {
  static Future freshUserinfo(BuildContext context) async {
    await HttpUtils.dioappi('User/userInfo', {},
            context: context, withToken: true)
        .then((response) async {
      if (response["status"].toString() == '1') {
        Userinfo userinfo = Userinfo.fromJson(response["userinfo"]);
        final model = globleModel().of(context);
        await model.setuserinfo(userinfo);
        await model.freshCartItem(context);
      } else
        Application.run(context, "/login");
    });
  }

  static Future<List<Map<String, dynamic>>> getmp3txt(int videoid,{BuildContext context}) async {
    List<Map<String, dynamic>> txlist = List();
    Map<String, String> params = {"id": videoid.toString()};
    var json = await HttpUtils.dioappi('Pub/getmp3txt', params);
    if (context!=null && json["status"].toString() != '1') {
      await DialogUtils.showToastDialog(context,"字幕文件请求异常:${json["msg"]}");
      return txlist;
    }

    var tts;
    try {
      tts = json['txtlist'] as List;
    } catch (e, r) {
      tts = [1];
    } finally {
      if (tts.isNotEmpty) {
        if (tts != null) {
          tts.forEach((ele) {
            if (ele.isNotEmpty) {
              txlist.add(ele);
            }
          });
        }
      }
    }
    return txlist;
  }

  static Future<bool> isBuyedGoods(int goodsid) async {
    var response = await HttpUtils.dioappi(
        'User/checkgoodsbuyed/goods_id/${goodsid.toString()}', {},
        withToken: true);
    bool isbuyed = response['status'] == 1 ? true : false;
    return isbuyed;
  }


  static Future<bool> isCheckedGoods(int goodsid,{int videoid=0,int vd_level=0}) async {
    if(videoid==0 && vd_level>=0)
      return true;

    if(videoid>0 ){
      if(vd_level==0)
        return true;
      else if(videoid<vd_level)
      {
        return true;
      }
    }

    var response = await HttpUtils.dioappi(
        'User/checkgoodsbuyed/goods_id/${goodsid.toString()}', {},
        withToken: true);
    bool isbuyed = response['status'] == 1 ? true : false;
    return isbuyed;
  }



  static Future  getSubsCategory(
      context,{int cat_id=0}) async {
    Map<String, String> params = {'cat_id':cat_id.toString()};
    return  await HttpUtils.dioappi('Shop/get_goods_subs_category', params, context: context);
  }


  static Future  getIndexCategory(
      context,{int cat_id=0}) async {
    Map<String, String> params = {'objfun':'getIndexCategory','cat_id':cat_id.toString()};
   return  await HttpUtils.dioappi('Shop/getIndexData', params, context: context);
  }


  static Future getIndexTopSwipperBanners(
      context) async {

    Map<String, String> params = {'objfun': 'getAppHomeAdv'};
    Map<String, dynamic> response =
    await HttpUtils.dioappi('Shop/getIndexData', params, context: context);

    return response["items"];

  }


  static Future<List<Map<String, dynamic>>> getIndexRecommendGoods(
      BuildContext context) async {
    List<Map<String, dynamic>> _recommondList = List();
    await HttpUtils.dioappi("Shop/ajaxCommantGoodsList/", {}, context: context)
        .then((response) {
        if (response['list'].isNotEmpty) {
            response['list'].forEach((ele) {
              if (ele.isNotEmpty) {
                _recommondList.add(ele);
              }
            });
        }
    });
    return _recommondList;
  }



  static Future<List<Map<String, dynamic>>> getIndexGoodsList(int page,
      BuildContext context,{int catid=0}) async {
    List<Map<String, dynamic>> _goodsList = List();
    await HttpUtils.dioappi("Shop/ajaxGoodsList/p/${page.toString()}/id/${catid.toString()}", {},
        context: context)
        .then((response) {
      if (response['list'].isNotEmpty) {
        response['list'].forEach((ele) {
          if (ele.isNotEmpty) {
            _goodsList.add(ele);
          }
        });
      }
    });
    return _goodsList;
  }


  static Future<Map<String, dynamic>> getIndexgetNewGoods(
      BuildContext context) async {
    Map<String, String> params = {'objfun': 'getNewGoods'};
    Map<String, dynamic> json =
        await HttpUtils.dioappi('Shop/getIndexData', params, context: context);
    return json;
  }

  static Future<Map<String, dynamic>> getIndexgetHotGood(
      BuildContext context) async {
    Map<String, String> params = {'objfun': 'getHotGood'};
    Map<String, dynamic> json =
        await HttpUtils.dioappi('Shop/getIndexData', params, context: context);
    return json;
  }

  static Future<List<Choice>> getIndexChoice(BuildContext context) async {
    List<Choice> choiceList = List();
    var data =
        await HttpUtils.dioappi('Api/getfarmChoiceList', {}, context: context);
    if (data['data'] != null) {
      Choice choice;
      data['data'].forEach((v) {
        if (v.isNotEmpty) {
          choice = Choice.fromJson(v);
          choiceList.add(choice);
        }
      });
    }
    return choiceList;
  }

  static Future<List<String>> getIndextests(BuildContext context) async {
    List<String> banners = [];
    Map<String, String> params = {};
    await HttpUtils.dioappi('Shop/index', params, context: context)
        .then((response) {
      String imurl = '';
      var imagesliest = response["list"];
      imagesliest.forEach((ele) {
        if (ele.isNotEmpty) {
          imurl = ele['ad_code'];
          banners.add(imurl);
        }
      });
    });
    return banners;
  }

}
