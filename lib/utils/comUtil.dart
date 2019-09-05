import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import '../globleConfig.dart';
import '../utils/screen_util.dart';

class ComFunUtil {
  static padNum(String pad) {
    var num = '${(double.parse(pad) / 60).toInt()}';
    var len = num.toString().length;
    while (len < 2) {
      num = '0' + num;
      len++;
    }
    return num;
  }

  static dealDuration(String duration,{bool ismil=false}) {
   if(ismil)
     duration= Duration(milliseconds:int.tryParse(duration)).inSeconds.toString();

    var ge = '${(double.parse(duration) % 60).toInt()}';
    var miao = '00';
    if (ge.length == 1) {
      miao = '0' + ge;
    } else {
      miao = ge;
    }
    return padNum(duration) + ':$miao';
  }

  static String getImgPath(String name, {String format: 'png'}) {
    return 'images/$name.$format';
  }

  static Color nameToColor(String name) {
    // assert(name.length > 1);
    final int hash = name.hashCode & 0xffff;
    final double hue = (360.0 * hash / (1 << 15)) % 360.0;
    return HSVColor.fromAHSV(1.0, hue, 0.4, 0.90).toColor();
  }

  static bool isChinaPhoneLegal(String str) {
    return new RegExp(
            '^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$')
        .hasMatch(str);
  }

  static String getTimeDuration(String comTime) {
    var nowTime = DateTime.now();
    var compareTime = DateTime.parse(comTime);
    if (nowTime.isAfter(compareTime)) {
      if (nowTime.year == compareTime.year) {
        if (nowTime.month == compareTime.month) {
          if (nowTime.day == compareTime.day) {
            if (nowTime.hour == compareTime.hour) {
              if (nowTime.minute == compareTime.minute) {
                return '片刻之间';
              }
              return (nowTime.minute - compareTime.minute).toString() + '分钟前';
            }
            return (nowTime.hour - compareTime.hour).toString() + '小时前';
          }
          return (nowTime.day - compareTime.day).toString() + '天前';
        }
        return (nowTime.month - compareTime.month).toString() + '月前';
      }
      return (nowTime.year - compareTime.year).toString() + '年前';
    }
    return 'time error';
  }

