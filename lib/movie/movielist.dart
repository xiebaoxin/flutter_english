import 'package:flutter/material.dart';
import '../api/movie.dart';
import 'moviedetail.dart';

MovieApi movieAPI = new MovieApi();

class MovieList extends StatefulWidget {
  MovieList({Key key, @required this.mt}) : super(key: key);
  final String mt;

  _MovieListState createState() => new _MovieListState();
}

class _MovieListState extends State<MovieList>
    with AutomaticKeepAliveClientMixin {
  var mlist = [];
  // 当前的页数
  int _page = 1;
  // 每页显示多少条数据
  int _pagesize = 10;
  // 总数据条数
  int _total = 0;
  // 是否加载完毕了
  bool _isover = false;
  // 是否正在加载数据
  bool _isloading = true;
  ScrollController _scrollCtrl;

  // 保持当前页面的数据状态
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = new ScrollController();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent) {
        // print('滑动到了底部');
        // 是否正在加载中或所有数据加载完毕了
        if (_isloading || _isover) return;
        // 判断是否加载完毕了所有的数据
        if (_page * _pagesize >= _total) {
          setState(() {
            _isover = true;
          });
          return;
        }
        // 页码值自增 +1
        setState(() {
          _page++;
        });
        // 获取下一页数据
        getMovieList();
      }
    });
    getMovieList();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtrl.dispose();
  }

  // 获取电影列表数据的方法
  void getMovieList() async {
    print('加载第 $_page 页数据');
    setState(() {
      _isloading = true;
    });
    var temp = await movieAPI.getMovieList(widget.mt, _page, _pagesize);
    setState(() {
      // mlist = temp['subjects'];
      // 合并数组
      mlist.addAll(temp['subjects']);
      _total = temp['total'];
      _isloading = false;
    });
  }

  // 当前页面的 build 函数用来渲染页面结构
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mlist.length,
      itemBuilder: (BuildContext ctx, int i) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext ctx) {
              return MovieDetail(
                id: mlist[i]['id'],
                title: mlist[i]['title'],
              );
            }));
          },
          child: Column(
            children: <Widget>[
              Divider(
                height: 1,
              ),
              Container(
                margin: EdgeInsets.all(5),
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.network(
                      mlist[i]['images']['small'],
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '电影名称：${mlist[i]['title']}',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text('电影类型：${mlist[i]['genres'].join('，')}',
                                style: TextStyle(fontSize: 12)),
                            Text('上映年份：${mlist[i]['year']}年',
                                style: TextStyle(fontSize: 12)),
                            Text('豆瓣评分：${mlist[i]['rating']['average']}分',
                                style: TextStyle(fontSize: 12)),
                            Row(
                              children: <Widget>[
                                Text('主演：', style: TextStyle(fontSize: 12)),
                                Row(
                                  children: List.generate(
                                      mlist[i]['casts'].length,
                                      (int index) => Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 5),
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(mlist[
                                                              i]['casts'][index]
                                                          ['avatars'] ==
                                                      null
                                                  ? 'https://img3.doubanio.com/f/movie/8dd0c794499fe925ae2ae89ee30cd225750457b4/pics/movie/celebrity-default-medium.png'
                                                  : mlist[i]['casts'][index]
                                                      ['avatars']['small']),
                                            ),
                                          )),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
      controller: _scrollCtrl,
    );
  }
}
