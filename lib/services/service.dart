import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:aplikasi_antrian/configs/exceptions/error_dio_handler.dart';
import 'package:aplikasi_antrian/services/api_interceptors.dart';
import 'package:dio/dio.dart';
import 'package:aplikasi_antrian/locator.dart';

class Service {
  Dio dio = locator<ApiInterceptors>().dio;
  // String baseUrl = 'http://192.168.1.12/antrian_backend/api/v1';
  String baseUrl = 'http://api.antrian.aiiviii.biz.id/v1';


  Future get(String url) async {
    try {
      url = baseUrl + url;
      if (await locator<ApiInterceptors>().checkConnection()) {
        final response =
        dio.get(url, options: Options(headers: {"requiresToken": true}));
        return response;
      } else {
        print('no');
        throw TimeoutException('no_internet');
      }
    } on TimeoutException catch (e) {
      throw SocketException('no_internet');
    } catch (error) {
      log(error.toString(), name: 'error');
      errorDioHandler(error);
    }
  }

  Future postLogin2(String url, var data) async {
    try{
      url = baseUrl + url;
      print(url);
      if (await locator<ApiInterceptors>().checkConnection()) {
        print(data);
        final Response response = await dio.post(url,
            options: Options(headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            }),
            data: data);
        return response;
      } else {
        print('no');
        throw SocketException('no_internet');
      }
    }on TimeoutException catch (e) {
      throw SocketException('no_internet');
    } catch (error) {
      errorDioHandler(error);
    }
  }


  Future post(String url, var data) async {
    try{
      url = baseUrl + url;
      print(url);
      if (await locator<ApiInterceptors>().checkConnection()) {
        final response = await dio.post(url,
            options: Options(headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              "requiresToken": true
            }),
            data: data);
        return response;
      } else {
        print('no');
        throw SocketException('no_internet');
      }
    } on TimeoutException catch (e) {
      throw SocketException('no_internet');
    } catch (error) {
      errorDioHandler(error);
    }
  }

  Future postImage(String url, var data) async {
    url = baseUrl + url;
    print(url);
    print(data);

    if (await locator<ApiInterceptors>().checkConnection()) {
      final response = await dio.post(url,
          options:
          Options(sendTimeout: 20000, headers: {'requiresToken': true, 'content-type': null}),
          data: data);
      print(response);
      return response;
    } else {
      print('no');
      throw SocketException('no_internet');
    }
  }


  Future patch(String url, var data) async {
    if (await locator<ApiInterceptors>().checkConnection()) {
      final response = await dio.patch(url,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }),
          data: data);
      return response;
    } else {
      print('no');
      throw SocketException('no_internet');
    }
  }

}