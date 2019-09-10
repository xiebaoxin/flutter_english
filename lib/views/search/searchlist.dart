import 'package:flutter/material.dart';
import '../../constants/index.dart';
import '../../widgets/index.dart';
import '../../views/goodsList.dart';
import '../../utils/HttpUtils.dart';

class SearchResultListPage extends StatefulWidget {
  final String keyword;
  final String catname;
  final int catid;
  SearchResultListPage(this.keyword,{this.catid=0,this.catname=''});

  @override
  State<StatefulWidget> createState() => SearchResultListState();
}

class SearchResultListState extends State<SearchResultListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
//            brightness: Brightness.light,
//            backgroundColor: KColorConstant.searchAppBarBgColor,
//            leading: SearchTopBarLeadingWidget(),
            //  actions: <Widget>[SearchTopBarActionWidget()],
            elevation: 0,
            titleSpacing: 0,
            title:widget.keyword!=''? SearchListTopBarTitleWidget(keyworld: widget.keyword):Text(widget.catname)),
        body:
        GoodsListWidget(
          _listData,
          getNextPage: () => getSearchList(),
        )
    );
  }



  int _page = 1;
  List<Map<String, dynamic>> _listData = List();
  String _keyword;
  int _catid;

  void getSearchList() async {
    Map<String, String> params = {};
    String url="";
    if(_catid>0)
      url="Shop/goodsList/id/${_catid.toString()}/p/${_page.toString()}/";

    if(_keyword!=''){
      url="Shop/search/p/${_page.toString()}/";
      params = {
        "q": _keyword
      };
    }

    await HttpUtils.dioappi(url, params, context: context).then ( (response) {
        if (response['list']!=null && response['list'].isNotEmpty ) {
          setState(() {
            _page += 1;
            response['list'].forEach((ele) {
              if (ele.isNotEmpty) {
                _listData.add(ele);
              }
            });

          });

        }

    });
  }



  @override
  void initState() {
    _keyword=widget.keyword;
    _catid=widget.catid;
    super.initState();
    getSearchList();
  }
  @override
  void dispose() {
    // TODO: implement dispose
     _listData = null;
    super.dispose();
  }
}
