import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saute_mouton/ball.dart';
import 'package:saute_mouton/button.dart';
import 'package:saute_mouton/missile.dart';
import 'package:saute_mouton/player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum Direction { left, right}

class _HomePageState extends State<HomePage> {
  //variables joueur
  static double playerX = 0;
  final FocusNode _focusNode = FocusNode();

  //variables missiles
  double missileX = playerX;
  double missileHeight = 10;
  bool midshoot = false;

  //balle variables
  double ballX = 0.5;
  double ballY = 0;
  var ballDirection = Direction.left;

  

  @override
  void initState() {
    super.initState();
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
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (ballX - 0.02 < -1) {
        ballDirection = Direction.right;
      } else if (ballX + 0.02 > 1) {
        ballDirection = Direction.left;
      }

      if (ballDirection == Direction.left) {
        setState(() {
        ballX -= 0.03;
      });
      } else if (ballDirection == Direction.right) {
        setState(() {
          ballX += 0.03;
        });
      }
    });
  }

  void moveLeft() {
    setState(() {
      playerX = (playerX - 0.1).clamp(-1.0, 1.0);

      // Il coordine les 2 X quand on n'est pas au milieu d'un tir
      if (!midshoot) {
        missileX = playerX;
      }
    });
  }

  void moveRight() {
    setState(() {
      playerX = (playerX + 0.1).clamp(-1.0, 1.0);

      // Il coordine les 2 X quand on n'est pas au milieu d'un tir
      if (!midshoot) {
        missileX = playerX;
      }
    });
  }

  void fireMissile() {
    if (midshoot == false) {
      Timer.periodic(const Duration(microseconds: 1000), (timer) {
        //missile tiré
        midshoot = true;

        // Misile jusqu'au top de l'ecran
        setState(() {
          missileHeight += 10.clamp(-1.0, 1.0);
        });

        if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) {
          //arreter missiles
          resetMissile();
          timer.cancel();
          midshoot = false;
        }
    });
    }
  }

  void resetMissile() {
    missileHeight = playerX;
    missileHeight = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              moveLeft();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              moveRight();
            }

            if (event.logicalKey == LogicalKeyboardKey.space) {
              fireMissile();
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
                    MyBall(
                      ballX: ballX, 
                      ballY: ballY
                    ),

                    MyMissile(
                      height: missileHeight, 
                      missileX: missileX
                    ),

                    Align(
                      alignment: Alignment(playerX, 1),
                      child: MyPlayer(
                        playerX: playerX
                      ),
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
                    MyButton(
                      icon: Icons.play_arrow, 
                      function: startGame
                    ),

                    MyButton(
                      icon: Icons.arrow_back, 
                      function: moveLeft
                    ),

                    MyButton(
                      icon: Icons.arrow_upward, 
                      function: fireMissile
                    ),

                    MyButton(
                      icon: Icons.arrow_forward, 
                      function: moveRight
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