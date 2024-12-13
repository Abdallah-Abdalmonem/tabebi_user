import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/userdata.dart';
import 'package:tabebi/screens/mainHome/mainPage.dart';
import 'apiParams.dart';
import 'constant.dart';
import 'customException.dart';
import 'generalMethods.dart';
import 'sessionManager.dart';

class Api {
  static Map<String, String> headers() {
    String apiToken = "";
    if (Constant.session != null) {
      apiToken = Constant.session!.getData(SessionManager.keyToken);
    }
    print("token=>$apiToken");
    return {
      "Authorization": "Bearer $apiToken",
      "accept": "application/json",
    };
  }

  static Future getFileLength(String url, {String? filelength}) async {
    if (filelength != null && filelength.trim().isNotEmpty) return filelength;
    Response r = await head(Uri.parse(url));

    return GeneralMethods.getFileSizeString(
        bytes: int.parse(r.headers["content-length"]!));
  }

  static Future downloadFile(String url, BuildContext context,
      {String? filename}) async {
    try {
      Response response = await get(Uri.parse(url));
      String fileMainName = url.substring(url.lastIndexOf("/") + 1);

      String path = Constant.filePath + "/" + (filename ?? fileMainName);
      File file = File(path);
      print("dwpath/**/->${file.path}");
      file.writeAsBytes(response.bodyBytes);
      print("dwpath//->${file.path}");

      return {"path": file.path, "message": getLables(lblFileDownloaded)};
    } catch (e) {
      return {"path": "", "message": e.toString()};
    }
  }

