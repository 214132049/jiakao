import 'dart:io';

import 'package:dlysaq/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'homePage.dart';

void main() {
  runApp(MyApp());
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
          home: HomePage(),
          builder: EasyLoading.init(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('zh', 'CN'),
            const Locale('en', 'US'),
          ],
        ));
  }
}
