import 'package:flutter/material.dart';

class Player {
  double width = 50;
  double height = 50;
  double alignX = 0;

  void moveLeft() {
    alignX = (alignX - 0.05).clamp(-1.0, 1.0);
  }

  void moveRight() {
    alignX = (alignX + 0.05).clamp(-1.0, 1.0);
  }

  Widget getPlayerWidget() {
    return Container(
      //color: Colors.pink,
      alignment: Alignment(alignX, 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.deepPurple,
          height: height,
          width: width,
        ),
      ),
    );
  }
}
