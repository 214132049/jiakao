import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        appBar: AppBar(title: Text('答题结果'), centerTitle: true),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 15.0, bottom: 10.0),
                        child: Text('总成绩',
                            style: TextStyle(
                                fontSize: 16.0, color: Color(0xff333333))),
                      ),
                      Container(
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: '$score',
                              style: TextStyle(
                                  fontSize: 28.0,
                                  color: score >= 90
                                      ? const Color(0xff84d197)
                                      : const Color(0xffea5957))),
                          TextSpan(
                              text: '分',
                              style: TextStyle(
                                  fontSize: 16.0, color: Color(0xff333333)))
                        ])),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 12.0),
                    child: Center(
                      child: Wrap(
                        children: _buildAnswers(questionAll, questionsMap),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Stack(children: <Widget>[
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(color: Color(0x50000000), blurRadius: 5.0)
                  ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 30.0),
                          height: 36.0,
                          width: 130.0,
                          decoration: BoxDecoration(
                              // 渐变色
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
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 30.0),
                          height: 36.0,
                          width: 130.0,
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
                                  borderRadius: BorderRadius.circular(48.0))))
                    ],
                  ),
                ),
              ),
            ])
          ],
        ));
  }

  List<Widget> _buildAnswers(questionAll, map) {
    List<Widget> child = [];
    map.forEach((i, q) => {
          child.add(Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
                color: q.answer != q.userAnswer
                    ? const Color(0xffea5957)
                    : const Color(0xff84d197),
                borderRadius: BorderRadius.circular(120.0),
                border: Border.all(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: q.answer != q.userAnswer
                        ? const Color(0xffea5957)
                        : const Color(0xff84d197))),
            child: Text((i + 1).toString(),
                style: TextStyle(fontSize: 16.0, color: Colors.white)),
          ))
        });
    return child;
  }
}
