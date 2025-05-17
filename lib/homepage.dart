// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saute_mouton/ball.dart';
import 'package:saute_mouton/button.dart';
import 'package:saute_mouton/missile.dart';
import 'package:saute_mouton/player.dart';
import 'auto_repeater.dart';
import 'ball_widget.dart';
import 'score_display.dart';
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
  int score = 0;
  List<Ball> balls = [];
  // time to add an additional ball (initialized to be "far away")
  DateTime? dtAddBall;

  //variables missiles
  double missileX = playerX;
  double missileHeight = 10;
  bool midshoot = false;
  late AutoRepeater leftMoveRepeater;
  late AutoRepeater rightMoveRepeater;

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

    setState(() {
      gameIsRunning = true;
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

    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
      setState(() {
        for (var ball in balls) {
          ball.move(totalHeight);
        }
      });
      //check si la balle touche le joueur
      if (playerDies()) {
        timer.cancel();
        gameIsRunning = false;
        _showDialog();
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

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[800],
            title: const Center(
              child: Text(
                "T'as été touché chef !",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }

  void moveLeft() {
    setState(() {
      playerX = (playerX - 0.05).clamp(-1.0, 1.0);

      // Il coordine les 2 X quand on n'est pas au milieu d'un tir
      if (!midshoot) {
        missileX = playerX;
      }
    });
  }

  void moveRight() {
    setState(() {
      playerX = (playerX + 0.05).clamp(-1.0, 1.0);

      // Il coordine les 2 X quand on n'est pas au milieu d'un tir
      if (!midshoot) {
        missileX = playerX;
      }
    });
  }

  void fireMissile() {
    print("playerX: $playerX, missileX: $missileX");
    if (midshoot == false) {
      Timer.periodic(const Duration(microseconds: 1000), (timer) {
        //missile tiré
        midshoot = true;

        // Misile jusqu'au top de l'ecran
        setState(() {
          // I did not understand the clamp in next line.
          // For me "10.clamp(-1.0, 1.0)" is the same as 1.
          //missileHeight += 10.clamp(-1.0, 1.0);
          missileHeight += 3; // increased missile speed
        });

        //arreter missiles quand ca arrive au top
        if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) {
          resetMissile();
          timer.cancel();
        }

        //checker si le missile touche la balle
        double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
        for (var ball in balls) {
          if (ball.alignY > heighToCoordinate(missileHeight, totalHeight) &&
              (ball.alignX - missileX).abs() < 0.03) {
            resetMissile();
            timer.cancel();
            setState(() {
              score++;
              balls.remove(ball);
            });
          }
        }
        if (balls.isEmpty) {
          var ball = Ball();
          // let the new ball start a bit outside
          ball.alignX = 2;
          balls.add(ball);
        }
      });
    }
  }

  void resetMissile() {
    missileHeight = playerX;
    missileHeight = 0;
    midshoot = false;
  }

  bool playerDies() {
    //si la balle touche le joueur et si la position du joueur et de la balle sont la meme
    for (var ball in balls) {
      if ((ball.alignX - playerX).abs() < 0.1 && ball.alignY > 0.95) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
              child: Container(
                color: Colors.pink[100],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ScoreDisplay(score: score),
                    for (var ball in balls) BallWidget(ball: ball),
                    MyMissile(height: missileHeight, missileX: missileX),
                    Align(
                      alignment: Alignment(playerX, 1),
                      child: MyPlayer(playerX: playerX),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Opacity(
                        opacity: gameIsRunning ? 0.2 : 1,
                        child: MyButton(
                            icon: Icons.play_arrow, function: startGame)),
                    MyButton(
                        icon: Icons.arrow_back, repeater: leftMoveRepeater),
                    MyButton(icon: Icons.arrow_upward, function: fireMissile),
                    MyButton(
                      icon: Icons.arrow_forward,
                      repeater: rightMoveRepeater,
                    ),
                    if (secondsTillAdditionalBall != null)
                      Container(
                          alignment: const Alignment(0.95, 0.95),
                          child: Text(
                              "additional ball in ${secondsTillAdditionalBall.toStringAsFixed(1)} s"))
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
