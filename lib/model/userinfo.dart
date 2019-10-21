import '../globleConfig.dart';

class Userinfo {
  bool paywsd;
  String name;
  String acount;
  String id;
  String nickname;
  String avtar;
  String phone;
  String level;
  double point;
  num money;
  num jiangli;
  double frozen;
  double point_frozen;
  double point_locked;
  String levelname;
  String wallet_addr;
  Map<String, dynamic> json;

  Userinfo(
      {this.paywsd = false,
        this.acount,
      this.phone,
      this.id,
      this.name,
      this.nickname,
      this.avtar,
      this.level,
      this.levelname,
      this.point,
      this.money = 0.0,
      this.frozen = 0.0,
      this.point_frozen = 0.0,
      this.point_locked = 0.0,
      this.jiangli = 0.0,
      this.wallet_addr,
      this.json});

  factory Userinfo.fromJson(Map<String, dynamic> json) {
    if (json == {} || json.length == 0)
      return Userinfo(
          phone: '18888888888',
          name: '新人驾到',
          acount: '88888888',
          id: "1",
          nickname: '新人驾到',
          avtar: GlobalConfig.server +
              '/public/images/icon_goods_thumb_empty_300.png',
          level: '1',
          money: 0.0,
          frozen: 0.0,
          jiangli: 0.0,
          point_locked: 0.0,
          point_frozen: 0.0,
          point: 0.0,
          levelname: '游客',
          wallet_addr: "",
          json: {});
    else
    return Userinfo(
        paywsd: json['setpaywsd'].toString() != '' ? true : false,
        phone: json['phone'] ?? '18888888888',
        name: json['username'] ?? '新人驾到',
        acount: json['account']??"88888888",
        id: json['user_id'].toString()??"0",
        nickname: json['nickname'] ?? '新人驾到',
        avtar: json['avatar'] ??
            GlobalConfig.server +
                '/public/images/icon_goods_thumb_empty_300.png',
        level: json['level'].toString() ?? '1',
        money: num.tryParse(json['money']) ?? 0.0,
        frozen: num.tryParse(json['frozen_money']) ?? 0.0,
        jiangli: num.tryParse(json['distribut_money']) ?? 0.0,
        point_locked: double.tryParse(json['points_locked']) ?? 0.0,
        point_frozen: double.tryParse(json['points_frozen']) ?? 0.0,
        point: double.tryParse(json['pay_points']) ?? 0.0,
        levelname: json['levelname'] ?? '游客',
        wallet_addr: json['wallet_addr'].toString(),
        json: json);
  }
}
