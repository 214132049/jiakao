import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'deviceUtil.dart';
import 'homePage.dart';

class LoginPage extends StatefulWidget {

  LoginPage({Key key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String _code = '';
  bool checked = false;
  String host = 'http://10.0.2.2:7001' ;
  final deviceInfo = DeviceInfo();

  LoginPageState() {
    checkDevice();
  }

  Future checkDevice() async {
    String androidId = await deviceInfo.getDeviceInfo();
    try {
      var url = '$host/api/check';
      var response = await http.post(url, body: {'deviceId': androidId});
      if (response.statusCode != 200) {
        throw Error.safeToString('请求异常');
      }
      var data = jsonDecode(response.body);
      if (data['code'] != 1) {
        throw Error.safeToString(data['message']);
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (exception) {
      setState(() {
        checked = true;
      });
      EasyLoading.showError(exception.replaceAll('"', ''));
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future activeDevice() async {
    if (_code.trim() == '') {
      EasyLoading.showToast('请先输入激活码');
      return;
    }
    EasyLoading.show(status: 'loading...');
    String androidId = await deviceInfo.getDeviceInfo();

    try {
      var url = '$host/api/active';
      var response = await http.post(url, body: {'code': _code, 'deviceId': androidId});
      if (response.statusCode != 200) {
        throw Error.safeToString('请求异常');
      }
      var data = jsonDecode(response.body);
      if (data['code'] != 1) {
        throw Error.safeToString(data['message']);
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (exception) {
      EasyLoading.showError(exception.replaceAll('"', ''));
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _enter() {
    activeDevice();
  }

  void _setCode(v) {
    setState(() {
      _code = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!checked) {
      return Scaffold();
    }
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(28.0),
      child: Wrap(children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 100.0),
          child: Text(
            '激活码登录',
            style: TextStyle(fontSize: 24.0),
          ),
        ),
        Container(
            padding:
                EdgeInsets.only(left: 30.0, right: 30.0, top: 2.0, bottom: 2.0),
            margin: EdgeInsets.only(top: 50.0, bottom: 30.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Color.fromRGBO(0, 0, 0, 0.1))),
            child: TextField(
              onChanged: _setCode,
              style: TextStyle(
                  textBaseline: TextBaseline.alphabetic, fontSize: 18.0),
              decoration: InputDecoration(
                hintText: '请输入激活码',
                border: InputBorder.none,
              ),
            )),
        Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xffffa192), Color(0xffff775d)]), // 渐变色
                borderRadius: BorderRadius.circular(48.0)),
            child: MaterialButton(
                textColor: Colors.white,
                height: ScreenUtil().setHeight(48.0),
                onPressed: _enter,
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
