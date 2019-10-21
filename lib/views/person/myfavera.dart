import 'package:flutter/material.dart';
import '../../constants/index.dart';
import '../../model/globle_model.dart';
import '../../views/goodsList.dart';
import '../../utils/HttpUtils.dart';
import '../../utils/DialogUtils.dart';

class MyfaveratePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => MyfaveratePageState();
}

class MyfaveratePageState extends State<MyfaveratePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
           leading: SizedBox(width: 10,),
            elevation: 0,
            titleSpacing: 0,
            centerTitle: true,
            title:Text('收藏')),
        body:
        GoodsListWidget(
          _listData,
          getNextPage: () => getSearchList(),
        )
    );
  }

  int _page = 1;
  List<Map<String, dynamic>> _listData = List();
  void getSearchList() async {
    final model = globleModel().of(context);
   if( model.token!=''){
     await HttpUtils.dioappi("User/collect_list/p/${_page.toString()}/", {}, withToken:true,context: context).then ( (response) {
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
  }



  @override
  void initState() {
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
