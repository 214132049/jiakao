import 'dart:convert';
import 'dart:async' show Future, Timer;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'constants.dart';
import 'deviceUtil.dart';
import 'result.dart';
import 'chip.dart';
import 'transferData.dart';
import 'payView.dart';

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
  final String type;

  QuestionPage({Key key, @required this.type}) : super(key: key);

  @override
  QuestionState createState() => QuestionState(type);
}

class QuestionState extends State<QuestionPage> {
  String _title = '模拟考试';
  int _pageIndex = 0;
  int _tryPageIndex = 10;
  PageController _pageController;
  List<String> answersEnum = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  Map<int, String> questionTypes = {1: '单选题', 2: '判断题', 3: '多选题'};
  Questions questions = Questions.fromJson([]);
  final deviceInfo = DeviceInfo();
  bool isReview = false;
  String _questionType;

  QuestionState(String type) {
    _questionType = type;
    isReview = false;
    this.getQuestions();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  _paySuccessCallback() {}

  _changePage(index) {
    print(index);
    _pageController.jumpToPage(index);
  }

  getQuestions() {
    loadQuestionJson().then((list) => {
          setState(() {
            questions = list;
          })
        });
  }

  Future<Questions> loadQuestionJson() async {
    try {
      EasyLoading.show(status: '试题加载中');
      String androidId = await deviceInfo.getDeviceInfo();
      var url = '$apiHost/api/getQuestions';
      var response = await http.post(url, body: {
        'type': _questionType,
        'deviceId': androidId
      }).timeout(Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw Error.safeToString('请求异常');
      }
      var data = jsonDecode(response.body);
      if (data['code'] != 1) {
        throw Error.safeToString(data['message']);
      }
      List<dynamic> listJson = data['data'];
      return _getRandomQuestions(listJson);
    } catch (exception) {
      if (exception is String) {
        EasyLoading.showError(exception.replaceAll('"', ''));
      } else {
        EasyLoading.showError('获取失败');
      }
      return Questions.fromJson([]);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Questions _getRandomQuestions(List listJson) {
    var rng = new Random();
    var realList = [];
    for (var i = 0; i < 100; i++) {
      var rngIndex = rng.nextInt(listJson.length);
      realList.add(listJson[rngIndex]);
    }
    realList.sort(
        (left, right) => left['questionType'].compareTo(right['questionType']));
    Questions questionList = Questions.fromJson(realList);
    for (Question question in questionList.questions) {
      question.userAnswer = '';
    }
    return questionList;
  }

  _submit() {
    final transSingletonData = TransferDataSingleton();
    transSingletonData.transData = questions;
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResultPage()))
        .then((value) => {
              setState(() {
                questions = null;
              }),
              Timer(Duration(milliseconds: 100), () {
                if (value == 'review') {
                  setState(() {
                    isReview = true;
                    questions = transSingletonData.transData;
                  });
                } else {
                  this.getQuestions();
                }
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    if (questions == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_title, style: TextStyle(fontSize: 16.0)),
        centerTitle: true,
        actions: <Widget>[
          MaterialButton(
              onPressed: _submit,
              child: Text(
                '提交',
                style: TextStyle(fontSize: 14.0, color: Color(0xffff775d)),
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
              ))
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PayView(key: payViewKey, payCallback: _paySuccessCallback),
          PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: questions.getLength(),
            controller: _pageController,
            onPageChanged: (index) {
              if (index >= _tryPageIndex) {
                _changePage(_tryPageIndex);
                payViewKey.currentState.showPayPanel();
                setState(() {
                  _pageIndex = 3;
                });
                return;
              }
              setState(() {
                _pageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPageViewItem(index);
            },
          ),
          questions.getLength() != 0 ? new Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                color: Color(0x80cccccc),
              ))),
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(0 == _pageIndex, Color(0xff333333),
                      IconData(0xe606, fontFamily: 'MyIcons'), '上一题', () {
                    setState(() {
                      _pageIndex--;
                    });
                    _changePage(_pageIndex);
                  }),
                  _buildButton(
                      _pageIndex == questions.getLength() - 1,
                      Color(0xff333333),
                      IconData(0xe60d, fontFamily: 'MyIcons'),
                      '下一题', () {
                    setState(() {
                      _pageIndex++;
                    });
                    _changePage(_pageIndex);
                  })
                ],
              ),
            ),
          ): Container()
        ],
      ),
    );
  }

  _buildButton(bool disabled, Color color, IconData icon, String label,
      Function callback) {
    return GestureDetector(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: disabled ? Color(0xffdddddd) : color),
            Container(
              margin: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: disabled ? Color(0xffdddddd) : color,
                ),
              ),
            ),
          ],
        ),
        onTap: disabled ? () {} : callback);
  }

  _buildPageViewItem(index) {
    var question = questions.getItem(index);
    var options = question.questionType == 3
        ? _buildMultiple(question)
        : _buildSingle(question);
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 100.0),
      child: Wrap(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: RichText(
                text: TextSpan(
              children: [
                WidgetSpan(
                    child: Container(
                  child: Text(
                    questionTypes[question.questionType],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xff00af63),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0))),
                  margin: EdgeInsets.only(right: 6.0),
                  padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
                )),
                TextSpan(
                    text: (index + 1).toString() + '、' + question.question,
                    style: TextStyle(color: Color(0xff333333), fontSize: 16.0)),
              ],
            )),
          ),
          Container(padding: EdgeInsets.only(left: 16.0), child: options),
        ],
      ),
    );
  }

  _buildSingle(question) {
    return Column(
      children: [
        ChipsChoice.single(
          direction: Axis.vertical,
          value: question.userAnswer,
          onChanged: (val) => setState(() => question.userAnswer = val),
          choiceItems: C2Choice.listFrom<String, dynamic>(
            source: question.options,
            value: (i, v) => answersEnum[i],
            label: (i, v) => v,
            meta: (i, v) => question,
            disabled: (i, v) => isReview,
          ),
          choiceBuilder: (item) {
            return CustomChip(
                label: item.label,
                selected: item.selected,
                onSelect: item.select,
                meta: item.meta,
                disabled: item.disabled,
                value: item.value);
          },
        ),
        _buildReview(question)
      ],
    );
  }

  _buildMultiple(question) {
    return Column(
      children: [
        ChipsChoice.multiple(
          direction: Axis.vertical,
          value: question.userAnswer.split(''),
          onChanged: (val) => setState(() => {
                val.sort((left, right) => left.compareTo(right)),
                question.userAnswer = val.join('')
              }),
          choiceItems: C2Choice.listFrom<String, dynamic>(
            source: question.options,
            value: (i, v) => answersEnum[i],
            label: (i, v) => v,
            meta: (i, v) => question,
            disabled: (i, v) => isReview,
          ),
          choiceBuilder: (item) {
            return CustomChip(
                label: item.label,
                selected: item.selected,
                onSelect: item.select,
                meta: item.meta,
                disabled: item.disabled,
                value: item.value);
          },
        ),
        _buildReview(question)
      ],
    );
  }

  _buildReview(question) {
    return !isReview
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 30.0),
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 30.0),
                  child: RichText(
                      text: TextSpan(
                          text: '正确答案：',
                          style: TextStyle(color: Color(0xff333333)),
                          children: [
                        TextSpan(
                            text: question.answer,
                            style: TextStyle(
                                fontSize: 18.0, color: Color(0xff84d197)))
                      ])),
                ),
                Container(
                  child: RichText(
                      text: TextSpan(
                          text: '我的答案：',
                          style: TextStyle(color: Color(0xff333333)),
                          children: [
                        TextSpan(
                            text: question.userAnswer,
                            style: TextStyle(
                                fontSize: 18.0, color: Color(0xffea5957)))
                      ])),
                )
              ],
            ));
  }
}
