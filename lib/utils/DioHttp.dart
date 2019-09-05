import 'dart:collection';
import 'package:dio/dio.dart';

import 'package:connectivity/connectivity.dart';

class YYConfig {
  static bool DEBUG = true;
}

class YYResultModel {
  var data;
  bool success;
  int code;
  var headers;

  YYResultModel(this.data, this.success, this.code, {this.headers});
}

class PXResultModel {
  String message;
  var result;
  int returnCode;
  String token;

  PXResultModel(this.message, this.result, this.returnCode, this.token);

  static PXResultModel init(Map json) {
    return PXResultModel(
        json["message"], json["result"], json["returnCode"], json["token"]);
  }
}

class YYResultCode {
  ///网络错误
  static const NETWORK_ERROR = -1;

  ///网络超时
  static const NETWORK_TIMEOUT = -2;

  ///网络返回数据格式化一次
  static const NETWORK_JSON_EXCEPTION = -3;

  static const SUCCESS = 200;


  static errorHandleFunction(code, message, noTip) {
    if (noTip) {
      return message;
    }
    return message;
  }
}

class YYResultErrorEvent {
  final int code;

  final String message;

  YYResultErrorEvent(this.code, this.message);
}

class YYRequestManager {
  static String baseUrl = "http://app.hukabao.com/index.php/Api/";
  static Map<String, String> baseHeaders = {
    "packageName": "com.hukabao.hukabao_flutter",
    "appName": "hukabao",
    "version": "0.0.0.1",
    "access-token": "7fc30ec2206ec3135ca9d33d11406b36b048e4950836a678c4642e492",
    "sign": "",
  };

  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";
  static Map optionParams = {
    "timeoutMs": 15000,
    "access-token": null,
    "authorizationCode": null,
  };

  static requestPost(url, params, {noTip = false}) async {
    Options option = new Options(method: "post");
    return await requestBase(baseUrl+url, params, baseHeaders, option, noTip: noTip);
  }

  static requestBase(url, params, Map<String, String> header, Options option,
      {noTip = false}) async {
    // 判断网络
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      return YYResultModel(
          YYResultErrorEvent(YYResultCode.NETWORK_ERROR, "请检查网络"),
          false,
          YYResultCode.NETWORK_ERROR);
    }

    //处理请求头
    Map<String, String> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    //options处理
    if (option != null) {
      option.headers = headers;
    } else {
      option = new Options(method: "get");
      option.headers = headers;
    }
//    option.baseUrl = baseUrl;
    option.connectTimeout = 15000;

    var dio = new Dio();
    Response response;
    try {
      response = await dio.request(url, data:FormData.from(params), options: option);
    } on DioError catch (error) {
      // 请求错误处理
      Response errorResponse;
      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      // 超时
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        errorResponse.statusCode = YYResultCode.NETWORK_TIMEOUT;
      }
      // debug模式才打印
      if (YYConfig.DEBUG) {
        print('请求异常: ' + error.toString());
        print('请求异常url: ' + url);
        print('请求头: ' + option.headers.toString());
        print('method: ' + option.method);
      }
      // 返回错误信息
      return new YYResultModel(
          YYResultCode.errorHandleFunction(
              errorResponse.statusCode, error.message, noTip),
          false,
          errorResponse.statusCode);
    }


    // debug模式打印相关数据
    if (YYConfig.DEBUG) {
      print('请求url: ' + url);
      print('请求头: ' + option.headers.toString());
      if (params != null) {
        print('请求参数: ' + params.toString());
      }
      if (response != null) {
        print('返回参数: ' + response.toString());
      }
    }

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return new YYResultModel(response.data, true, YYResultCode.SUCCESS,
            headers: response.headers);
      }
    } catch (error) {
      print(error.toString() + url);
      return new YYResultModel(response.data, false, response.statusCode,
          headers: response.headers);
    }
    return new YYResultModel(
        YYResultCode.errorHandleFunction(response.statusCode, "", noTip),
        false,
        response.statusCode);
  }
}
