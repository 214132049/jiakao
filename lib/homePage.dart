import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:tobias/tobias.dart';

import 'deviceUtil.dart';
import 'questionPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final deviceInfo = DeviceInfo();
  String _payType = 'wePay';

  @override
  initState() {
    super.initState();
    isAliPayInstalled().then((data){
      print("installed $data");
    });
    _initFluwx();
  }

  _initFluwx() async {
    await fluwx.registerWxApi(
        appId: "wxd930ea5d5a258f4f",
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: "https://your.univerallink.com/link/");
    var result = await fluwx.isWeChatInstalled;
    print("is installed $result");
    String _result;
    fluwx.weChatResponseEventHandler.listen((res) {
      if (res is fluwx.WeChatPaymentResponse) {
        setState(() {
          _result = "pay :${res.isSuccessful}";
        });
      }
    });
  }

  void _showModal(String type) {
    Future<void> future = _showBottomSheet(type);
    future.then((value) {
      setState(() {
        _payType = 'wePay';
      });
    });
  }

  Future _payAction(String type) async {
    var payMethod;
    if (_payType == 'wePay') {
      payMethod = _handleWechatPay;
    } else {
      payMethod = _handleAliPay;
    }
    await payMethod();
    Navigator.of(context).pop();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => QuestionPage(type: type)));
  }

  _handleWechatPay() async {
    Map result;
    fluwx.payWithWeChat(
      appId: result['appid'].toString(),
      partnerId: result['partnerid'].toString(),
      prepayId: result['prepayid'].toString(),
      packageValue: result['package'].toString(),
      nonceStr: result['noncestr'].toString(),
      timeStamp: result['timestamp'],
      sign: result['sign'].toString(),
    )
        .then((data) {
      print("---》$data");
    });
  }

  _handleAliPay() async {
    Map payResult;
    Map _payResult;
    String _payInfo;
    try {
      print("The pay info is : " + _payInfo);
      payResult = await aliPay(_payInfo);
      print("--->$payResult");
    } on Exception catch (e) {
      payResult = {};
    }

    setState(() {
      _payResult = payResult;
    });
  }

  _showBottomSheet(type) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, _setState) {
            return Container(
              height: 320,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Center(
                        child: Text(
                          '选择支付方式',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      '使用模拟考试需要支付50元，请先支付',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: RadioListTile(
                                  value: 'wePay',
                                  title: Text('微信支付',
                                      style: TextStyle(fontSize: 20.0)),
                                  activeColor: Color(0xffff775d),
                                  secondary: Image.asset(
                                      'assets/images/WePayLogo.png',
                                      width: 36),
                                  controlAffinity:
                                  ListTileControlAffinity.trailing,
                                  groupValue: _payType,
                                  onChanged: (value) {
                                    _setState(() {
                                      _payType = value;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: RadioListTile(
                                  value: 'aliPay',
                                  title: Text('支付宝',
                                      style: TextStyle(fontSize: 20.0)),
                                  activeColor: Color(0xffff775d),
                                  secondary: Image.asset(
                                      'assets/images/AliPayLogo.png',
                                      width: 36),
                                  controlAffinity:
                                  ListTileControlAffinity.trailing,
                                  groupValue: _payType,
                                  onChanged: (value) {
                                    _setState(() {
                                      _payType = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 300.0,
                            margin: EdgeInsets.only(top: 30.0),
                            decoration: BoxDecoration(
                                color: Color(0xffff775d), // 渐变色
                                borderRadius: BorderRadius.circular(48.0)),
                            child: MaterialButton(
                                textColor: Colors.white,
                                onPressed: () => _payAction(type),
                                child: Text(
                                  '立即支付',
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48.0))))
                      ],
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _showModal('A'),
          child: Container(
              width: 150.0,
              height: 60.0,
              margin: EdgeInsets.all(50.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xffff775d),
                  border: Border.all(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: Color.fromRGBO(0, 0, 0, 0.1))),
              child: Text('A1模拟考试',
                  style: TextStyle(fontSize: 20.0, color: Colors.white))),
        ),
        GestureDetector(
          onTap: () => _showModal('C'),
          child: Container(
              width: 150.0,
              height: 60.0,
              margin: EdgeInsets.all(50.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xffff775d),
                  border: Border.all(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: Color.fromRGBO(0, 0, 0, 0.1))),
              child: Text('C1模拟考试',
                  style: TextStyle(fontSize: 20.0, color: Colors.white))),
        )
      ],
    );
  }
}
