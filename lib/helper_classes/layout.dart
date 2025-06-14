import 'package:flutter/material.dart';

class Layout {
  Color? playGroundBackgroundColor;
  Color? playgroundTextColor;
  Color? bottomRowBackgroundColor;
  Color? playerBackgroundColor;
  String? pathForPlayerIcon;

  Layout.mitch() {
    playGroundBackgroundColor = Colors.pink[100];
    playgroundTextColor = Colors.grey.shade600;
    bottomRowBackgroundColor = Colors.grey;
    playerBackgroundColor = Colors.deepPurple;
  }
  Layout.irina() {
    playGroundBackgroundColor = Colors.blue[900];
    playgroundTextColor = Colors.white70;
    bottomRowBackgroundColor = Colors.green;
    pathForPlayerIcon = "assets/images/alien.png";
  }
}
