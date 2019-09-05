import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info/package_info.dart';
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import '../globleConfig.dart';
import '../utils/DialogUtils.dart';

class UpdateApp {
  static Dio dio;

  Options options;

  /// 创建 dio 实例对象 context
  static Dio createInstance() {
    if (dio == null) {
      dio = new Dio();
      dio.options.baseUrl = GlobalConfig.base;
      dio.options.connectTimeout = 10000;
//      dio.options.receiveTimeout = 5000;
//      dio.options.contentType=ContentType.binary.
    }

    return dio;
  }

  static clear() {
    dio = null;
  }

  // 获取安装地址
  Future<String> get apkLocalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  static TargetPlatform get defaultTargetPlatform {
    TargetPlatform result;
    //这里根据平台来赋值，但是只有iOS、Android、Fuchsia，没有PC
    if (Platform.isIOS) {
      result = TargetPlatform.iOS;
    } else if (Platform.isAndroid) {
      result = TargetPlatform.android;
    } else if (Platform.isFuchsia) {
      result = TargetPlatform.fuchsia;
    }
    assert(() {
      if (Platform.environment.containsKey('FLUTTER_TEST'))
        result = TargetPlatform.android;
      return true;
    }());
    //这里判断debugDefaultTargetPlatformOverride有没有值，有值的话，就赋值给result
//    'package:flutter/foundation.dart';
    if (debugDefaultTargetPlatformOverride != null)
      result = debugDefaultTargetPlatformOverride;

    //如果到这一步，还没有取到 TargetPlatform 的值，就会抛异常
    if (result == null) {
      throw FlutterError('Unknown platform.\n'
          '${Platform.operatingSystem} was not recognized as a target platform. '
          'Consider updating the list of TargetPlatforms to include this platform.');
    }
    return result;
  }

  Future<bool> checkPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
  //处理异常
  static void _handError(String errorMsg, {BuildContext context}) {
    print("<net> errorMsg :" + errorMsg);
//      DialogUtils.showToastDialog(context);
  }

  //具体的还是要看返回数据的基本结构
  Future<bool> get checkDownloadApp async {

    print("<net---> checkDownloadApp :");
    String errorMsg = "";
    int statusCode;
    bool isupdate = false;
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      errorMsg = "请检查网络";
      print("请检查网络");
      _handError(errorMsg);
    }

    try {
      Dio dio = createInstance();
      String url = GlobalConfig.base + 'Pub/upGrade';
      if (defaultTargetPlatform == TargetPlatform.android) {
        url =  GlobalConfig.base + 'Pub/upGrade/type/0';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        url =  GlobalConfig.base + 'Pub/upGrade/type/1';
      } else {
        ;
      }

      await dio.get(url).then((Response response) async {
print(response.data["update"]);
        statusCode = response.statusCode;
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorMsg);
        }
        if (response.data["update"] != null) {
          final newVersion = response.data["update"]['verCode'];
          // 获取此时版本
          final packageInfo = await PackageInfo.fromPlatform();
          /* print(packageInfo.version); //1.0.0
          print(packageInfo.packageName);
          print(packageInfo.buildNumber); //1
          print(packageInfo.appName);
          print(defaultTargetPlatform);*/
//          await SimplePermissions.requestPermission(  Permission.WriteExternalStorage);

//          if (await SimplePermissions.checkPermission(Permission.WriteExternalStorage)) {
        if(await checkPermission()){
            if (newVersion.compareTo(packageInfo.buildNumber) > 0) {
              isupdate = true;
            }
          } else {
            print('权限不容许');
          }
        }
      });
    } catch (exception) {
      _handError(exception.toString());
    }
    return isupdate;
  }

}
