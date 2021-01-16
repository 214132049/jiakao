import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final dynamic meta;
  final String value;
  final bool selected;
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => onSelect(!selected),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10.0),
              width: 24.0,
              height: 24.0,
                decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xffff775d)
                        : const Color(0xffffffff),
                    borderRadius: BorderRadius.circular(120.0),
                    border: Border.all(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: selected
                            ? const Color(0xffff775d)
                            : const Color(0xffdddddd))),
                child: Text(value,
                    style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xff333333))),
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 3,
                style: TextStyle(
                  color: Color(0xff333333),
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
