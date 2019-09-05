import 'package:flutter/material.dart';
import '../../utils/screen_util.dart';

class DetailsTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        var isLeft = true;
        var isRight = false;
        return Container(
          margin: EdgeInsets.only(top: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child: _myTabBarLeft(context, isLeft),flex: 1,),
              Expanded(child: _myTabBarRight(context, isRight),flex: 1,)

            ],
          ),
        );

  }

  Widget _myTabBarLeft(BuildContext context, bool isLeft) {
    return InkWell(
      onTap: () {
//        Provide.value<DetailsInfoProvide>(context).changeLeftAndRight(0);
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: isLeft ? Colors.deepOrangeAccent : Colors.black12,
            ),
          ),
        ),
        child: Text(
          '详情',
          style: TextStyle(
            color: isLeft ? Colors.deepOrangeAccent : Colors.black,
          ),
        ),
      ),
    );
  }

  /// 右边的tabar
  Widget _myTabBarRight(BuildContext context, bool isRight) {
    return InkWell(
      onTap: () {
//        Provide.value<DetailsInfoProvide>(context).changeLeftAndRight(1);
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: isRight ? Colors.deepOrangeAccent : Colors.black12,
            ),
          ),
        ),
        child: Text(
          '评论',
          style: TextStyle(
            color: isRight ? Colors.deepOrangeAccent : Colors.black,
          ),
        ),
      ),
    );
  }
}
