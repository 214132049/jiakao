import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'loginPage.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = SystemUiOverlayStyle(
        statusBarColor: Colors.white,

        ///这是设置状态栏的图标和字体的颜色
        ///Brightness.light  一般都是显示为白色
        ///Brightness.dark 一般都是显示为黑色
        statusBarIconBrightness: Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, //只能纵向
      DeviceOrientation.portraitDown,//只能纵向
    ]);
    return ScreenUtilInit(
        designSize: Size(375, 812),
        allowFontScaling: false,
        child: MaterialApp(
          title: '驾考',
          theme: ThemeData(
            primaryColor: Colors.white,
            cursorColor: Color(0xffff775d),
            textSelectionHandleColor: Color(0xffff775d),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: LoginPage(),
          builder: EasyLoading.init(),
        ));
  }
}
