// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helper_widgets/fdg_logo_animation_widget.dart';
import 'settings/settings_provider.dart';
import 'ball.dart';
import 'helper_widgets/button.dart';
import 'helper_classes/cycle_counter.dart';
import 'missile.dart';
import 'player.dart';
import 'helper_classes/auto_repeater.dart';
import 'helper_widgets/score_display.dart';
import 'helper_widgets/show_settings_button.dart';
import 'helper_widgets/start_game_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // the SettingsProvider
  late SettingsProvider settingsProvider;

  //variables joueur
  var player = Player();
  Missile? missile;
  List<Ball> balls = [];
  int score = 0;

  // some flags (hopefully self-explaining)
  bool firstBuildCall = true;
  bool gameIsRunning = false;

  // autorepeater and keyboard focus node
  late AutoRepeater leftMoveRepeater;
  late AutoRepeater rightMoveRepeater;
  final FocusNode _focusNode = FocusNode();

  // time to add an additional ball (initialized to be "far away")
  DateTime? dtAddBall;
  DateTime? dtLastMissileTimer;

  // for animation
  // BTW: the code for the animation was taken from Gemini after asking 4 questions:
  // a) Flutter rotate image animation
  // b) Is this possible without AnimationBuilder by using _animation.value in a Matrix4
  // c) how to run the animation only once started e.g. by a button press
  // d) how to make animation not linear, but first fast and then slow

  late AnimationController _controller;
  late Animation<double> _animation;

  // for timer and build statistics
  var timerCounter = CycleCounter();
  var buildCounter = CycleCounter();

  @override
  void initState() {
    super.initState();
    leftMoveRepeater = AutoRepeater(moveLeft);
    rightMoveRepeater = AutoRepeater(moveRight);
    settingsProvider = SettingsProvider(callbackOnSettingsChange: refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duration for one full rotation
      vsync: this, // The TickerProvider
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1, // One full circle
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Or Curves.easeOut, Curves.decelerate, etc.
    ));

    // IMPORTANT: Add a listener to rebuild the widget on every animation tick
    _animation.addListener(() {
      setState(() {
        // This will trigger a rebuild of the entire Matrix4RotationScreen
        // whenever the _animation's value changes.
      });
    });

    // Make the animation repeat indefinitely
    //_controller.repeat();
    _controller.forward();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animation
        .removeListener(() {}); // Remove the listener to prevent memory leaks
    _controller.dispose(); // Important: Dispose the controller

    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  // adapt layout according to screen size
  static const double maxBottomRowHeight = 120;
  double bottomRowHeight = maxBottomRowHeight;

  // when we have enough place, make buttons quadratic
  static const double maxWidthOfBottomButtoms =
      maxBottomRowHeight - 2 * MyButton.padding;
  double widthOfBottomButtons = maxWidthOfBottomButtoms;

  Size getPlayingAreaSize(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    bottomRowHeight = (screenHeight > 400) ? maxBottomRowHeight : 80;

    double screenWidth = MediaQuery.of(context).size.width;
    //print("screenWidth: $screenWidth");

    // calculate size of the buttons in the bottom row:
    // we have 3 buttons -> we have 6 paddings in x-direction
    widthOfBottomButtons = (screenWidth - 6 * MyButton.padding) / 3;
    //print("widthOfBottomButtons before limiting: $widthOfBottomButtons");

    if (widthOfBottomButtons > maxWidthOfBottomButtoms) {
      widthOfBottomButtons = maxWidthOfBottomButtoms;
    }

    return Size(screenWidth, screenHeight - bottomRowHeight);
  }

  // the margin we leave in PlayingArea on left, top and right e.g. for the SettingsButton
  final double playingAreaInset = 8;

  double getFirstLineTop() =>
      MediaQuery.of(context).padding.top + playingAreaInset;

  void startGame() {
    if (gameIsRunning) {
      return;
    }

    timerCounter.reset();
    buildCounter.reset();

    var playingAreaSize = getPlayingAreaSize(context);

    setState(() {
      gameIsRunning = true;
      score = 0;
      balls.clear();
      var ball = Ball();
      ball.goToStartPosition(playingAreaSize);
      balls.add(ball);
      // reset player and missile to the center
      player.moveToCenter(playingAreaSize);
    });

    // First we started with 10. But then the text displayed in the game shrinks when going from 10 to 9.
    // That did not look good. So we start with 9.
    dtAddBall = DateTime.now().add(const Duration(seconds: 9));

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
    setState(() {
      player.moveLeft();
    });
  }

  void moveRight() {
    setState(() {
      player.moveRight();
    });
  }

  // fire_missile is only allowed while game is running,
  // because otherwise we have to timer "to move" the missile
  void fireMissile() {
    if (gameIsRunning) {
      missile = Missile();
      missile!.alignToPlayer(player);
    }
  }

  // common callback for panUpdate used both for the playing area
  // and for the "panning area" introduced on bottom right.
  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      player.left += details.delta.dx;
      if (missile != null) {
        missile!.alignToPlayer(player);
      }
    });
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
      // appBar: AppBar(
      //   title: const Text("Bubble trouble", style: TextStyle(fontSize: 28)),
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Colors.white,
      //   centerTitle: true,
      // ),
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
              child: GestureDetector(
                onPanUpdate: onPanUpdate,
                child: Container(
                  color: Colors.pink[100],
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FdgLogoAnimationWidget(
                          finalTop: getFirstLineTop(),
                          finalLeft: playingAreaInset,
                          animation: _animation,
                          playingAreaSize: playingAreaSize),
                      ShowSettingsButton(
                        top: getFirstLineTop(),
                        right: playingAreaInset,
                        settingsProvider: settingsProvider,
                      ),
                      ScoreDisplay(score: score),
                      if (missile != null) missile!.getMissileWidget(),
                      player.getPlayerWidget(),
                      // show the balls on top of the player to better see the collisions
                      for (var ball in balls) ball.getBallWidget(),
                      if (!gameIsRunning)
                        StartGameWidget(
                            callback: startGame, displayText: "Start game"),
                      if (gameIsRunning)
                        showAdditionalBallInfo(secondsTillAdditionalBall),
                      //showBuildAndTimerStatistics(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: bottomRowHeight,
              color: Colors.grey,
              child: Row(
                children: [
                  MyButton(
                      width: widthOfBottomButtons,
                      isActive: gameIsRunning,
                      icon: Icons.arrow_upward,
                      function: fireMissile),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (settingsProvider.showButtonsForPlayerMovement)
                          Row(
                            children: [
                              MyButton(
                                width: widthOfBottomButtons,
                                icon: Icons.arrow_back,
                                repeater: leftMoveRepeater,
                              ),
                              MyButton(
                                width: widthOfBottomButtons,
                                icon: Icons.arrow_forward,
                                repeater: rightMoveRepeater,
                              ),
                            ],
                          ),
                        if (!settingsProvider.showButtonsForPlayerMovement)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onPanUpdate: onPanUpdate,
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade800,
                                        border: Border.all(
                                            color: Colors.white,
                                            width: 2), // Grey border
                                        borderRadius: BorderRadius.circular(
                                            15)), // Rounded corners

                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
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
          ],
        ),
      ),
    );
  }

  Widget showAdditionalBallInfo(double? secondsTillAdditionalBall) {
    return Container(
        margin: EdgeInsets.only(top: getFirstLineTop()),
        alignment: Alignment.topCenter,
        child: Text(
            "additional ball in ${secondsTillAdditionalBall != null ? secondsTillAdditionalBall.toStringAsFixed(1) : 0}s",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)));
  }

  Widget showBuildAndTimerStatistics() {
    return Positioned(
        top: getFirstLineTop() + 20,
        left: playingAreaInset,
        child: Text(
            "timersPerSecond: ${timerCounter.getCountsPerSecond().toStringAsFixed(1)}   "
            "buildsPerSecond: ${buildCounter.getCountsPerSecond().toStringAsFixed(1)} \n"
            "timerCounter: ${timerCounter.counter}   buildCounter: ${buildCounter.counter} \n",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)));
  }
}
