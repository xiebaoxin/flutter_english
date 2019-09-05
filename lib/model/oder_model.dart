class OrderCell {
  String id;
  String orderNo;
  String orderName;
  String orderMoney;
  String orderBond; //保证金
  String orderCharge; //手续费

  String orderBondPer;
  String content;
  String createtime;
  String planText;

  String orderCard;
  String orderTime;
  String status; //状态,订单状态（0=进行中，1=已完成，2=已取消，3=已停止）

  OrderCell({
    this.id,
    this.orderNo,
    this.orderMoney,
    this.orderName,
    this.orderBond,
    this.orderCharge,
    this.orderBondPer,
    this.content,
    this.createtime,
    this.planText,
    this.orderCard,
    this.orderTime,
    this.status,
  });

  factory OrderCell.fromJson(Map<String, dynamic> json) {
    var statlist={'0':'进行中','1':'已完成','2':'已取消','3':'已停止'};
    return OrderCell(
      id: json['id'] ?? '',
      orderNo: json['orderNo'] ?? '',
      orderMoney: json['orderMoney'] ?? '',
      orderName: json['orderName'] ?? '',
      orderBond: json['orderBond'] ?? '',
      orderCharge: json['orderCharge'] ?? '',
      orderCard: json['orderNo'] ?? '',
      orderBondPer: json['orderBondPer'] ?? '',
      content: json['content'] ?? '',
      planText: json['planText'] ?? '',
      createtime: json['create_time'] ?? '',
      orderTime: json['planPayTime'] ?? '',

      status:statlist[json['status']]??'异常'
    );
  }
}
