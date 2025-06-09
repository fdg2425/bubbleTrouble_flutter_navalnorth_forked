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
import 'score_display.dart';
import 'start_game_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //variables joueur
  var player = Player();
  Missile? missile;
  List<Ball> balls = [];
  int score = 0;

  // some flags (hopefully self-explaining)
  bool firstBuildCall = true;
  bool gameIsRunning = false;
  bool gameHasEnded = false;
  bool movePlayerWithPanning = true;

  // autorepeater and keyboard focus node
  late AutoRepeater leftMoveRepeater;
  late AutoRepeater rightMoveRepeater;
  final FocusNode _focusNode = FocusNode();

  // time to add an additional ball (initialized to be "far away")
  DateTime? dtAddBall;
  DateTime? dtLastMissileTimer;

  // for timer and build statistics
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

  Size getPlayingAreaSize(BuildContext context) {
    double height = (MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top) *
        3 /
        4;

    double width = MediaQuery.of(context).size.width;
    return Size(width, height);
  }

  void startGame() {
    if (gameIsRunning) {
      return;
    }

    timerCounter.reset();
    buildCounter.reset();

    var playingAreaSize = getPlayingAreaSize(context);

    setState(() {
      gameIsRunning = true;
      gameHasEnded = false;
      score = 0;
      balls.clear();
      var ball = Ball();
      ball.goToStartPosition(playingAreaSize);
      balls.add(ball);
      // reset player and missile to the center
      player.moveToCenter(playingAreaSize);
    });

    dtAddBall = DateTime.now().add(const Duration(seconds: 10));

    // By increasing the cycle time to 40ms we try to ensure, that we have a
    // similar ball speed on different machines and also in Debug and Release.
    Timer.periodic(const Duration(milliseconds: 40), gameTimerCallback);
  }

  void gameTimerCallback(Timer timer) {
    timerCounter.increase();

    var playingAreaSize = getPlayingAreaSize(context);

    for (var ball in balls) {
      ball.move(playingAreaSize);
    }

    if (missile != null) {
      missile!.increase(playingAreaSize.height);

      //checker si le missile touche la balle
      // While iterating through a list in Android, you should not remove elements from that list.
      // Otherwise you get an "ConcurrentModificationError" exception (this does not happen on Chrome ?!).
      // So memorize the balls to be removed in an extra list and remove them later:
      List<Ball> ballsToBeRemoved = [];

      for (var ball in balls) {
        if ((ball.height < missile!.height) &&
            (ball.left + ball.diameter / 2 - missile!.left).abs() <
                ball.diameter / 2) {
          score++;
          ballsToBeRemoved.add(ball);
        }
      }

      // if at least one ball was hit, "delete" the missile
      if (ballsToBeRemoved.isNotEmpty) {
        missile = null;
      }
      for (var ball in ballsToBeRemoved) {
        balls.remove(ball);
      }
      // if no more ball exists, start a new one
      if (balls.isEmpty) {
        var ball = Ball();
        // let the new ball start a bit outside
        ball.goToStartPosition(playingAreaSize);
        // ZZZ evtl. etwas weiter nach rechts ?!
        balls.add(ball);
      }

      if (missile != null && missile!.height > playingAreaSize.height) {
        missile = null;
      }
    }

    //check si la balle touche le joueur
    if (playerDies(playingAreaSize)) {
      timer.cancel();
      gameIsRunning = false;
      gameHasEnded = true;
    }

    if (dtAddBall != null && DateTime.now().isAfter(dtAddBall!)) {
      var ball = Ball();
      ball.goToStartPosition(playingAreaSize);
      balls.add(ball);
      // the better the score, the smaller is the time when an additional ball is added,
      // but give him at least 2 seconds
      int delay = 10 - score ~/ 10;
      if (delay < 2) {
        delay = 2;
      }
      dtAddBall = DateTime.now().add(Duration(seconds: delay));
    }

    setState(() {});
  }

  bool playerDies(Size playingAreaSize) {
    // uncomment next line e.g. for testing ball/missile collisions without being interrupted by EndGame
    //return false;
    for (var ball in balls) {
      if (ball.left + ball.diameter > player.left &&
          ball.left < player.left + player.width &&
          ball.height < player.height) {
        return true;
      }
    }
    return false;
  }

  void moveLeft() {
    if (gameHasEnded) {
      return;
    }
    setState(() {
      player.moveLeft();
    });
  }

  void moveRight() {
    if (gameHasEnded) {
      return;
    }
    setState(() {
      player.moveRight();
    });
  }

  void fireMissile() {
    if (gameHasEnded) {
      return;
    }
    missile = Missile();
    missile!.alignToPlayer(player);
  }

  // common callback for panUpdate used both for the playing area
  // and for the "panning area" introduced on bottom right.
  void onPanUpdate(DragUpdateDetails details) {
    if (!gameHasEnded) {
      setState(() {
        player.left += details.delta.dx;
        if (missile != null) {
          missile!.alignToPlayer(player);
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

    var playingAreaSize = getPlayingAreaSize(context);
    if (firstBuildCall) {
      firstBuildCall = false;
      player.moveToCenter(playingAreaSize);
    }

    player.forceToPlayingArea(playingAreaSize);

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
                      if (missile != null) missile!.getMissileWidget(),
                      player.getPlayerWidget(),
                      // show the balls on top of the player to better see the collisions
                      for (var ball in balls) ball.getBallWidget(),
                      if (!gameIsRunning)
                        StartGameWidget(
                            callback: startGame,
                            displayText:
                                gameHasEnded ? "Restart game" : "Start game"),
                      showAdditionalBallInfo(secondsTillAdditionalBall),
                      //showBuildAndTimerStatistics(),
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

  Widget showAdditionalBallInfo(double? secondsTillAdditionalBall) {
    return Positioned(
        top: 0,
        left: 0,
        child: Text(
            "additional ball in ${secondsTillAdditionalBall != null ? secondsTillAdditionalBall.toStringAsFixed(1) : 0}s"));
  }

  Widget showBuildAndTimerStatistics() {
    return Positioned(
        top: 20,
        left: 0,
        child: Text(
            "timersPerSecond: ${timerCounter.getCountsPerSecond().toStringAsFixed(1)}   "
            "buildsPerSecond: ${buildCounter.getCountsPerSecond().toStringAsFixed(1)} \n"
            "timerCounter: ${timerCounter.counter}   buildCounter: ${buildCounter.counter} \n"));
  }
}
