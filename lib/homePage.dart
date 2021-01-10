import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_info/device_info.dart';

import './questionPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _auth = false;
  String _code = '';

  homePageState() {
    if (_auth == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => QuestionPage()));
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  void _enter() {
    print(_code);
  }

  void _setCode(v) {
    setState(() {
      _code = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('登录'),
        ),
        body: Padding(
          padding: EdgeInsets.all(28.0),
          child: Wrap(children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 2.0, bottom: 2.0),
                margin: EdgeInsets.only(top: 100.0, bottom: 30.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: Color.fromRGBO(0, 0, 0, 0.1))),
                child: TextField(
                  onChanged: _setCode,
                  decoration: InputDecoration(
                    hintText: '请输入激活码',
                    border: InputBorder.none,
                  ),
                )),
            Container(
                width: double.infinity,
                child: MaterialButton(
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    height: ScreenUtil().setHeight(48.0),
                    onPressed: _enter,
                    child: Text('提交'),
                    shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50))))
                ),
          ]),
        ));
  }
}
