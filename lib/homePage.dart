import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:tobias/tobias.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'constants.dart';
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
  bool _wxInstalled = true;
  bool _aliInstalled = true;

  @override
  initState() {
    super.initState();
    _initPay();
  }

  _initPay() async {
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
    _aliInstalled = await isAliPayInstalled();
    _wxInstalled = await fluwx.isWeChatInstalled;
    print("wx is installed $_wxInstalled");
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
      payMethod = _handleWxPay;
    } else {
      payMethod = _handleAliPay;
    }
    try {
      await payMethod();
      Navigator.of(context).pop();
      Timer(Duration(seconds: 1), () => {
        Navigator.push(context,
      MaterialPageRoute(builder: (context) => QuestionPage(type: type)))
      });
    } catch (e) {}
  }

  _handleWxPay() async {
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
      if(!_aliInstalled) {
        EasyLoading.showToast('请安装支付宝客户端');
        return;
      }
      Map payResult;
      String _payInfo = await _getOrderInfo(false);
      print("The pay info is : " + _payInfo);
      payResult = await aliPay(_payInfo);
      print("--->$payResult");
      if (payResult['resultStatus'] != 9000) {
        throw Error.safeToString(payResult['memo']);
      }
      _showPayResult(true);
    } catch (e) {
      _showPayResult(false);
      throw Error();
    }
  }

  _getOrderInfo(bool isWx) async {
    try {
      EasyLoading.show(status: 'loading...');
      var url =
          isWx ? '$apiHost/api/getWxOrderInfo' : '$apiHost/api/getAliOrderInfo';
      var response = await http.get(url).timeout(Duration(seconds: 30));
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
      print(e);
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
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      '需要支付50元，请先支付',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
                                      style: TextStyle(fontSize: 16.0)),
                                  activeColor: Color(0xffff775d),
                                  secondary: Image.asset(
                                      'assets/images/WePayLogo.png',
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
                            ],
                          ),
                        ),
                        Container(
                            width: 240.0,
                            margin: EdgeInsets.only(top: 30.0),
                            decoration: BoxDecoration(
                                color: Color(0xffff775d), // 渐变色
                                borderRadius: BorderRadius.circular(48.0)),
                            child: MaterialButton(
                                textColor: Colors.white,
                                onPressed: () => _payAction(type),
                                child: Text(
                                  '立即支付',
                                  style: TextStyle(fontSize: 16.0),
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
              width: 180.0,
              height: 180.0,
              margin: EdgeInsets.all(30.0),
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
              width: 180.0,
              height: 180.0,
              margin: EdgeInsets.all(30.0),
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
