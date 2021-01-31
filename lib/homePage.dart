import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat_kit/wechat_kit.dart';
import 'package:alipay_kit/alipay_kit.dart';

import 'deviceUtil.dart';
import 'questionPage.dart';

// 微信
const String WECHAT_APPID = 'your wechat appId';
const String WECHAT_UNIVERSAL_LINK = 'your wechat universal link'; // iOS 请配置
const String WECHAT_APPSECRET = 'your wechat appSecret';
const String WECHAT_MINIAPPID = 'your wechat miniAppId';

// 支付宝
const String _ALIPAY_APPID = '2016102200741044'; // 支付/登录
const String _ALIPAY_PRIVATEKEY =
    'your alipay rsa private key(pkcs1/pkcs8)'; // 支付/登录

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final deviceInfo = DeviceInfo();
  String _payType = 'wePay';
  Wechat _wechatInstance = Wechat()
    ..registerApp(
      appId: WECHAT_APPID,
      universalLink: WECHAT_UNIVERSAL_LINK,
    );
  Alipay _alipayInstance = Alipay();

  StreamSubscription<WechatPayResp> _wechatPayListen;
  StreamSubscription<AlipayResp> _aliPayListen;

  @override
  void initState() {
    super.initState();
    _wechatPayListen = _wechatInstance.payResp().listen(_listenWeChatPay);
    _aliPayListen = _alipayInstance.payResp().listen(_listenAliPay);
  }

  @override
  void dispose() {
    _wechatPayListen?.cancel();
    _wechatPayListen = null;
    _aliPayListen?.cancel();
    _aliPayListen = null;
    super.dispose();
  }

  void _listenWeChatPay(WechatPayResp resp) {
    String content = 'pay: ${resp.errorCode} ${resp.errorMsg}';
    print('微信支付--$content');
  }

  void _listenAliPay(AlipayResp resp) {
    String content = 'pay: ${resp.resultStatus} - ${resp.result}';
    print('支付宝支付--$content');
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
    // await _wechat.isSupportApi()
    var content = await _wechatInstance.isInstalled();
    print('微信安装--$content');
    _wechatInstance.pay(
      appId: WECHAT_APPID,
      partnerId: '商户号',
      prepayId: '预支付交易会话ID',
      package: '扩展字段,暂填写固定值：Sign=WXPay',
      nonceStr: '随机字符串, 随机字符串，不长于32位',
      timeStamp: '时间戳：东八区，单位秒',
      sign: '签名',
    );
  }

  _handleAliPay() async {
    var content = await _alipayInstance.isInstalled();
    print('支付宝安装--$content');
    String androidId = await deviceInfo.getDeviceInfo();
    final formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime now = new DateTime.now();
    int timestamp = now.millisecondsSinceEpoch;
    Map<String, dynamic> bizContent = <String, dynamic>{
      'timeout_express': '30m',
      'product_code': 'QUICK_MSECURITY_PAY',
      'total_amount': '50',
      'subject': '试题',
      'out_trade_no': '$androidId$timestamp',
    };
    Map<String, dynamic> orderInfo = <String, dynamic>{
      'app_id': _ALIPAY_APPID,
      'biz_content': jsonEncode(bizContent),
      'charset': 'utf-8',
      'method': 'alipay.trade.app.pay',
      'timestamp': formatter.format(now),
      'version': '1.0',
    };
    _alipayInstance.payOrderJson(
      orderInfo: jsonEncode(orderInfo),
      signType: Alipay.SIGNTYPE_RSA2,
      privateKey: _ALIPAY_PRIVATEKEY,
    );
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
