import 'utilities.dart';

enum Direction { left, right }

class Ball {
  double time = 0;
  double height = 0;
  double velocity = 60;
  double alignX = 1;
  double alignY = 1;
  var ballDirection = Direction.left;

  void goToStartPosition() {
    alignX = 1;
    alignY = 1;
  }

  void move(double totalHeight) {
    //Equation pour que la alle rebondissent
    height = -5 * time * time + velocity * time;

    //si la balle touche le sol reset le saut
    if (height < 0) {
      time = 0;
    }

    // met a jour la position de la balle
    alignY = heighToCoordinate(height, totalHeight);

    //si la balle touche les cotés ca change de direction a droite
    if (alignX - 0.02 < -1) {
      ballDirection = Direction.right;

      //si la balle touche les cotés ca change de direction a gauche
    } else if (alignX + 0.02 > 1) {
      ballDirection = Direction.left;
    }

    // Bouge la bale dans lea direction approprié
    if (ballDirection == Direction.left) {
      alignX -= 0.005;
    } else if (ballDirection == Direction.right) {
      alignX += 0.005;
    }
    // Le temps s'incremente
    time += 0.1;
  }
}
