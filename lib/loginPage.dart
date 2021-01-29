import 'dart:async';
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
  Timer _timer;
  int _countdown = 60;
  int _seconds;
  bool _available = true; // 是否可以获取验证码
  String _verifyStr = '获取验证码';

  LoginPageState() {
    EasyLoading.instance..userInteractions = false;
    // checkDevice();
  }

  Future _getCode() async {
    if (!_available) {
      return;
    }
    _seconds = _countdown;
    _startTimer();
    print('21');
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() {
          _verifyStr = '重新发送';
          _available = true;
          _seconds = _countdown;
        });
        _cancelTimer();
        return;
      }
      setState(() {
        _available = false;
        _verifyStr = '已发送$_seconds' + 's';
      });
      _seconds -= 1;
    });
  }

  /// 取消倒计时的计时器。
  void _cancelTimer() {
    // 计时器（`Timer`）组件的取消（`cancel`）方法，取消计时器。
    _timer?.cancel();
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
    _jumpPage();
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
  void dispose() {
    ///取消计时器
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(30.0),
          child: Wrap(children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 60.0),
                child: Text('手机号登录',
                    style: TextStyle(
                        fontSize: 28.0, fontWeight: FontWeight.bold))),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                margin: EdgeInsets.only(top: 50.0, bottom: 5.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Color(0xffeeeeee)))),
                child: TextField(
                  onChanged: _setName,
                  style: TextStyle(fontSize: 18.0),
                  decoration: InputDecoration(
                    hintText: '请输入姓名',
                    border: InputBorder.none,
                  ),
                )),
            Container(
              padding: EdgeInsets.only(left: 10.0),
              margin: EdgeInsets.only(right: 5.0),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1.0,
                          style: BorderStyle.solid,
                          color: Color(0xffeeeeee)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 230.0,
                    child: TextField(
                      onChanged: _setPhone,
                      style: TextStyle(fontSize: 18.0),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '请输入手机号',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  MaterialButton(
                      color: Color(0xffff775d),
                      disabledColor: Color(0x90ff775d),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: _available ? _getCode : null,
                      child: Text(
                        _verifyStr,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)))
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                margin: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Color(0xffeeeeee)))),
                child: TextField(
                  onChanged: _setCode,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18.0),
                  decoration: InputDecoration(
                    hintText: '请输入验证码',
                    border: InputBorder.none,
                  ),
                )),
            Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 40.0),
                decoration: BoxDecoration(
                    color: Color(0xffff775d), // 渐变色
                    borderRadius: BorderRadius.circular(48.0)),
                child: MaterialButton(
                    textColor: Colors.white,
                    onPressed: _activeDevice,
                    child: Text(
                      '登录',
                      style: TextStyle(fontSize: 20.0, letterSpacing: 12.0),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48.0)))),
          ]),
        ));
  }
}
