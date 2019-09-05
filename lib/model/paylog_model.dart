
class PayLogCell {
  String id;
  String orderNo;
  String orderName;
  String orderMoney;
  String orderBond;//入账金额
  String orderCharge;//手续费
  String orderCard;
  String orderTime;
  String status; //状态,0=处理中，1=出账成功

  PayLogCell(
      {this.id,
      this.orderNo,
      this.orderMoney,

      this.orderName,
      this.orderBond,
      this.orderCharge,

      this.orderCard,
      this.orderTime,
      this.status,});

  factory PayLogCell.fromJson(Map<String, dynamic> json) {
    var statlist={'0':'不成功','1':'入账','2':'消费','3':'入账','4':'消费'};
    return PayLogCell(
        id: json['id']??'',
        orderNo: json['orderNo']??'',
        orderMoney: json['orderMoney']??'',

      orderName: json['orderName']??'',
      orderBond: json['orderBond']??'',
      orderCharge: json['orderCharge']??'',
        orderCard: json['orderNo']??'',
        orderTime: json['create_time']??'',
//        status: json['status']=='1' ? "出账成功":"已处理",
        status:statlist[json['status']]??'处理'
        );
  }

}
