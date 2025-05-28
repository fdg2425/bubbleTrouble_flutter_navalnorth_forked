import 'dart:math';
import 'utilities.dart';

enum Direction { left, right }

class Ball {
  double time = 0;
  double height = 0;
  double velocity = 220;
  double alignX = 1;
  double alignY = 1;
  var ballDirection = Direction.left;

  // randomize the velocity and thus the height of the balls, because otherwise
  // the player can be easily moved to a fixed position where he is quite "safe",
  // as all balls follow similar curves.
  Ball() {
    var random = Random();
    velocity = 180 + 60 * random.nextDouble();
  }

  void goToStartPosition() {
    alignX = 1;
    alignY = 1;
  }

  void move(double totalHeight, double totalWidth) {
    //Equation pour que la alle rebondissent
    height = -70 * time * time + velocity * time;

    //si la balle touche le sol reset le saut
    if (height < 0) {
      time = 0;
    }

    // met a jour la position de la balle
    alignY = heightToCoordinate(height, totalHeight);

    //si la balle touche les cotés ca change de direction a droite
    if (alignX - 0.02 < -1) {
      ballDirection = Direction.right;

      //si la balle touche les cotés ca change de direction a gauche
    } else if (alignX + 0.02 > 1) {
      ballDirection = Direction.left;
    }

    // Bouge la bale dans lea direction approprié

    // Independent of the screenwidth in Chrome browser, we want to have the same ball speed in x direction.
    // This was no the case when adding a fixed value to alignX, because this value moves the ball faster
    // when the browser window is wider.
    // Solution: move the ball by a fixed amount of pixels, represented in the formula below by "speedX":
    // We have:
    // speedX / totalWidth = deltaAlign / 2   => deltaAlignX = 2 * speedX / totalWidth
    // let's try speedX = 2:
    var deltaAlignX = 14 / totalWidth;
    //print(deltaAlignX);
    if (ballDirection == Direction.left) {
      alignX -= deltaAlignX;
    } else if (ballDirection == Direction.right) {
      alignX += deltaAlignX;
    }
    // Le temps s'incremente
    time += 0.1;
  }
}
