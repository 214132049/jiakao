import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'deviceUtil.dart';
import 'questionPage.dart';
import 'loginPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final deviceInfo = DeviceInfo();
  String _questionType;
  SharedPreferences _prefs;

  @override
  initState() {
    super.initState();
    _checkDevice();
    _init();
  }

  _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future _checkDevice() async {
    return deviceInfo.deviceStatus();
  }

  Future<void> _showModal(String type) async {
    _questionType = type;
    int status = _prefs?.getInt('deviceStatus');
    if (status == null) {
      status = await _checkDevice();
    }
    if (status == 0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginPage()));
      return;
    }
    if (status == 2) {
      _jumpPage();
      return;
    }
  }

  _jumpPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => QuestionPage(type: _questionType)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 50),
          child: Text(
            '请选择身份，开始模拟考试',
            style: TextStyle(fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: () => _showModal('1'),
          child: Container(
              width: 240.0,
              height: 100.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color.fromRGBO(255, 119, 93, 0.1)),
              child: Text('企业主要负责人',
                  style: TextStyle(fontSize: 20.0, color: Color(0xffff775d)))),
        ),
        GestureDetector(
          onTap: () => _showModal('2'),
          child: Container(
              width: 240.0,
              height: 100.0,
              margin: EdgeInsets.only(top: 30.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color.fromRGBO(255, 119, 93, 0.1)),
              child: Text('安全生产管理人员',
                  style: TextStyle(fontSize: 20.0, color: Color(0xffff775d)))),
        )
      ],
    );
  }
}
