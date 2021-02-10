import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'transferData.dart';

class ResultPage extends StatefulWidget {
  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    final transSingletonData = TransferDataSingleton();
    final questionAll = transSingletonData.transData;
    final questionsMap = questionAll.questions.asMap();
    int score = 0;

    questionsMap.forEach((i, q) => {
          if (q.answer == q.userAnswer) {score++}
        });

    _again() {
      Navigator.of(context).pop();
    }

    _review() {
      Navigator.of(context).pop('review');
    }

    return Scaffold(
        appBar: AppBar(
            title: Text(
              '答题结果',
              style: TextStyle(fontSize: 16.0),
            ),
            centerTitle: true),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 80.0,
                      ),
                      child: new CircularPercentIndicator(
                        radius: 120.0,
                        lineWidth: 12.0,
                        animation: true,
                        percent: score / 100,
                        center: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: '$score',
                              style: TextStyle(
                                  fontSize: 28.0,
                                  color: const Color(0xff333333))),
                          TextSpan(
                              text: '%',
                              style: TextStyle(
                                  fontSize: 16.0, color: Color(0xff333333)))
                        ])),
                        footer: Container(
                          margin: EdgeInsets.only(top: 6.0),
                          child: new Text(
                            "正确率",
                            style: new TextStyle(fontSize: 15.0),
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: score >= 90
                            ? const Color(0xff84d197)
                            : const Color(0xffea5957),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 30.0),
                        height: 48.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                            color: Color(0xffff775d),
                            borderRadius: BorderRadius.circular(48.0)),
                        child: MaterialButton(
                            onPressed: _again,
                            child: Text(
                              '继续练习',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                            shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius: BorderRadius.circular(48.0)))),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 30.0),
                        height: 48.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0,
                                style: BorderStyle.solid,
                                color: const Color(0xffff775d)),
                            borderRadius: BorderRadius.circular(48.0)),
                        child: MaterialButton(
                            onPressed: _review,
                            child: Text(
                              '查看错题',
                              style: TextStyle(
                                  fontSize: 16.0, color: Color(0xffff775d)),
                            ),
                            shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius: BorderRadius.circular(48.0)))),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
