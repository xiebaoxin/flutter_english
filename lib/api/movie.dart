import 'package:dio/dio.dart';

Dio dio = new Dio();

class MovieApi {
  // 获取电影列表
  getMovieList(String mt, int page, int pagesize) async {
    int offset = (page - 1) * pagesize;
    var result = await dio.get(
        'http://www.liulongbin.top:3005/api/v2/movie/$mt?start=$offset&count=$pagesize');
    return result.data;
  }

  // 获取电影详情
  getMovieDetail(String id) async {
    var result = await dio
        .get('http://www.liulongbin.top:3005/api/v2/movie/subject/$id');
    return result.data;
  }

  int add(int n) {
    return ++n;
  }

  int sub(int n) {
    return --n;
  }
}
