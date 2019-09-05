import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/globle_model.dart';
import '../video/audioPlayerXbx.dart';
import '../views/category.dart';
import '../utils/screen_util.dart';
import '../globleConfig.dart';

class SecondPage extends StatefulWidget {
  @override
  SecondPageState createState() => new SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return  ScopedModelDescendant<globleModel>(builder: (context, child, model)
    {
      if (model.url != '' && model.url != null) {
        print("99999999999999999999444444444444444444449999999999999999999");
       return   AudioPlayerXbx(url: model.url, video: model.video, info: model.info,);
      }
      else{
        double extralHeight = Klength.topBarHeight + //顶部标题栏高度
            Klength.bottomBarHeight + //底部tab栏高度
            ScreenUtil.statusBarHeight + //状态栏高度
            ScreenUtil.bottomBarHeight; //IPhoneX底部状态栏
        return   Category(
          rightListViewHeight: ScreenUtil.screenHeight - extralHeight,
        );
      }

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(SecondPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}