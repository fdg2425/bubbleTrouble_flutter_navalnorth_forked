import 'dart:math';
import 'package:flutter/material.dart';

class Ball {
  // ToDo : encapsulate variables like left and height and make variables like speedX, speedY and time private
  double left = 0;
  double height = 0;
  double diameter = 20;
  double speedX = -3;
  double speedY = 220;
  double time = 0;

  // randomize the velocity and thus the height of the balls, because otherwise
  // the player can be easily moved to a fixed position where he is quite "safe",
  // as all balls follow similar curves.
  Ball() {
    var random = Random();
    speedY = 180 + 60 * random.nextDouble();
    speedX = -5 + 2 * random.nextDouble();
  }

  void goToStartPosition(Size playingAreaSize) {
    left = playingAreaSize.width;
    height = 0;
  }

  double getTop(Size playingAreaSize) {
    return playingAreaSize.height - height;
  }

  void move(Size playingAreaSize) {
    //Equation pour que la alle rebondissent
    height = -70 * time * time + speedY * time;

    //si la balle touche le sol reset le saut
    if (height < 0) {
      time = 0;
    }

    left += speedX;
    if (left < 0) {
      left = 0;
      speedX = -speedX;
    }
    var maxLeft = playingAreaSize.width - diameter;
    if (left > maxLeft) {
      left = maxLeft;
      speedX = -speedX;
    }

    // Le temps s'incremente
    time += 0.1;
  }

  Widget getBallWidget() {
    return Positioned(
      left: left,
      bottom: height,
      child: Container(
        width: diameter,
        height: diameter,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      ),
    );
  }
}
