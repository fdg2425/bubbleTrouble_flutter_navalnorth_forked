import 'package:flutter/material.dart';

class Player {
  double width = 50;
  double height = 50;
  double left = 0;
  double top = 0;

  // how far the player moves in moveLeft / moveRight
  static const _xStepWidth = 10; //

  void moveLeft() {
    left -= _xStepWidth;
  }

  void moveRight() {
    left += _xStepWidth;
  }

  void moveToCenter(Size playingAreaSize) {
    top = playingAreaSize.height - height;
    left = (playingAreaSize.width - width) / 2;
    forceToPlayingArea(playingAreaSize);
  }

  void forceToPlayingArea(Size playingAreaSize) {
    if (left + width > playingAreaSize.width) {
      left = playingAreaSize.width - width;
    }
    if (left < 0) {
      left = 0;
    }
    top = playingAreaSize.height - height;
    if (top < 0) {
      top = 0;
    }
  }

  Widget getPlayerWidget() {
    return Positioned(
      top: top,
      left: left,
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
