class Choice {
  final int id;
  final String name;
  final String title;
  final int categoryId; //对应商品goodsid
  final String icon;
  final double price;
  final int weight;
  final String danwei;
  final String describe;
  final int thmax;
  final int childs;
  final int produce;

  final int parent_id;
  final String parent_name;
  final String parent_title;
  final int parent_categoryId; //对应商品goodsid
  final String parent_icon;
  final String parent_price;
  final int parent_weight;
  final String parent_danwei;
  final String parent_describe;
  final int parent_thmax;
  final int parant_childs;
  final int parant_produce;

  const Choice(
      {this.id,
      this.name,
      this.title,
      this.categoryId,
      this.icon,
      this.price,
      this.weight,
      this.danwei,
      this.describe,
      this.thmax,
      this.childs,
      this.produce,
      this.parent_id,
      this.parent_name,
      this.parent_title,
      this.parent_categoryId,
      this.parent_icon,
      this.parent_price,
      this.parent_weight,
      this.parent_danwei,
      this.parent_describe,
      this.parent_thmax,
      this.parant_childs,
      this.parant_produce});

  factory Choice.fromJson(Map<String, dynamic> json) {
    var $parentjson = json['parent'];
    return Choice(
        id: json['id'] ?? 1,
        title: json['name'] ?? '',
        name: json['lab'] ?? '',
        categoryId: json['goods_id'] ?? 0,
        icon: json['icon'] ?? '',
        price: double.parse(json['price']) ?? 1.0,
        weight: json['weight'] ?? '',
        danwei: json['danwei'] ?? '个',
        describe: json['describe'].toString() ?? "",
        thmax: json['thmax'] ?? 0,
        childs: json['childs'] ?? 0,
        produce: json['produce'] ?? 0,
        parent_id: $parentjson['id'] ?? 1,
        parent_title: $parentjson['lable'] ?? '',
        parent_name: $parentjson['name'] ?? '',
        parent_categoryId: $parentjson['goods_id'] ?? 0,
        parent_icon: $parentjson['icon'] ?? '',
        parent_price: $parentjson['price'].toString() ?? 0,
        parent_weight: $parentjson['weight'] ?? '',
        parent_danwei: $parentjson['danwei'] ?? '个',
        parent_describe: $parentjson['describe'].toString() ?? "",
        parent_thmax: $parentjson['thmax'] ?? 0,
        parant_childs: $parentjson['childs'] ?? 0,
        parant_produce: $parentjson['produce'] ?? 0);
  }
}

class MsgCell {
  String title;
  String id;
  String createtime;
  String content;
  String type;

  MsgCell({this.title, this.id, this.createtime, this.content, this.type});

  factory MsgCell.fromJson(Map<String, dynamic> json) {
    return MsgCell(
        title: json['title'] ?? '',
        createtime: json['create_time'] ?? '',
        id: json['id'] ?? '',
        content: json['content'] ?? '',
        type: json['type'] ?? '');
  }
}

class PicsCell {
  String title;
  String id;
  String imgurl;
  String url;
  String deft;
  String time;

  PicsCell({this.title, this.id, this.imgurl, this.url, this.time, this.deft});

  factory PicsCell.fromJson(Map<String, dynamic> json) {
    return PicsCell(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      id: json['id'] ?? '',
      imgurl: json['image_url'] ?? '',
      deft: json['default'] ?? '0',
      time: json['create_time'] ??
          '', // Util.getTimeDuration(json['create_time'])
    );
  }
}
