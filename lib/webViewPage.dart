import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';

class WebViewPage extends StatefulWidget {
  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {

  String _title = '';
  WebViewController _controller;

  Future<void> getWebTitle() async {
    String script = 'window.document.title';
    var title = await _controller.evaluateJavascript(script);
    print(title);
    setState(() {
      _title = title.replaceAll('"', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title', style: TextStyle(fontSize: 16.0)),
        centerTitle: true,
      ),
      body: WebView(
        initialUrl: '$apiHost/public/privacyPolicy.html',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        onPageFinished: (url) {
          getWebTitle();
        },
      )
    );
  }
}