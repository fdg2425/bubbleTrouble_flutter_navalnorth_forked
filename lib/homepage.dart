// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ball.dart';
import 'button.dart';
import 'cycle_counter.dart';
import 'missile.dart';
import 'player.dart';
import 'player_movement_selection.dart';
import 'auto_repeater.dart';
import 'ball_widget.dart';
import 'score_display.dart';
import 'start_game_widget.dart';
import 'utilities.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //variables joueur
  static double playerX = 0;
  final FocusNode _focusNode = FocusNode();
  bool gameIsRunning = false;
  bool gameHasEnded = false;
  bool movePlayerWithPanning = true;
  int score = 0;
  List<Ball> balls = [];
  // time to add an additional ball (initialized to be "far away")
  DateTime? dtAddBall;
  DateTime? dtLastMissileTimer;

  //variables missiles
  double missileX = playerX;
  double missileHeight = 10;
  bool midshoot = false;

  // autorepeater
  late AutoRepeater leftMoveRepeater;
  late AutoRepeater rightMoveRepeater;

  // timer and build counter
  var timerCounter = CycleCounter();
  var buildCounter = CycleCounter();

  @override
  void initState() {
    super.initState();
    leftMoveRepeater = AutoRepeater(moveLeft);
    rightMoveRepeater = AutoRepeater(moveRight);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void startGame() {
    print("in startGame, gameIsRunning = $gameIsRunning");

    if (gameIsRunning) {
      return;
    }

    timerCounter.reset();
    buildCounter.reset();

    setState(() {
      gameIsRunning = true;
      gameHasEnded = false;
      score = 0;
      balls.clear();
      var ball = Ball();
      ball.goToStartPosition();
      balls.add(ball);
      // reset player and missile to the center
      playerX = 0;
      missileX = 0;
    });

    dtAddBall = DateTime.now().add(const Duration(seconds: 10));

    // By increasing the cycle time to 40ms we try to ensure, that we have a
    // similar ball speed on different machines and also in Debug and Release.
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      timerCounter.increase();

      double totalHeight = getStackHeight(context);
      double totalWidth = MediaQuery.of(context).size.width;
      setState(() {
        for (var ball in balls) {
          ball.move(totalHeight, totalWidth);
        }
      });
      //check si la balle touche le joueur
      if (playerDies(totalHeight, totalWidth)) {
        timer.cancel();
        gameIsRunning = false;
        //_showDialog();
        setState(() {
          gameHasEnded = true;
        });
      }

      if (dtAddBall != null && DateTime.now().isAfter(dtAddBall!)) {
        balls.add(Ball());
        // the better the score, the smaller is the time when an additional ball is added,
        // but give him at least 2 seconds
        int delay = 10 - score ~/ 10;
        if (delay < 2) {
          delay = 2;
        }
        dtAddBall = DateTime.now().add(Duration(seconds: delay));
      }
    });
  }

  // Showing an Alert dialog has a disadvantage: it blocks keyboard events and tap events on other widgets
  // As a consequence: when an AutoRepeater was active when the player get hit, this AutoRepeater did not stop.
  // Therefore we decided to manage the end of the game in another way (with flag gameHasEnded)
  // void _showDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           backgroundColor: Colors.grey[800],
  //           title: const Center(
  //             child: Text(
  //               "T'as été touché chef !",
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ),
  //         );
  //       });
  // }

  void moveLeft() {
    if (gameHasEnded) {
      return;
    }
    setState(() {
      playerX = (playerX - 0.05).clamp(-1.0, 1.0);

      // Il coordine les 2 X quand on n'est pas au milieu d'un tir
      if (!midshoot) {
        missileX = playerX;
      }
    });
  }

  void moveRight() {
    if (gameHasEnded) {
      return;
    }
    setState(() {
      playerX = (playerX + 0.05).clamp(-1.0, 1.0);

      // Il coordine les 2 X quand on n'est pas au milieu d'un tir
      if (!midshoot) {
        missileX = playerX;
      }
    });
  }

  void fireMissile() {
    if (gameHasEnded) {
      return;
    }
    print("playerX: $playerX, missileX: $missileX");
    if (midshoot == false) {
      Timer.periodic(const Duration(milliseconds: 20), (timer) {
        // Ensure that the missile "flies" for half a second independent of the screenheight.
        // When Android emulator was turned by 90°, missile reached the top very fast and it was difficlut to hit a ball.

        double deltaHeight =
            3; // in the first timer event, move missile for 3 pixels
        double stackHeight = getStackHeight(context);
        if (dtLastMissileTimer != null) {
          deltaHeight = stackHeight *
              DateTime.now().difference(dtLastMissileTimer!).inMilliseconds /
              500;
        }
        dtLastMissileTimer = DateTime.now();
        //missile tiré
        midshoot = true;

        // Misile jusqu'au top de l'ecran
        setState(() {
          // I did not understand the clamp in next line.
          // For me "10.clamp(-1.0, 1.0)" is the same as 1.
          //missileHeight += 10.clamp(-1.0, 1.0);
          missileHeight += deltaHeight; // increased missile speed
        });

        //arreter missiles quand ca arrive au top
        if (missileHeight > stackHeight) {
          resetMissile();
          timer.cancel();
        }

        //checker si le missile touche la balle
        // While iterating through a list in Android, you should not remove elements from that list.
        // Otherwise you get an "ConcurrentModificationError" exception (this does not happen on Chrome ?!).
        // So memorize the balls to be removed in an extra list and remove them later:
        List<Ball> ballsToBeRemoved = [];

        for (var ball in balls) {
          if (ball.alignY > heightToCoordinate(missileHeight, stackHeight) &&
              (ball.alignX - missileX).abs() < 0.03) {
            resetMissile();
            timer.cancel();
            setState(() {
              score++;
              ballsToBeRemoved.add(ball);
            });
          }
        }
        for (var ball in ballsToBeRemoved) {
          balls.remove(ball);
        }
        // if no more ball exists, start a new one
        if (balls.isEmpty) {
          var ball = Ball();
          // let the new ball start a bit outside
          ball.alignX = 2;
          balls.add(ball);
        }
      });
    }
  }

