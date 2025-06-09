import 'package:flutter/material.dart';

import 'player.dart';

class Missile {
  double height = 0;
  double left = 0;
  DateTime? dtLastIncrease; // DateTime of last increase call

  void increase(double stackHeight) {
    // In Mitch's version, when Android emulator was turned by 90°, the missile reached the top
    // very fast and it was difficlut to hit a ball.
    // New: Ensure that the missile "flies" for about half a second independent of the screenheight.

    double deltaHeight =
        3; // in the first timer event, move missile for 3 pixels
    if (dtLastIncrease != null) {
      deltaHeight = stackHeight *
          DateTime.now().difference(dtLastIncrease!).inMilliseconds /
          500;
    }
    height += deltaHeight;
    dtLastIncrease = DateTime.now();
  }

  void alignToPlayer(Player player) {
    left = player.left + player.width / 2 - 1;
  }

  Widget getMissileWidget() {
    return Positioned(
      left: left,
      bottom: 0,
      child: Container(
        width: 2,
        height: height,
        color: Colors.grey,
      ),
    );
  }
}
