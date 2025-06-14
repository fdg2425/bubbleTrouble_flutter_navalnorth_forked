import 'package:flutter/material.dart';

import 'helper_classes/layout.dart';

class Player {
  double width = 60;
  double height = 80;
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

  Widget getPlayerWidget(Layout layout) {
    return Positioned(
        top: top,
        left: left,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: layout.playerBackgroundColor,
            height: height,
            width: width,
            decoration: layout.pathForPlayerIcon == null
                ? null
                : BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(layout.pathForPlayerIcon!),
                      fit: BoxFit.fill,
                    ),
                  ),
          ),
        ));
  }
}
