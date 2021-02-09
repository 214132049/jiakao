import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'constants.dart';

class DeviceInfo {
  static SharedPreferences _prefs;

  Future<String> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    return androidInfo.androidId;
  }

  /// status  0: 未激活  1:激活未支付  2:支付完成
  Future<int> deviceStatus() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setInt('deviceStatus', 0);

    String androidId = await this.getDeviceInfo();
    String url = '$apiHost/api/check';
    var response = await http.post(url, body: {
      'deviceId': androidId
    }).timeout(Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Error.safeToString('初始化失败');
    }
    var data = jsonDecode(response.body);
    var res = data['data'];
    if (data['code'] != 1 || res == null) {
      return 0;
    }
    _prefs.setInt('deviceStatus', res['status']);
    return res['status'];
  }
}
