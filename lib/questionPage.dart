import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class Question {
  List<String> options;
  String answer;
  String question;
  int questionType;
}

class QuestionPage extends StatefulWidget {
  QuestionPage({Key key}) : super(key: key);

  @override
  QuestionState createState() => QuestionState();
}

class QuestionState extends State<QuestionPage> {
  String _title = '模拟考试';
  int currentNum = 0;
  List<Question> questions = [];
  List<String> answersEum = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  Map<int, String> questionTypes = {1: '单选题', 2: '多选题', 3: '判断题'};

  QuestionState() {
    this.getQuestions();
  }

  getQuestions() {
    loadAsset().then((json) => {
          setState(() {
            List<Question> questions = jsonDecode(json);
            questions = questions.sublist(0, 100);
          })
        });
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/json/questions.json');
  }

  _onPageChanged(index) {
    print(index);
    setState(() {
      currentNum = index % (questions.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.horizontal,
            onPageChanged: _onPageChanged,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return _buildPageViewItem(index);
            },
          )
        ],
      ),
    );
  }

  _buildPageViewItem(index) {
    Question question = questions[index];
    return Wrap(
      children: [
        Wrap(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                questionTypes[question.questionType],
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
            Text((index + 1).toString() + '、' + question.question,
                style: TextStyle(color: Color(0xff333333), fontSize: 16.0)),
          ],
        ),
        Wrap(
          children: question.options
              .asMap()
              .keys
              .map<Widget>((index) => Container(
                    padding: EdgeInsets.all(16.0),
                    child: Wrap(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(answersEum[index]),
                        ),
                        Text(
                          question.options[index],
                          style: TextStyle(
                              color: Color(0xff333333), fontSize: 16.0),
                        )
                      ],
                    ),
                  ))
              .toList(),
        )
      ],
    );
  }
}
