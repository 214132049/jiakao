import 'dart:convert';
import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:chips_choice/chips_choice.dart';

class Question {
  List<String> options;
  String answer;
  String question;
  int questionType;
  String userAnswer;
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
            for (Question question in questions) {
              question.userAnswer = '';
            }
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
    var options = question.questionType == 3
        ? _buildMultiple(question.options, question.userAnswer)
        : _buildSingle(question.options, question.userAnswer);
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
        Container(padding: EdgeInsets.all(16.0), child: options)
      ],
    );
  }

  _buildSingle(options, value) {
    return ChipsChoice.single(
      value: value,
      onChanged: (val) => setState(() => value = val),
      choiceItems: C2Choice.listFrom<String, String>(
        source: options,
        value: (i, v) => v,
        label: (i, v) => v,
      ),
    );
  }

  _buildMultiple(options, value) {
    return ChipsChoice.multiple(
      value: value,
      onChanged: (val) => setState(() => value = val),
      choiceItems: C2Choice.listFrom<String, String>(
        source: options,
        value: (i, v) => v,
        label: (i, v) => v,
      ),
    );
  }
}
