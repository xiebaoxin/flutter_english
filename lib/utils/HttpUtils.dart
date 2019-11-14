import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:package_info/package_info.dart';
import '../views/login.dart';
import '../utils/updateApp.dart';
import '../globleConfig.dart';
import '../utils/DialogUtils.dart';
import '../model/globle_model.dart';

class HttpUtils {
  /// global dio object
  static Dio dio;

  /// default options
  static const String API_PREFIX = 'http://app.hukabao.com/index.php/Api/';
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 10000;
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  /// http request methods
  static const String GET = 'GET';
  static const String POST = 'POST';
  static const String PUT = 'PUT';
  static const String PATCH = 'PATCH';
  static const String DELETE = 'DELETE';

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Options options;

  /// 创建 dio 实例对象 context
  static Dio createInstance() {
    if (dio == null) {
      dio = new Dio();
      dio.options.baseUrl = GlobalConfig.base;
      dio.options.connectTimeout = CONNECT_TIMEOUT;
      dio.options.receiveTimeout = RECEIVE_TIMEOUT;
      dio.options.contentType = ContentType.parse(CONTENT_TYPE_FORM);
/*
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
        // 在请求被发送之前做一些事情
        String token =await HttpUtils().theToken;
          options.headers = {
            'access-token': token,
//          'Authorization': 'Bearer ' + token,
          };

        return options; //continue
        // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      }, onResponse: (Response response) {
        // 在返回响应数据之前做一些预处理
        return response; // continue
      }, onError: (DioError e) {
        // 当请求失败时做一些预处理
        return e; //continue
      }));*/
    }
    return dio;
  }

  static clear() {
    dio = null;
  }

  Future<String> get theToken async {
    final SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    return token;
  }

  //get请求
  Future get(String url, Function callBack,
      {Map<String, dynamic> params, Function errorCallBack}) async {
    await _request(url, callBack,
        method: GET,
        params: params,
        errorCallBack: errorCallBack,
        withToken: false);
  }

  //没有Token的 post请求
  static Future post(BuildContext context, String url, Function callBack,
      {Map<String, dynamic> params}) async {
    dio = createInstance();

    if (url == "Pub/Login") {
      String ostype = "android";
      if (UpdateApp.defaultTargetPlatform == TargetPlatform.android) {
        ostype = "android";
      } else if (UpdateApp.defaultTargetPlatform == Platform.isIOS) {
        ostype = "ios";
      } else {
        ostype = "other";
      }
      var packageInfo = await PackageInfo.fromPlatform();
      dio.options.headers = {
        'version': packageInfo.version,
        'os': ostype,
        'from': "app"
      };
    }

    if (params == null || params.isEmpty) {
      params = {};
    }

    try {
      Response response = await dio.post(GlobalConfig.base + url,
          data: params,
          options: new Options(
              contentType:
                  ContentType.parse("application/x-www-form-urlencoded")));

      int statusCode = response.statusCode;
      if (statusCode < 0) {
        String errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(context, errorMsg);
      }

      if (response.data["status"].toString() == '-2') {
        await DialogUtils.close2Logout(context);
      }

      if (callBack != null) {
        callBack(response.data);
      } else {
        _handError(
          context,
          '请求成功',
        );
      }
    } catch (e) {
      print('请求异常:' + e.toString());
    }
  }

  //具体的还是要看返回数据的基本结构
  static Future _request(String url, Function callBack,
      {String method,
      Map<String, dynamic> params,
      Function errorCallBack,
      BuildContext context,
      bool withToken = true}) async {
    print("-----<net---> url :<" + method + ">" + url);
    if (params != null && params.isNotEmpty) {
      print("<net> params :" + params.toString());
    }

    String errorMsg = "";
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      errorMsg = "请检查网络";
      print("请检查网络");
      _handError(context, errorMsg);
    }

    dio = createInstance();
    if (withToken == true) {
      final model = globleModel().of(context);
      String token = model.token;

      dio.options.headers = {
        'access-token': token,
      };
    }

    if (method == GET) {
      //组合GET请求的参数
      if (params != null && params.isNotEmpty) {
        /// restful 请求处理
        params.forEach((key, value) {
          if (url.indexOf(key) != -1) {
            url = url.replaceAll(':$key', value.toString());
          }
        });
      }
    }

    if (params == null || params.isEmpty) {
      params = {};
    }

    try {
      Response response = await dio.request(GlobalConfig.base + url,
          data: params, options: Options(method: method));

      int statusCode = response.statusCode;
      if (statusCode < 0 && errorCallBack != null) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(context, errorMsg);
      }
      String ercd = response.data['status'].toString() ?? '0';
      response.data["status"] = ercd;
      if (ercd == '-2') {
        print(response.data);
        await DialogUtils.close2Logout(context);
        return;
      }