  static double setPercentage(percentage, context) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Display date picker.
  static void showDatePicker(context, Function callback) {
    DateTime nowDay = DateTime.now();
    final bool showTitleActions = false;
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minYear: 1970,
      maxYear: 2035,
      initialYear: nowDay.year,
      initialMonth: nowDay.month,
      initialDate: nowDay.day,
      confirm: Text(
        '确定',
        style: TextStyle(color: Colors.red),
      ),
      cancel: Text(
        '取消',
        style: TextStyle(color: Colors.cyan),
      ),
      locale: 'zh',
      dateFormat: 'yyyy-mm-dd',
      onChanged: (year, month, date) {
//        debugPrint('onChanged date: $year-$month-$date');
/*        if (!showTitleActions) {
          callback(
              '$year-${month.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}');
        }*/
      },
      onConfirm: (year, month, date) {
        callback(
            '$year-${month.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}');
      },
    );
  }

  void showSnackDialog<T>({BuildContext context, Widget child}) {
    final GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();
    showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        _scaffoldKey1.currentState.showSnackBar(
          SnackBar(
            content: Text('您选择了: $value'),
          ),
        );
      }
    });
  }

  static String getTimeDate(String comTime) {
    var compareTime = DateTime.parse(comTime);
    String weekDay = '';
    switch (compareTime.weekday) {
      case 2:
        weekDay = '周二';
        break;
      case 3:
        weekDay = '周三';
        break;
      case 4:
        weekDay = '周四';
        break;
      case 5:
        weekDay = '周五';
        break;
      case 6:
        weekDay = '周六';
        break;
      case 7:
        weekDay = '周日';
        break;
      default:
        weekDay = '周一';
    }
    return '${compareTime.month}-${compareTime.day}  $weekDay';
  }

  Widget buildMyButton(BuildContext context, String text, Function pressfun,
      {double width ,double height ,
      Color bgcolor =const Color(0xFF5FB419),
      bool disabled = false,
        TextStyle textstyle,}) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
         RaisedButton(
            color: bgcolor,
            elevation: 4,
            child: Container(
                alignment: Alignment.center,
                width: width ?? 100,
                height:height?? 44,
                child: Text(
                  text,
                  style:  textstyle ?? TextStyle(fontWeight: FontWeight.w600,fontFamily: 'FZLanTing',
                      fontSize:16, color: Colors.white),
                  maxLines: 1,
                )),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            onPressed:disabled?null: pressfun),
      ],
    );


  }

  Widget buideStandInput(BuildContext context, String Labtext,
      TextEditingController textControllor,
      {String osType = 'ios',
      String iType,
      int maxlen,
      int maxlines,
      TextAlign txtalign,
      TextDirection txtdrt,
      TextStyle textstyle,
      bool enable = true,
      Function valfun,
      Function svefun,
      Function changfun,
      bool tapfun = false,
      bool showPlaceholder = false}) {
    Widget iosTextInput = CupertinoTextField(
      controller: textControllor ?? null,
      textAlign: txtalign ?? TextAlign.right,
      prefix: Text(Labtext,
          style: textstyle ?? TextStyle(color: GlobalConfig.mainColor)),
      placeholder: showPlaceholder ? "请输入$Labtext" : '',
      suffix: tapfun
          ? Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
              size: 12,
            )
          : null,
      maxLines: maxlines ?? 1,
      maxLength: maxlen ?? null,
      keyboardType: iType == 'number' ? TextInputType.number : null,
      /* inputFormatters: <TextInputFormatter>[
        iType == 'number' ? WhitelistingTextInputFormatter.digitsOnly : null,
      ],*/
      enabled: enable, // 是否可编辑
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 11.0),
      decoration: const BoxDecoration(
        border: Border(
            bottom:
                BorderSide(width: 0.0, color: CupertinoColors.inactiveGray)),
      ),
      onChanged: changfun ?? null,
    );

    Widget adrformInput = TextFormField(
      controller: textControllor ?? null,
//      style: TextStyle(fontSize: 12),
      textAlign: txtalign ?? TextAlign.right,
      cursorColor: GlobalConfig.mainColor,
      maxLines: maxlines ?? 1,
      maxLength: maxlen ?? null,
      keyboardType: iType == 'number' ? TextInputType.number : null,
      inputFormatters: <TextInputFormatter>[
        iType == 'number' ? WhitelistingTextInputFormatter.digitsOnly : null,
      ],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
//        border: InputBorder.none,
//  border: OutlineInputBorder(),
        hintText: tapfun ? "<…>" : "请输入$Labtext",
        hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
      validator: valfun ?? null,
      onSaved: svefun ?? null,
    );
/*

    Widget textInput = TextField(
//      autofocus: true,
      controller: textControllor,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLines: 1,
      maxLength: maxlen ?? null,
      keyboardType: iType == 'number' ? TextInputType.number : null,
      inputFormatters: <TextInputFormatter>[
        iType == 'number' ? WhitelistingTextInputFormatter.digitsOnly : null,
      ],

      decoration: new InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
        hintText: "请输入$Labtext",
      ),
    );
*/

    Widget textInputRow = Row(children: <Widget>[
      Text(
        Labtext,
        style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2),
      ),
      Expanded(
        flex: 1,
        child: adrformInput,
      ),
    ]);

    return tapfun
        ? IgnorePointer(
            child: osType == 'ios' ? iosTextInput : textInputRow,
          )
        : osType == 'ios' ? iosTextInput : textInputRow;
  }

  void alertMsg(BuildContext context,Map<String, dynamic> message){
    if(message.isNotEmpty){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => new AlertDialog(
              title: new Text("公告:"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text( message['message_title']),
                    SizedBox(height: 10,),
                    Text( message['message_content']),
                    SizedBox(height: 15,),
                    Text(ComFunUtil.getTimeDuration(message['send_time'].toString())),

                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("确定"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ]));
    }

  }
}
