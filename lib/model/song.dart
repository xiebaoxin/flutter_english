import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Song {
   String id;
   String url;
   Map<String, dynamic> video;//当前
   Map<String, dynamic> info;//简介
   List<Map<String, dynamic>> vdlist = List();//列表集合
   List<Map<String, dynamic>> txtlist;//字幕文件
   int preid;
   int nextid;

//  String get id => _id;

  /// 自定义属性
  bool isExpaned = false;

   Song(
       {
         this.id,
         this.url,
         this.video,
         this.info,
       this.txtlist,
         this.preid,
         this.nextid,
         this.vdlist
       });
/*
  factory Song.fromJson(Map<String, dynamic> json) =>
   Song()
  ..imgUrl = json['imgUrl'] as String
  ..lrcUrl = json['lrcUrl'] as String
  ..size = json['size'] as String
  ..singer = json['singer'] as String
  ..songUrl = json['songUrl'] as String
  ..title = json['title'] as String
  ..duration = json['duration'] as String
  ..imgUrl_s = json['imgUrl_s'] as String
  ..desc = json['desc'] as String
  ..isFav = json['isFav'] as bool
  .._id = json['_id'];

  static Map<String, dynamic> toJson(Song instance) =>
      <String, dynamic>{
        'imgUrl': instance.imgUrl,
        'lrcUrl': instance.lrcUrl,
        'size': instance.size,
        'singer': instance.singer,
        'songUrl': instance.songUrl,
        'title': instance.title,
        'duration': instance.duration,
        'imgUrl_s': instance.imgUrl_s,
        'desc': instance.desc,
        'isFav': instance.isFav,
        '_id': instance._id
      };*/
}
