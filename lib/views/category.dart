import 'package:flutter/material.dart';
import '../widgets/index.dart';
import '../model.dart';
//import '../data/category.dart';
import '../utils/screen_util.dart';
import '../utils/HttpUtils.dart';
import '../utils/dataUtils.dart';

class Category extends StatefulWidget {
  final double rightListViewHeight;
  Category({Key key, this.rightListViewHeight}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CategoryState();
}

class CategoryState extends State<Category> {
  var _categoryData=[];
  int currentPage = 0;
  GlobalKey<RightListViewState> rightListviewKey =
      new GlobalKey<RightListViewState>();
  GlobalKey<CategoryMenueState> categoryMenueKey =
      new GlobalKey<CategoryMenueState>();
  List<SubCategoryListModel> listViewData = [];
  bool isAnimating = false;
  int itemCount = 0;
  double menueWidth;
  double itemHeight;
  double height;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFFFFFFFF),
        child: Column(
          children: <Widget>[
            SearchBar(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      color: Color(0xFFf7f7f7),
                      width:  ScreenUtil().L(75),
                      child: CategoryMenue(
                          key: categoryMenueKey,
                          items: _categoryData.map((i){
                            return i['name'] as String;
                          }).toList(),
                          itemHeight: ScreenUtil().L(44),
                          itemWidth: ScreenUtil().L(75),
                          menueTaped: menueItemTap),
                    ),
                  ),
                  RightListView(
                      key: rightListviewKey,
                      height: widget.rightListViewHeight,
                      dataItems: listViewData,
                      listViewChanged: listViewChanged)
                ],
              ),
            )
          ],
        ));
  }

  menueItemTap(int i) {
    rightListviewKey.currentState.jumpTopage(i);
  }

  
  listViewChanged(i) {
    this.categoryMenueKey.currentState.moveToTap(i);
  }
@override
  void reassemble() {
    listViewData = _categoryData.map((i){
      return SubCategoryListModel.fromJson(i);
    }).toList();
    super.reassemble();
  }
  @override
  void initState() {
    categoryData();
    super.initState();
  }

  Future categoryData() async {
    List<dynamic> CategoryItems =[];
   await DataUtils.getIndexCategory(context).then((response){
      var cateliest = response["items"];
      print(cateliest);
      cateliest.forEach((ele) {
        if (ele.isNotEmpty) {
          CategoryItems.add(ele);
        }
      });
      setState(() {
        _categoryData=CategoryItems;
        listViewData = _categoryData.map((i){
          return SubCategoryListModel.fromJson(i);
        }).toList();
      });

    });

    return CategoryItems;
  }
}
