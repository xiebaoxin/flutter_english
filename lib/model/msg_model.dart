class MyMsgCell {
  String id;
  String title;
  String content;
  String createtime;
  String status; //状态,订单状态（0=进行中，1=已完成，2=已取消，3=已停止）

  MyMsgCell({
    this.id,
    this.title,
    this.content,
    this.createtime,
    this.status,
  });

  factory MyMsgCell.fromJson(Map<String, dynamic> json) {
    var statlist={'0':'未读','1':'已读','2':'已过期'};
    return MyMsgCell(
      id: json['id'] ?? '',
        title: json['title'] ?? '',
      content: json['content'] ?? '',
      createtime: json['create_time'] ?? '',
      status:statlist[json['status']]??'未知'
    );
  }
}
