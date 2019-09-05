import 'package:flutter/material.dart';
import 'dart:async' show Future;
import '../utils/HttpUtils.dart';
//import '../model/book_cell.dart';
import '../model/model_cell.dart';
import '../routers/application.dart';
import '../model/globle_model.dart';
import '../model/userinfo.dart';
import '../model/index_model.dart';

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

  static Future<List<Map<String, dynamic>>> getmp3txt(int videoid) async {
    Map<String, String> params = {"id": videoid.toString()};
    var json = await HttpUtils.dioappi('Pub/getmp3txt', params);
    List<Map<String, dynamic>> txlist = List();
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


  static Future<List<Map<String, dynamic>>> getIndexTopSwipperBanners(
      context) async {
//  List<String> banners =[];

    Map<String, String> params = {'objfun': 'getAppHomeAdv'};
    var response =
        await HttpUtils.dioappi('Shop/getIndexData', params, context: context);
    /*   .then((response){
    String imurl = '';
    var imagesliest = response["items"];
    imagesliest.forEach((ele) {
      if (ele.isNotEmpty) {
        imurl =ele['ad_code'];
        banners.add(imurl);
      }
    });
  });*/
    List<Map<String, dynamic>> itemlist = response["items"];
    return itemlist;
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

/*static Future<  List<Map> > getIndexChoice()async{
  List<Map> choiceList = [];
  Map<String, String> params = {};
  await HttpUtils.dioappi('Shop/getfarmChoiceList', params).then((data) {
    List<Map> hotGoodList = (data['data'] as List).cast();
    choiceList.addAll(hotGoodList);
  });
  print(choiceList);
  return choiceList;
}*/

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

// 首页九宫格列表数据
  static Future<List<ModelCell>> getIndexModelListData(
      Map<String, dynamic> params) async {
    List<ModelCell> resultList = new List();

    await HttpUtils.post(null, 'Pub/getAppModel', (response) {
      var responseList = response['data'];
      try {
        for (int i = 0; i < responseList.length; i++) {
          ModelCell bookCell;

          bookCell = ModelCell.fromJson(responseList[i]);
//        print(bookCell.modName);
          resultList.add(bookCell);
        }
      } catch (e) {
        return [];
      }
    }, params: params);

    return resultList;
  }
}
