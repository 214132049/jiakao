import 'dart:convert';
import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:chips_choice/chips_choice.dart';

class Questions {
  List<Question> questions;

  Questions({this.questions});

  factory Questions.fromJson(List<dynamic> listJson) {
    List<Question> questions =
        listJson.map((value) => Question.fromJson(value)).toList();

    return Questions(questions: questions);
  }

  int getLength() {
    return this.questions.length;
  }

  Question getItem(int index) {
    return this.questions[index];
  }
}

class Question {
  List<dynamic> options;
  String answer;
  String question;
  int questionType;
  String userAnswer;

  Question(
      {this.options,
      this.answer,
      this.question,
      this.questionType,
      this.userAnswer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      options: json['options'],
      answer: json['answer'],
      question: json['question'],
      questionType: json['questionType'],
      userAnswer: json['userAnswer'],
    );
  }
}

class QuestionPage extends StatefulWidget {
  QuestionPage({Key key}) : super(key: key);

  @override
  QuestionState createState() => QuestionState();
}

class QuestionState extends State<QuestionPage> {
  String _title = '模拟考试';
  int currentNum = 0;
  List<String> answersEnum = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  Map<int, String> questionTypes = {1: '单选题', 2: '多选题', 3: '判断题'};
  Questions questions = Questions.fromJson([]);

  QuestionState() {
    this.getQuestions();
  }

  getQuestions() {
    loadQuestionJson().then((list) => {
          setState(() {
            questions = list;
          })
        });
  }

  Future<Questions> loadQuestionJson() async {
    String json = await rootBundle.loadString('assets/json/questions.json');
    List<dynamic> listJson = jsonDecode(json);
    listJson = listJson.sublist(0, 100);
    Questions questionList = Questions.fromJson(listJson);
    for (Question question in questionList.questions) {
      question.userAnswer = '';
    }
    return questionList;
  }

  _onPageChanged(index) {
    print(index);
    setState(() {
      currentNum = index % (questions.getLength());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.questions == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.horizontal,
            onPageChanged: _onPageChanged,
            itemCount: questions.getLength(),
            itemBuilder: (context, index) {
              return _buildPageViewItem(index);
            },
          )
        ],
      ),
    );
  }

  _buildPageViewItem(index) {
    var question = questions.getItem(index);
    var options = question.questionType == 3
        ? _buildMultiple(question)
        : _buildSingle(question);
    return Wrap(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: RichText(
              text: TextSpan(
            children: [
              TextSpan(
                text: questionTypes[question.questionType],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    backgroundColor: Colors.red),
              ),
              TextSpan(
                  text: (index + 1).toString() + '、' + question.question,
                  style: TextStyle(color: Color(0xff333333), fontSize: 16.0)),
            ],
          )),
        ),
        Container(padding: EdgeInsets.all(16.0), child: options)
      ],
    );
  }

  _buildSingle(question) {
    return ChipsChoice.single(
      direction: Axis.vertical,
      value: question.userAnswer,
      onChanged: (val) => setState(() => question.userAnswer = val),
      choiceItems: C2Choice.listFrom<String, dynamic>(
        source: question.options,
        value: (i, v) => answersEnum[i],
        label: (i, v) => answersEnum[i] + v,
      ),
    );
  }

  _buildMultiple(question) {
    return ChipsChoice.multiple(
      value: question.userAnswer,
      onChanged: (val) => setState(() => question.userAnswer = val),
      choiceItems: C2Choice.listFrom<String, dynamic>(
        source: question.options,
        value: (i, v) => answersEnum[i],
        label: (i, v) => answersEnum[i] + v,
      ),
    );
  }
}