  static Future sendApiRequest(
      String url, Map<String, dynamic> body, bool ispost, BuildContext context,
      {bool isputmethod = false}) async {
    Response response;

    String mainurl = url;
    if (!url.contains("http")) {
      mainurl = Constant.baseUrl + url;
    }
    body[ApiParams.lang] = Constant.session!.getCurrLangCode();
    String cityid = Constant.session!.getData(SessionManager.keyCityId);
    if (body.containsKey(ApiParams.cityId)) {
      body.remove(ApiParams.cityId);
    }
    if (cityid.trim().isNotEmpty && cityid.trim() != "0") {
      body[ApiParams.cityId] = cityid;
    } else if (!body.containsKey(ApiParams.provinceId)) {
      body[ApiParams.provinceId] =
          Constant.session!.getData(SessionManager.keyProvinceId);
    }

    print("url=>$mainurl");
    print("params->$url=>$body");

    try {
      if (isputmethod) {
        response = await put(Uri.parse(mainurl),
            body: body.isNotEmpty ? body : null, headers: headers());
      } else if (ispost) {
        print("$url=>$body");
        response = await post(Uri.parse(mainurl),
            body: body.isNotEmpty ? body : null, headers: headers());
      } else {
        response = await get(Uri.parse(mainurl), headers: headers());
      }

      return getJsonResponse(context, isfromfile: false, response: response);
    } on SocketException {
      throw FetchDataException(getLables(noInternetErrorMessage));
    } on TimeoutException {
      throw FetchDataException(getLables(dataNotFoundErrorMessage));
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  static getResponseData(bool isfromfile, StreamedResponse? streamedResponse,
      Response? response) async {
    if (isfromfile) {
      var responseData = await streamedResponse!.stream.toBytes();
      print("response->${String.fromCharCodes(responseData)}");
      return String.fromCharCodes(responseData);
    } else {
      print("response->=${response!.body}");
      return response!.body;
    }
  }

  static getJsonResponse(BuildContext context,
      {bool isfromfile = false,
      StreamedResponse? streamedResponse,
      Response? response}) async {
    int code;
    if (isfromfile) {
      code = streamedResponse!.statusCode;
    } else {
      code = response!.statusCode;
    }
    print("statuscode-$code");
    switch (code) {
      case 200:
        var data =
            await getResponseData(isfromfile, streamedResponse, response);
        if (data == "null") {
          throw CustomException(getLables(dataNotFoundErrorMessage));
        }
        return data;
      case 400:
        var data =
            await getResponseData(isfromfile, streamedResponse, response);

        throw BadRequestException(errMsg(context, data, returnData: true));
      case 401:
        Map getdata = {};
        var data =
            await getResponseData(isfromfile, streamedResponse, response);
        getdata = json.decode(data);

        if (Constant.session!.isUserLoggedIn()) {
          Constant.session!.logoutUser(context);
        }
        throw UnauthorisedException(errMsg(context, getdata));
      case 403:
        var data =
            await getResponseData(isfromfile, streamedResponse, response);
        throw UnauthorisedException(data.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode: $code');
    }
  }

  static errMsg(BuildContext context, var getdata, {bool returnData = false}) {
    Map map;

    if (getdata.runtimeType == String) {
      map = json.decode(getdata);
    } else {
      map = getdata;
    }

    Map? mainData;
    if (map.containsKey("data")) {
      Map data = map["data"];
      if (data.isNotEmpty) {
        mainData = data;
      }
    }

    if (mainData == null && map.containsKey("message")) {
      /*if (returnData) {
        return map[ApiParams.message];
      }*/

      return map[ApiParams.message];
    }
    Map data = getdata['data'];

    if (data.containsKey('errors')) {
      return data['errors'];
    } else if (getdata.containsKey(ApiParams.message)) {
      return getdata[ApiParams.message];
    } else if (returnData) {
      return data.toString();
    } else {
      return getLables(somethingwentwrong);
    }
  }

  static Future postApiFile(String url, Map<String, String> filelist,
      BuildContext context, Map<String, dynamic> body,
      {bool passUserid = true}) async {
    try {
      String mainurl = url;
      if (!url.contains("http")) {
        mainurl = Constant.baseUrl + url;
      }
      body[ApiParams.lang] = Constant.session!.getCurrLangCode();
      String cityid = Constant.session!.getData(SessionManager.keyCityId);
      if (body.containsKey(ApiParams.cityId)) {
        body.remove(ApiParams.cityId);
      }
      if (cityid.trim().isNotEmpty && cityid.trim() != "0") {
        body[ApiParams.cityId] = cityid;
      } else if (!body.containsKey(ApiParams.provinceId)) {
        body[ApiParams.provinceId] =
            Constant.session!.getData(SessionManager.keyProvinceId);
      }
      print("url=>$mainurl");
      var request = MultipartRequest('POST', Uri.parse(mainurl));

      request.headers.addAll(headers());
      body.forEach((key, value) {
        print('{ key: $key, value: $value }');
        request.fields[key] = value;
      });

      filelist.forEach((key, value) async {
        String name = key.split("==")[1];
        print('{ file: $name, value: $value }');
        var pic = await MultipartFile.fromPath(name, value);
        request.files.add(pic);
      });

      var res = await request.send();
      return getJsonResponse(context, isfromfile: true, streamedResponse: res);
    } on SocketException {
      throw FetchDataException(getLables(noInternetErrorMessage));
    } on TimeoutException {
      throw FetchDataException(getLables(dataNotFoundErrorMessage));
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  static String getApiMessage(var message) {
    String apimsg = '';
    if (message is String) {
      return apimsg = message;
    } else {
      message.forEach((k, v) {
        if (v is List<dynamic>) {
          apimsg = "${apimsg + v.first}\n";
        } else {
          apimsg = "${apimsg + v}\n";
        }
      });
    }
    return apimsg;
  }

  static getUserInfo(BuildContext context) async {
    Map<String, String?> parameter = {};

    var response = await sendApiRequest(
        ApiParams.apiGetUserDetails, parameter, true, context);

    if (response == null) return;
    var getdata = json.decode(response);

    if (!getdata["error"] && getdata['data'] != null) {
      UserData userData = UserData.fromJson(getdata['data']);
      userData.token = Constant.session!.getData(SessionManager.keyToken);
      Constant.userdata = userData;
      Constant.session!
          .setData(SessionManager.keyUserData, Constant.userdata!.toJson());
    }
  }

  static getAppSettings(BuildContext context) async {
    var response =
        await sendApiRequest(ApiParams.apiGetSettings, {}, true, context);

    if (response == null) return;
    var getdata = json.decode(response);

    if (!getdata['error']) {
      Constant.documentSize =
          double.parse((getdata["data"]["document_size"] ?? 0.0).toString());
      Constant.uploadReportTypes =
          (getdata["data"]["report_type"] ?? "").toString().split(",");
      Constant.uploadReportTypes.toLowerCase();
      Constant.aboutUsData = getdata["data"]["about_us"];
      Constant.contactUsData = getdata["data"]["contact_us"];
      Constant.privacyPolicyData = getdata["data"]["privacy_policy"];
      Constant.termsConditionsData = getdata["data"]["terms_conditions"];
      Constant.currencyCode = getdata["data"]["currency_code"];
      Constant.socialmediaMap.clear();
      if (getdata["data"]["socialmedia"] != null) {
        List<dynamic> map = getdata["data"]["socialmedia"];
        Constant.socialmediaMap.addAll(map);
        if (settingController != null && !settingController!.isClosed) {
          settingController!.sink.add(true);
        }
      }
    }
  }
}

extension LowerCaseList on List<String> {
  void toLowerCase() {
    for (int i = 0; i < length; i++) {
      this[i] = this[i].toLowerCase();
    }
  }
}
