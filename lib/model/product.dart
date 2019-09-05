class ProductItemModel {
  String goods_id;
  String shop_price;
  String market_price;
  String bgColor;
  String picurl;
  String title;
  String titleColor;
  String subtitle;
  String subtitleColor;
  ProductItemModel(
      {this.goods_id,
      this.bgColor,
      this.market_price,
      this.shop_price,
      this.picurl,
      this.title,
      this.titleColor,
      this.subtitle,
      this.subtitleColor});
  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    return ProductItemModel(
        bgColor: json['bg_color'],
        goods_id: json['goods_id'].toString() ?? "0",
        market_price: json['market_price'] ?? "0",
        shop_price: json['shop_price'] ?? "0",
        picurl: json['pic_url'],
        subtitle: json['subtitle'].toString()??"",
        titleColor: json['title_color'],
        subtitleColor: json['subtitle_color'],
        title: json['title']);
  }
}

class ProductListModel {
  List<ProductItemModel> items;
  String title;

  ProductListModel({this.items, this.title});
  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    var menueItems = itemsList.map((i) {
      return ProductItemModel.fromJson(i);
    }).toList();

    return ProductListModel(items: menueItems, title: json['title']);
  }
}
