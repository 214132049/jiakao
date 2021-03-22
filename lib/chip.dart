import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final dynamic meta;
  final String value;
  final bool selected;
  final bool disabled;
  final Function(bool selected) onSelect;

  CustomChip({
    Key key,
    this.label,
    this.width,
    this.height,
    this.meta,
    this.value,
    this.selected,
    this.onSelect,
    this.disabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = 0xffffffff;
    var borderColor = 0xffdddddd;
    var textColor = 0xff333333;

    if (disabled) {
      var answer = meta.answer;
      var userAnswer = meta.userAnswer;
      var questionType = meta.questionType;
      if (questionType == 3) {
        if (userAnswer.indexOf(value) > -1 && answer.indexOf(value) > -1) {
          color = 0xff84d197;
          borderColor = 0xff84d197;
          textColor = 0xffffffff;
        } else if (userAnswer.indexOf(value) == -1 && answer.indexOf(value) > -1) {
          color = 0xffea5957;
          borderColor = 0xffea5957;
          textColor = 0xffffffff;
        }
      } else {
        // 单选题、判断题
        if (answer.indexOf(value) > -1) {
          // 正确答案绿色
          color = 0xff84d197;
          borderColor = 0xff84d197;
          textColor = 0xffffffff;
        } else if (userAnswer.indexOf(value) > -1 && answer.indexOf(value) == -1) {
          //
          color = 0xffea5957;
          borderColor = 0xffea5957;
          textColor = 0xffffffff;
        }
      }
      // 此题没有 正确答案红色
      if (userAnswer == '' && answer.indexOf(value) > -1) {
        color = 0xffea5957;
        borderColor = 0xffea5957;
        textColor = 0xffffffff;
      }
    } else {
      if (selected) {
        color = 0xffff775d;
        borderColor = 0xffff775d;
        textColor = 0xffffffff;
      }
    }

    return InkWell(
        onTap: () => {
              if (!disabled) {onSelect(!selected)}
            },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 10.0),
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                    color: Color(color),
                    borderRadius: BorderRadius.circular(120.0),
                    border: Border.all(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: Color(borderColor))),
                child: Text(value, style: TextStyle(color: Color(textColor))),
              ),
              Expanded(
                child: Text(
                  label,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xff333333),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
