import 'package:flutter/material.dart';

import 'questionPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _enter() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => QuestionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _enter,
          child: Container(
              width: 150.0,
              height: 150.0,
              margin: EdgeInsets.all(50.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  gradient: LinearGradient(
                      colors: [Color(0xffffa192), Color(0xffff775d)]),
                  border: Border.all(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: Color.fromRGBO(0, 0, 0, 0.1))),
              child: Text(
                  // onTap: _enter,
                  '模拟考试',
                  style: TextStyle(fontSize: 24.0, color: Colors.white))),
        )
      ],
    );
  }
}
