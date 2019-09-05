import 'package:flutter/material.dart';
import '../constants/length.dart';
import 'package:flutter/cupertino.dart';
class HomeTopBar extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.deepOrange,
      padding: EdgeInsets.only(
          top: statusBarHeight+6, left: 10, right: 10, bottom: 5),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.settings_overscan,
            size: 22.0,
            color:Colors.white70,// Color.fromRGBO(132, 95, 63, 1.0),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
                onTap: () {
                     Navigator.push(context,CupertinoPageRoute(builder: (BuildContext context){
                       ;//return  SearchPage();
                     }));
                },
                child: Container(
                  height: Klength.topBarHeight,
                  padding: EdgeInsets.all(5.0),
//                  color: Color.fromRGBO(238, 238, 238, 0.5),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(238, 238, 238, 0.5),
//                      border: Border.all(color: Colors.black45, width: 1.0),
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.search,
                          color: Color(0xFF979797),
                          size: 20,
                        ),
                      ),
                      Text(
                        "搜索",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF979797),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 6.0),
            child: Icon(
              Icons.account_balance_wallet,
              size: 22.0,
              color:Colors.white70,// Color.fromRGBO(132, 95, 63, 1.0),
            ),
          )
        ],
      ),
    );
  }
}