// Until now the variable totalHeight was used for the height of the "player area".
// It was calculated like this:
//          double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
// But in this calculation the height of the AppBar (and in Android the height of the StatusBar) was missing.
// Because "totalHeight" does not express very well what is meant, we use as function name getStackHeight,
// as the "player area" is the Stack widget:
  double getStackHeight(BuildContext context) {
    double result = (MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top) *
        3 /
        4;
    return result;
  }

  void resetMissile() {
    missileHeight = playerX;
    missileHeight = 0;
    midshoot = false;
    dtLastMissileTimer = null;
  }

  bool playerDies(double totalHeight, double totalWidth) {
    //si la balle touche le joueur et si la position du joueur et de la balle sont la meme
    // to avoid fake collisions when the width of Chrome is increased, we have to convert
    // player's width and height into "alignment units":
    // playerWidth /(totalWidth - playerWidth) = alignDistanceX / 2  => alignDistanceX = 2 * playerWidth / (totalWidth - playerWidth)
    // experience showed that it should be smaller, so we use 1.5 instead of 2:
    double alignDistanceX = 1.5 * playerWidth / (totalWidth - playerWidth);
    double alignDistanceY = 1.5 * playerHeight / (totalHeight - playerHeight);
    for (var ball in balls) {
      if ((ball.alignX - playerX).abs() < alignDistanceX &&
          ball.alignY > 1 - alignDistanceY) {
        return true;
      }
    }
    return false;
  }

  // common callback for pPanUpdate used both for the playing area
  // and for the "panning area" introduced on bottom right.
  void onPanUpdate(DragUpdateDetails details) {
    if (!gameHasEnded) {
      setState(() {
        playerX += deltaXToCoordinate(
            details.delta.dx, MediaQuery.of(context).size.width);
        playerX = playerX.clamp(-1, 1);
        if (!midshoot) {
          missileX = playerX;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    buildCounter.increase();

    double? secondsTillAdditionalBall;
    if (dtAddBall != null) {
      secondsTillAdditionalBall =
          (dtAddBall!.difference(DateTime.now()).inMilliseconds / 1000);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bubble trouble", style: TextStyle(fontSize: 28)),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          print("key event is $event");
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              leftMoveRepeater.start();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              rightMoveRepeater.start();
            }

            if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              fireMissile();
            }
          }
          if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              leftMoveRepeater.stop();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              rightMoveRepeater.stop();
            }
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onPanUpdate: onPanUpdate,
                child: Container(
                  color: Colors.pink[100],
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScoreDisplay(score: score),
                      MyMissile(height: missileHeight, missileX: missileX),
                      Align(
                        alignment: Alignment(playerX, 1),
                        child: MyPlayer(playerX: playerX),
                      ),
                      // show the balls on top of the player to better see the collisions
                      for (var ball in balls) BallWidget(ball: ball),
                      if (!gameIsRunning)
                        StartGameWidget(
                            callback: startGame,
                            displayText:
                                gameHasEnded ? "Restart game" : "Start game"),
                      Positioned(
                          top: 0,
                          left: 0,
                          child: Text(
                              "timersPerSecond: ${timerCounter.getCountsPerSecond().toStringAsFixed(1)}   "
                              "buildsPerSecond: ${buildCounter.getCountsPerSecond().toStringAsFixed(1)} \n"
                              "timerCounter: ${timerCounter.counter}   buildCounter: ${buildCounter.counter} \n"
                              "additional ball in ${secondsTillAdditionalBall != null ? secondsTillAdditionalBall.toStringAsFixed(1) : 0}s")),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (gameIsRunning)
                      Expanded(
                          flex: 1,
                          child: MyButton(
                              icon: Icons.arrow_upward, function: fireMissile)),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!gameIsRunning)
                            PlayerMovementSelection(
                              usePanning: movePlayerWithPanning,
                              callback: (value) {
                                setState(() {
                                  movePlayerWithPanning = value;
                                });
                              },
                            ),
                          if (gameIsRunning && !movePlayerWithPanning)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyButton(
                                  icon: Icons.arrow_back,
                                  repeater: leftMoveRepeater,
                                ),
                                const SizedBox(width: 20),
                                MyButton(
                                  icon: Icons.arrow_forward,
                                  repeater: rightMoveRepeater,
                                ),
                              ],
                            ),
                          if (gameIsRunning && movePlayerWithPanning)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onPanUpdate: onPanUpdate,
                                  child: Container(
                                      alignment: Alignment.center,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade800,
                                          border: Border.all(
                                              color: Colors.white,
                                              width: 2), // Grey border
                                          borderRadius: BorderRadius.circular(
                                              15)), // Rounded corners

                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          "pan here or in the playing area to move the player",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
