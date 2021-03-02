import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:tobias/tobias.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'constants.dart';
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
  String _payType = 'aliPay';
  SharedPreferences _prefs;

  @override
  initState() {
    super.initState();
    _checkDevice();
    _init();
  }

  _init() async {
    _prefs = await SharedPreferences.getInstance();
    await fluwx.registerWxApi(
        appId: "wxd930ea5d5a258f4f",
        doOnAndroid: true,
        doOnIOS: false,
        universalLink: "");
    fluwx.weChatResponseEventHandler.listen((res) {
      if (res is fluwx.WeChatPaymentResponse) {
        print("wxPay :${res.isSuccessful}");
        _showPayResult(true);
      } else {
        _showPayResult(false);
      }
    });
  }

  Future _checkDevice() async {
    return deviceInfo.deviceStatus();
  }

  Future<void> _showModal(String type) async {
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
      _jumpPage(type);
      return;
    }
    Future<void> future = _showBottomSheet(type);
    future.then((value) {
      setState(() {
        _payType = 'aliPay';
      });
    });
  }

  Future _payAction(String type) async {
    var payMethod;
    if (_payType == 'wePay') {
      payMethod = _handleWxPay;
    } else {
      payMethod = _handleAliPay;
    }
    try {
      await payMethod();
      _closeBottomSheet();
      Timer(Duration(seconds: 1), () => {_jumpPage(type)});
    } catch (e) {}
  }

  _handleWxPay() async {
    bool _wxInstalled = await fluwx.isWeChatInstalled;
    if (!_wxInstalled) {
      EasyLoading.showToast('请先安装微信客户端');
      return;
    }
    Map result = await _getOrderInfo(true);
    var data = await fluwx.payWithWeChat(
      appId: result['appid'].toString(),
      partnerId: result['partnerid'].toString(),
      prepayId: result['prepayid'].toString(),
      packageValue: result['package'].toString(),
      nonceStr: result['noncestr'].toString(),
      timeStamp: result['timestamp'],
      sign: result['sign'].toString(),
    );
    print("---》$data");
  }

  _handleAliPay() async {
    try {
      bool _aliInstalled = await isAliPayInstalled();
      if (!_aliInstalled) {
        EasyLoading.showToast('请安装支付宝客户端');
        return;
      }
      Map payResult;
      String _payInfo = await _getOrderInfo(false);
      payResult = await aliPay(_payInfo);
      print('--->>>$payResult');
      if (payResult['resultStatus'] != '9000') {
        throw Error.safeToString(payResult['memo']);
      }
      int status = await deviceInfo.deviceStatus();
      print('----$status');
      if (status != 2) {
        throw Error.safeToString('支付失败');
      }
      _showPayResult(true);
    } catch (e) {
      _showPayResult(false);
      throw Error();
    }
  }

  _getOrderInfo(bool isWx) async {
    try {
      EasyLoading.show();
      String androidId = await deviceInfo.getDeviceInfo();
      var url =
          isWx ? '$apiHost/api/getWxOrderInfo' : '$apiHost/api/getAliOrderInfo';
      var response = await http.post(url,
          body: {'deviceId': androidId}).timeout(Duration(seconds: 30));
      print(response);
      if (response.statusCode != 200) {
        throw Error();
      }
      var data = jsonDecode(response.body);
      if (data['code'] != 1) {
        throw Error();
      }
      return data['data'];
    } catch (e) {
      EasyLoading.showError('支付异常，请重试');
    } finally {
      EasyLoading.dismiss();
    }
  }

  _showPayResult(bool success) {
    if (success) {
      EasyLoading.showToast('支付成功');
    } else {
      EasyLoading.showToast('支付失败,请重试');
    }
  }

  _jumpPage(type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => QuestionPage(type: type)));
  }

  _closeBottomSheet() {
    Navigator.of(context).pop();
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
              height: 260,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(
                        child: Text(
                      '选择支付方式',
                      style: TextStyle(
                          fontSize: 16.0,  color: Colors.grey),
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      '开通考试，需要支付100元',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                                  value: 'aliPay',
                                  title: Text('支付宝',
                                      style: TextStyle(fontSize: 16.0)),
                                  activeColor: Color(0xffff775d),
                                  secondary: Image.asset(
                                      'assets/images/AliPayLogo.png',
                                      width: 32),
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
                              // Container(
                              //   margin: EdgeInsets.symmetric(vertical: 5.0),
                              //   child: RadioListTile(
                              //     value: 'wePay',
                              //     title: Text('微信支付',
                              //         style: TextStyle(fontSize: 16.0)),
                              //     activeColor: Color(0xffff775d),
                              //     secondary: Image.asset(
                              //         'assets/images/WePayLogo.png',
                              //         width: 32),
                              //     controlAffinity:
                              //         ListTileControlAffinity.trailing,
                              //     groupValue: _payType,
                              //     onChanged: (value) {
                              //       _setState(() {
                              //         _payType = value;
                              //       });
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Container(
                            width: 240.0,
                            height: 36.0,
                            margin: EdgeInsets.only(top: 30.0),
                            decoration: BoxDecoration(
                                color: Color(0xffff775d), // 渐变色
                                borderRadius: BorderRadius.circular(48.0)),
                            child: MaterialButton(
                                textColor: Colors.white,
                                onPressed: () => _payAction(type),
                                child: Text(
                                  '立即支付',
                                  style: TextStyle(fontSize: 18.0),
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
              width: 240.0,
              height: 100.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color.fromRGBO(255, 119, 93, 0.1)),
              child: Text('A1模拟考试',
                  style: TextStyle(fontSize: 20.0, color: Color(0xffff775d)))),
        ),
        GestureDetector(
          onTap: () => _showModal('C'),
          child: Container(
              width: 240.0,
              height: 100.0,
              margin: EdgeInsets.only(top: 80.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color.fromRGBO(255, 119, 93, 0.1)),
              child: Text('C1模拟考试',
                  style: TextStyle(fontSize: 20.0, color: Color(0xffff775d)))),
        )
      ],
    );
  }
}
