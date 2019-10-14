class GoodSpc {
  String item_id;
  String item;
  String src;

  GoodSpc({
    this.item_id,
    this.item,
    this.src,
  });

  factory GoodSpc.fromJson(Map<String, dynamic> json) {
    return GoodSpc(
        item_id: json['item_id'].toString(),
        item: json['item'].toString(),
        src: json['src'].toString() ?? "");
  }
}

class GoodSpcListItem {
  String sname;
  List<GoodSpc> items = List();

  GoodSpcListItem({
    this.sname,
    this.items,
  });

  factory GoodSpcListItem.Setitem(String dname, List<dynamic> ditems) {
    List<GoodSpc> sditems = List();
    for (int i = 0; i < ditems.length; i++) {
      GoodSpc scoit = GoodSpc.fromJson(ditems[i]);
      sditems.add(scoit);
    }
    return GoodSpcListItem(
      sname: dname,
      items: sditems,
    );
  }
}

class GoodSpcPrice {
  String key;
  String item_id;
  String price;
  String store_count;

  GoodSpcPrice({
    this.key,
    this.item_id,
    this.price,
    this.store_count,
  });

  factory GoodSpcPrice.fromJson(dynamic json) {
    return GoodSpcPrice(
        key: json['key'].toString(),
        item_id: json['item_id'].toString(),
        price: json['price'].toString(),
        store_count: json['store_count'].toString() ?? "0");
  }
}

class GoodSpcPriceListItem {
  String keyname;
  GoodSpcPrice items;

  GoodSpcPriceListItem({
    this.keyname,
    this.items,
  });

  factory GoodSpcPriceListItem.Setitem(
      String kname, Map<String, dynamic> ditems) {
    GoodSpcPrice scoit = GoodSpcPrice.fromJson(ditems);
    return GoodSpcPriceListItem(
      keyname: kname,
      items: scoit,
    );
  }

/*  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['keyname'] = this.keyname;
    data['items'] = this.items;
    return data;
  }*/
}

class GoodInfo {
  String amount;
  String goodsId;
  String isOnline;
  String goodsSerialNumber;
  String oriPrice;
  String presentPrice;
  String comPic;
  String shopId;
  String goodsName;
  String goodsRemark;
  String content;

  List<String> images;
  List<String> specNameList=List();
  List<GoodSpcListItem> specMapList = List();
  List<GoodSpcPriceListItem> specMapPriceList = List();


  GoodInfo(
      {this.amount,
      this.goodsId,
      this.isOnline,
      this.goodsSerialNumber,
      this.oriPrice,
      this.presentPrice,
      this.comPic,
      this.shopId,
      this.goodsName,
      this.goodsRemark,
      this.images,
      this.specNameList,
      this.specMapList,
      this.specMapPriceList,
      this.content});
  factory GoodInfo.fromJson(Map<String, dynamic> json) {
/*    var itemsList = json["data"]["goods_images_list"] as List;
    images = itemsList.map((i) {
      return i['image_url'];
    }).toList();
    */

    List<String> imagesList = [];
   /* String ddr = json['goods']['original_img'].toString() ??
        'http://testapp.hukabao.com:8008/public/upload/ad/2018/04-12/ca1e401cbd313540eadace224524d766.jpg';

    imagesList.add(ddr);*/
    String imu = '';
    var imagesliest = json["data"]["goods_images_list"];

    imagesliest.forEach((ele) {
      if (ele.isNotEmpty) {
        imu =ele['image_url'];
        imagesList.add(imu);
      }
    });

    List<GoodSpcListItem> specMapLists = List();
    List<String> specnameslist=List();

    var tt;
    try{
       tt=json["data"]["filter_spec"] as List;
    }catch(e, r){
        tt=[1];
    }finally{
      if(tt.isNotEmpty){
        Map<String,dynamic> spejson = json["data"]["filter_spec"];
        GoodSpcListItem spelist;
        spejson.forEach((k, v) {
          if (v.isNotEmpty) {
            specnameslist.add(k);
            spelist = GoodSpcListItem.Setitem(k, v);
            specMapLists.add(spelist);
          }
        });
      }
    }

    List<GoodSpcPriceListItem> specMapPriceLists = List();
    GoodSpcPriceListItem sppelist;
    var tts;
    try{
    tts=json["data"]["spec_goods_price"] as List;
    }catch(e, r){
      tts=[1];
    }finally{
      if(tts.isNotEmpty){
        Map<String,dynamic> speprcjson = json["data"]["spec_goods_price"];
        speprcjson.forEach((key, v) {
          sppelist = GoodSpcPriceListItem.Setitem(key, v);
          specMapPriceLists.add(sppelist);
        });
      }
    }

    return GoodInfo(
        amount: json['goods']['store_count'].toString() ?? '0',
        goodsId: json['goods']['goods_id'].toString(), //cat_id
        goodsName: json['goods']['goods_name'],
        goodsSerialNumber: json['goods']['goods_sn'].toString(),
        isOnline: json['goods']['is_on_sale'].toString(),
        goodsRemark: json['goods']['goods_remark'].toString(),
        images: imagesList,
        specNameList: specnameslist,
        specMapList: specMapLists,
        specMapPriceList: specMapPriceLists,
        oriPrice: json['goods']['market_price'].toString()?? "",
        presentPrice: json['goods']['shop_price'].toString()?? "1",
        comPic: json['goods']['original_img'].toString(),
        shopId: json['goods']['suppliers_id'].toString()?? "",
        content: json['goods']['content'].toString() ?? ""
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['goodsId'] = this.goodsId;
    data['isOnline'] = this.isOnline;
    data['goodsSerialNumber'] = this.goodsSerialNumber;
    data['oriPrice'] = this.oriPrice;
    data['presentPrice'] = this.presentPrice;
    data['comPic'] = this.comPic;
    data['shopId'] = this.shopId;
    data['goodsName'] = this.goodsName;
    data['goodsRemark'] = this.goodsRemark;
    data['imges'] = this.images.toList();
    data['specNameList']=this.specNameList.toList();
    data['specMapList'] = this.specMapList;
    data['specMapPriceList'] = this.specMapPriceList;
    return data;
  }

  GoodSpcPrice findSpcItem(String spcname){
    GoodSpcPrice newitem;
    this.specMapPriceList.forEach((v) {
      GoodSpcPrice item = v.items;
      if (item.key == spcname.toString()) {
        print(item);
        print(v.keyname+"======"+item.price);
        newitem= item;
      }
    });
    return newitem;

  }
}

class GoodComment {
  String content;
  String userName;
  String discussTime;
  String headpic;
  int commentid;
  int parentid;

  GoodComment(
      {this.commentid,
      this.content,
      this.userName,
      this.discussTime,
      this.headpic,
      this.parentid});

  factory GoodComment.fromJson(Map<String, dynamic> json) {
    return GoodComment(
      commentid: json['comment_id'],
      parentid: json['parent_id'],
      content: json['content'],
      userName: json['username'],
      discussTime: json['add_time'],
      headpic: json['head_pic'],
    );
  }
}
