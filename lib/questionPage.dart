import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class QuestionPage extends StatefulWidget {
  QuestionPage({Key key}) : super(key: key);

  @override
  QuestionState createState() => QuestionState();
}

class QuestionState extends State<QuestionPage> {
  String _title = '做题';
  int currentNum = 0;
  var questions = [];

  questionPage() {
    loadAsset().then((json) => {
          setState(() {
            questions = jsonDecode(json);
          })
        });
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/json/questions.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
    );
  }
}
