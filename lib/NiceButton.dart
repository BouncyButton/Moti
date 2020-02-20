import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class NiceButton extends StatelessWidget {

  final Color textColor;
  final Color fillColor;
  final String text;

  NiceButton({this.textColor, this.text, this.fillColor});

  @override
  Widget build(BuildContext context) {
    var _textColor = textColor;
    if (_textColor == null)
      _textColor = TinyColor(Theme
          .of(context)
          .primaryColor)
          .desaturate(20)

          .color;

    var _fillColor = fillColor;
    if (_fillColor == null)
      _fillColor = Colors.white;
    return Card(
      color: _fillColor,
        elevation: 3.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 24.0, horizontal: 54.0),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
        )
    );
  }
}