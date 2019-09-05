class ModelCell {
  String id;
  String modAddr;
  String modName;
  String modtype;
  String url;
  String fluUrl;
  String sortId; //
  String stat;
  String icon; //
  String iconname;

  ModelCell({
    this.id,
    this.modAddr,
    this.modName,
    this.modtype,
    this.url,
    this.fluUrl,
    this.sortId,
    this.stat,
    this.icon,
    this.iconname,
  });

  factory ModelCell.fromJson(Map<String, dynamic> json) {
    return ModelCell(
      id: json['_id'],
      modAddr: json['modAddr'],
      modName: json['modName'],
      modtype: json['modtype'],
      sortId: json['sortId'],
      url: json['url'],
      fluUrl: json['iosUrl'],
      stat: json['stat'],
      icon: json['icon'],
      iconname: json['iconname'],
    );
  }
}
