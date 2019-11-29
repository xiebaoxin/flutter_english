import 'package:flutter/material.dart';

class FiexdAppbar extends StatefulWidget implements PreferredSizeWidget {

  final double contentHeight; //从外部指定高度
  final Widget contentChild;  //从外部指定内容
  final Color statusBarColor; //设置statusbar的颜色

  FiexdAppbar({this.contentChild, this.contentHeight, this.statusBarColor}): super();

  @override
  State<StatefulWidget> createState() {
    return new _XFileAppbarState();
  }

  @override
  Size get preferredSize => new Size.fromHeight(contentHeight);

}
/*
 * 这是一个可以指定SafeArea区域背景色的AppBar
 * PreferredSizeWidget提供指定高度的方法
 * 如果没有约束其高度，则会使用PreferredSizeWidget指定的高度
 */

/*
 * 这里没有直接用SafeArea，而是用Container包装了一层
 * 因为直接用SafeArea，会把顶部的statusBar区域留出空白
 * 外层Container会填充SafeArea，指定外层Container背景色也会覆盖原来SafeArea的颜色
 */
class _XFileAppbarState extends State<FiexdAppbar> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: widget.statusBarColor,
      child: new SafeArea(
        top: true,
        child: widget.contentChild,
      ),
    );
  }

}