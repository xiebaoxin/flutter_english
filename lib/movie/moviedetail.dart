import 'package:flutter/material.dart';
import '../api/movie.dart';

MovieApi movieApi = new MovieApi();

class MovieDetail extends StatefulWidget {
  MovieDetail({Key key, @required this.id, @required this.title})
      : super(key: key);
  // 电影 Id
  final String id;
  // 电影 标题
  final String title;

  _MovieDetailState createState() => new _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  // 电影详情
  var _minfo = {};
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    _getMovieInfo();
  }

  _getMovieInfo() async {
    var temp = await movieApi.getMovieDetail(widget.id);
    setState(() {
      _minfo = temp;
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: _renderInfo(),
    );
  }

  Widget _renderInfo() {
    if (_isloading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView(
        children: <Widget>[
          Padding(
            child: Image.network(_minfo['images']['large'], height: 350),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _minfo['summary'],
              style: TextStyle(height: 1.5),
            ),
          )
        ],
      );
    }
  }
}
