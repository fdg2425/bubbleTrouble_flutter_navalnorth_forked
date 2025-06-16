import 'dart:math';
import 'package:flutter/material.dart';
import 'helper_classes/layout.dart';

class Ball {
  // ToDo : encapsulate variables like left and height and make variables like speedX, speedY and time private
  double left = 0;
  double height = 0;
  double lastHeight = -1;
  double diameter = 30;
  double speedX = -3;
  double speedY = 220;
  double time = 0;
  double middleOfParabola = -1;

  // randomize the velocity and thus the height of the balls, because otherwise
  // the player can be easily moved to a fixed position where he is quite "safe",
  // as all balls follow similar curves.
  Ball() {
    var random = Random();
    speedX = -5 + 2 * random.nextDouble();
    var bigBallSelector = random.nextDouble();
    if (bigBallSelector > 0.7) {
      diameter = 40 + 10 * random.nextDouble();
      speedY = 230 + 30 * random.nextDouble();
    } else {
      diameter = 25 + 10 * random.nextDouble();
      speedY = 200 + 30 * random.nextDouble();
    }
    print("bigballSelector = $bigBallSelector, diameter = $diameter");
  }

  bool get isBigBall => diameter > 40;

  Ball createSplitBall({bool switchDirection = false}) {
    var newBall = Ball();
    newBall.left = left;
    newBall.height = height;
    newBall.diameter = diameter / 2;
    newBall.speedX = speedX * (switchDirection ? -1 : 1);
    newBall.speedY = speedY + 10;
    // ensure that the new balls rise up and does not fall by setting
    // the time to the first half of the parabola:
    if (middleOfParabola > 0 && time > middleOfParabola) {
      newBall.time = middleOfParabola - (time - middleOfParabola);
    } else {
      newBall.time = time;
    }
    return newBall;
  }

  void goToStartPosition(Size playingAreaSize) {
    left = playingAreaSize.width;
    height = 0;
  }

  double getTop(Size playingAreaSize) {
    return playingAreaSize.height - height;
  }

  void move(Size playingAreaSize) {
    lastHeight = height;

    //Equation pour que la alle rebondissent
    height = -70 * time * time + speedY * time;

    // If ball sinks the first time, memorize the middle of the parabola
    if (height < lastHeight && middleOfParabola < 0) {
      middleOfParabola = time;
    }

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

  Widget getBallWidget(Layout layout) {
    var color2 = isBigBall ? Colors.red : layout.colorOfSmallBalls;
    var color1 = layout.showGradientColorInBalls ? Colors.white : color2;
    return Positioned(
      left: left,
      bottom: height,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
                colors: [color1, color2],
                stops: const [0.1, 0.5],
                center: const Alignment(-0.4, -0.5))),
      ),
    );
  }
}