      if (callBack != null) {
        callBack(response.data);
      } else {
        _handError(context, '请求成功');
      }
    } catch (exception) {
      if (errorCallBack != null)
        _handError(context, exception.toString(), errorCallback: errorCallBack);
    }
  }

  //post请求--不需要token身份验证
  static Future apipost(BuildContext context, String url,
      Map<String, dynamic> params, Function callBack) async {
    await dioappi(
      url,
      params,context: context
    ).then((response) {
      callBack(response.data);
    });
//    await _request(url, callBack, method: POST, params: params, context: context);
  }

  static Future dioappi(String url, Map<String, dynamic> params,
      {String method = POST,
      BuildContext context,
      bool withToken = false}) async {
    print("=-=-=-=-=-dioappi=-=-=-=-=--");
    if (params != null && params.isNotEmpty) {
      print("<net> params :" + params.toString());
    }

    dio = createInstance();
    if (withToken == true) {
      if(context!=null){
      final model = globleModel().of(context);
      String token = model.token;
      print(token);
      dio.options.headers = {
        'access-token': token,
      };
      }
    }
    if (params == null || params.isEmpty) {
      params = {};
    }

    try {
      Response response;
      if (method == GET) {
        response =
            await dio.get(GlobalConfig.base + url, queryParameters: params);
      } else if (method == POST) {
        response = await dio.post(GlobalConfig.base + url, data: params);
      } else
        response = await dio.request(GlobalConfig.base + url,
            data: params, options: Options(method: method));

      Map<String, dynamic> nrespon = response.data;

      if (context!=null){
        final modelw = globleModel().of(context);
        if(nrespon["config"]!=null)
          await modelw.setConfig(nrespon["config"]);
      }
      print("==================dioapp--$url----end=================================");
      return nrespon;
//      Entity entity = Entity.fromJson(map);
      return response.data;
    } on DioError catch (error) {
      // 请求错误处理
      Response errorResponse;
      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      /*   // 超时
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        errorResponse.statusCode = YYResultCode.NETWORK_TIMEOUT;      }
*/
/*      await DialogUtils.showToastDialog(context,"网络请求异常:${errorResponse.statusCode}${error.message}");*/
      DialogUtils().showToast(
          context, "网络请求异常:${errorResponse.statusCode}${error.message}");
      return {'status':-1,'msg':error.message};
    }
  }

  static Future dioWithToken(String url, Map<String, dynamic> params, String token,
      {String method = POST,
      }) async {
    print("=-=-=-dioWithToken=-$url-=-=-=-=--");
    dio = createInstance();
    dio.options.headers = {
      'access-token': token,
    };
    if (params == null || params.isEmpty) {
      params = {};
    }
    try {
      Response response;
      if (method == GET) {
        response =
        await dio.get(GlobalConfig.base + url, queryParameters: params);
      } else if (method == POST) {
        response = await dio.post(GlobalConfig.base + url, data: params);
      } else
        response = await dio.request(GlobalConfig.base + url,
            data: params, options: Options(method: method));
      print(response.data);
      return response.data;
    } on DioError catch (error) {
      // 请求错误处理
      Response errorResponse;
      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      return {'status':-1,'msg':error.message,};
    }
  }


  static Future dioFormAppi(String url,FormData params,
      {String method = POST,
        BuildContext context,
        bool withToken = false}) async {

    dio = createInstance();
    if (withToken == true) {
      if(context!=null){
        final model = globleModel().of(context);
        String token = model.token;
        print(token);
        dio.options.headers = {
          'access-token': token,
        };
      }
    }

    try {
      Response response;
      if (method == GET) {
        response =
        await dio.get(GlobalConfig.base + url, queryParameters: params);
      } else if (method == POST) {
        response = await dio.post(GlobalConfig.base + url, data: params);
      } else
        response = await dio.request(GlobalConfig.base + url,
            data: params, options: Options(method: method));

      Map<String, dynamic> nrespon = response.data;

      if (context!=null){
        final modelw = globleModel().of(context);
        if(nrespon["config"]!=null)
          await modelw.setConfig(nrespon["config"]);
      }
      print("==================dioapp--$url----end=================================");
      print(response.data);
      return response.data;
    } on DioError catch (error) {
      // 请求错误处理
      Response errorResponse;
      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }

      DialogUtils.showToastDialog(context,"网络请求异常:${errorResponse.statusCode}${error.message}");
      return {'status':-1,'msg':error.message};
    }
  }

  //处理异常
  static void _handError(BuildContext context, String errorMsg,
      {Function errorCallback}) async {
    print("<net> errorMsg :" + errorMsg);
    if (errorCallback != null) {
      await DialogUtils.showToastDialog(context, errorMsg);
    } else
      errorCallback(errorMsg);
  }
}
