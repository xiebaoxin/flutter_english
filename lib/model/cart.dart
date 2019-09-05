class CartItemModel {
  int cartId;
  String productName;
  int goodsId;
  int itemId;
  int buyLimit;
  int count;
  String imageUrl;
  bool isSelected;
  bool isDeleted;
  double price;
  CartItemModel(
      {this.productName,
        this.count,
        this.cartId,
        this.goodsId,
        this.itemId,
        this.buyLimit,
        this.imageUrl,
        this.price,
        this.isDeleted,
        this.isSelected});
  CartItemModel.fromJson(dynamic json)
      : productName = json['goods_name'],
        goodsId = json['goods_id'],
        itemId = json['item_id'],
        cartId = json['id'],
        price = num.parse(json['goods_price']),
        isDeleted = false,
        count = json['goods_num'],
        isSelected = (json['selected'] as int) == 1 ? true : false,
        imageUrl = json['original_img'] ?? '',
        buyLimit = json['store_count'];
}
