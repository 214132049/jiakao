import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'deviceUtil.dart';
import 'homePage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String _name = '';
  String _phone = '';
  String _code = '';
  String host = 'http://47.103.79.180:80';
  final deviceInfo = DeviceInfo();
  SharedPreferences _prefs;

  LoginPageState() {
    EasyLoading.instance..userInteractions = false;
    // checkDevice();
  }

  Future checkDevice() async {
    _prefs = await SharedPreferences.getInstance();

    if (_prefs.getBool('activated') ?? false) {
      _jumpPage();
      return;
    }

    String androidId = await deviceInfo.getDeviceInfo();
    try {
      EasyLoading.show(status: '初始化中');
      var url = '$host/api/check';
      var response = await http.post(url,
          body: {'deviceId': androidId}).timeout(Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw Error.safeToString('初始化失败');
      }
      var data = jsonDecode(response.body);
      if (data['code'] != 1) {
        return;
      }
      _prefs.setBool('activated', true);
      _jumpPage();
    } catch (exception) {
      if (exception is String) {
        EasyLoading.showError(exception.replaceAll('"', ''));
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future _activeDevice() async {
    if (_name.trim() == '') {
      EasyLoading.showToast('请输入姓名');
      return;
    }
    if (_phone.trim() == '') {
      EasyLoading.showToast('请输入手机号');
      return;
    }
    if (_code.trim() == '') {
      EasyLoading.showToast('请输入验证码');
      return;
    }
    EasyLoading.show(status: 'loading...');
    String androidId = await deviceInfo.getDeviceInfo();

    try {
      var url = '$host/api/active';
      var response = await http.post(url, body: {
        'code': _code,
        'deviceId': androidId
      }).timeout(Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw Error.safeToString('请求异常');
      }
      var data = jsonDecode(response.body);
      if (data['code'] != 1) {
        throw Error.safeToString(data['message']);
      }
      _prefs.setBool('activated', true);
      _jumpPage();
    } catch (exception) {
      if (exception is String) {
        EasyLoading.showError(exception.replaceAll('"', ''));
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  _jumpPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => route == null,
    );
  }

  void _setName(v) {
    setState(() {
      _name = v;
    });
  }

  void _setCode(v) {
    setState(() {
      _code = v;
    });
  }

  void _setPhone(v) {
    setState(() {
      _phone = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(28.0),
      child: Wrap(children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: 60.0),
            child: Text('登录', style: TextStyle(fontSize: 24.0))),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            margin: EdgeInsets.only(top: 50.0, bottom: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Color.fromRGBO(0, 0, 0, 0.1))),
            child: TextField(
              onChanged: _setName,
              style: TextStyle(fontSize: 16.0),
              decoration: InputDecoration(
                hintText: '请输入姓名',
                border: InputBorder.none,
              ),
            )),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            margin: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Color.fromRGBO(0, 0, 0, 0.1))),
            child: TextField(
              onChanged: _setPhone,
              style: TextStyle(fontSize: 16.0),
              decoration: InputDecoration(
                hintText: '请输入手机号',
                border: InputBorder.none,
              ),
            )),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            margin: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Color.fromRGBO(0, 0, 0, 0.1))),
            child: TextField(
              onChanged: _setCode,
              style: TextStyle(fontSize: 16.0),
              decoration: InputDecoration(
                hintText: '请输入验证码',
                border: InputBorder.none,
              ),
            )),
        Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 50.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xffffa192), Color(0xffff775d)]), // 渐变色
                borderRadius: BorderRadius.circular(48.0)),
            child: MaterialButton(
                textColor: Colors.white,
                height: ScreenUtil().setHeight(48.0),
                onPressed: _activeDevice,
                child: Text(
                  '登录',
                  style: TextStyle(fontSize: 20.0, letterSpacing: 16.0),
                ),
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.circular(48.0)))),
      ]),
    ));
  }
}
