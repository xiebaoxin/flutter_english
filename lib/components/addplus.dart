import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/screen_util.dart';
import '../globleConfig.dart';

class AddPlus extends StatefulWidget {
  int count;
  int max;
  Function callback;
  AddPlus({this.count = 1, this.max = 100, this.callback});

  @override
  AddPlusState createState() => AddPlusState();
}

class AddPlusState extends State<AddPlus> {
  int _count;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              if (_count > 1) {
                _count -= 1;
                widget.callback(_count);
              }
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(border: _getRemoveBtBorder()),
            child: Icon(
              Icons.remove,
              color: _getRemovebuttonColor(),
              size: 10,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: 50,
          height: 30,
          decoration: BoxDecoration(
              border: Border.all(
                  color: KColorConstant.cartItemCountTxtColor, width: 1)),
          child:
       /*   CupertinoTextField(
            textAlign: TextAlign.right,
            prefix: Text(_count.toString(),style: TextStyle(color: GlobalConfig.mainColor)),
            keyboardType: TextInputType.number,
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 0.0, color: CupertinoColors.inactiveGray)),
            ),
            onChanged: (String value) {
              setState(() {
                if (_count > 0) {
                  widget.callback(_count);
                }
              });
            },
          ),
*/
                 Text(
              _count.toString(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: KColorConstant.cartItemCountTxtColor),
            )
        ),
        GestureDetector(
          onTap: () {
            {
              setState(() {
                if (_count > 0) {
                  _count += 1;
                  widget.callback(_count);
                }
              });
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: 30,
            height: 30,
            decoration: BoxDecoration(border: _getAddBtBorder()),
            child: Icon(
              Icons.add,
              color: _getAddbuttonColor(),
              size: 10,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _count = widget.count;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(AddPlus oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Color _getRemovebuttonColor() {
    return _count > 1
        ? KColorConstant.cartItemChangenumBtColor
        : KColorConstant.cartDisableColor;
  }

  Border _getRemoveBtBorder() {
    return Border(
        bottom: BorderSide(width: 1, color: _getRemovebuttonColor()),
        top: BorderSide(width: 1, color: _getRemovebuttonColor()),
        left: BorderSide(width: 1, color: _getRemovebuttonColor()));
  }

  Border _getAddBtBorder() {
    return Border(
        bottom: BorderSide(width: 1, color: _getAddbuttonColor()),
        top: BorderSide(width: 1, color: _getAddbuttonColor()),
        right: BorderSide(width: 1, color: _getAddbuttonColor()));
  }

  _getAddbuttonColor() {
    return _count >= widget.max
        ? KColorConstant.cartDisableColor
        : KColorConstant.cartItemCountTxtColor;
  }
}
