import 'package:flutter/material.dart';
import 'dart:async';
import 'player.dart';

class Missile {
  Missile({required this.maxHeight, required this.callbackWhenIncreased});
  double maxHeight;
  void Function(bool isLastCallbackCall) callbackWhenIncreased;
  double height = 0;
  double left = 0;
  DateTime? dtLastIncrease; // DateTime of last increase call
  Timer? _timer;

  void startTimer() {
    _timer =
        Timer.periodic(const Duration(milliseconds: 40), missileTimerCallback);
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void missileTimerCallback(Timer timer) {
    // In Mitch's version, when Android emulator was turned by 90°, the missile reached the top
    // very fast and it was difficlut to hit a ball.
    // New: Ensure that the missile "flies" for about half a second independent of the screenheight.

    double deltaHeight =
        50; // in the first timer event, move missile up for 50 pixels (this is behind the player)
    if (dtLastIncrease != null) {
      deltaHeight = maxHeight *
          DateTime.now().difference(dtLastIncrease!).inMilliseconds /
          500;
    }
    height += deltaHeight;
    if (height >= maxHeight) {
      callbackWhenIncreased(true);
      stopTimer();
    } else {
      callbackWhenIncreased(false);
    }
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
