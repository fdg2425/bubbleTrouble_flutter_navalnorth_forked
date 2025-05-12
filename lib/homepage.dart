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

enum Direction { left, right }

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
    double time = 0;
    double height = 0;
    double velocity = 60;

    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      //Equation pour que la alle rebondissent
      height = -5 * time * time + velocity * time;

      //si la balle touche le sol reset le saut
      if (height < 0) {
        time = 0;
      }

      // met a jour la position de la balle
      setState(() {
        ballY = heighToCoordinate(height);
      });

      //si la balle touche les cotés ca change de direction a droite
      if (ballX - 0.02 < -1) {
        ballDirection = Direction.right;

        //si la balle touche les cotés ca change de direction a gauche
      } else if (ballX + 0.02 > 1) {
        ballDirection = Direction.left;
      }

      // Bouge la bale dans lea direction approprié
      if (ballDirection == Direction.left) {
        setState(() {
          ballX -= 0.005;
        });
      } else if (ballDirection == Direction.right) {
        setState(() {
          ballX += 0.005;
        });
      }

      //check si la balle touche le joueur
      if (playerDies()) {
        timer.cancel();
        _showDialog();
      }

      // Le temps s'incremente
      time += 0.1;
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

        //arreter missiles quand ca arrive au top
        if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) {
          resetMissile();
          timer.cancel();
        }

        //checker si le missile touche la balle
        if (ballY > heighToCoordinate(missileHeight) &&
            (ballX - missileX).abs() < 0.03) {
          resetMissile();
          ballX = 5;
          timer.cancel();
        }
      });
    }
  }

  //Convertis la hauteur en coodonnées
  double heighToCoordinate(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
    double position = 1 - 2 * (height / totalHeight);
    return position;
  }

  void resetMissile() {
    missileHeight = playerX;
    missileHeight = 0;
    midshoot = false;
  }

  bool playerDies() {
    //si la balle touche le joueur et si la position du joueur et de la balle sont la meme
    if ((ballX - playerX).abs() < 0.05 && ballY > 0.95) {
      return true;
    } else {
      return false;
    }
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
                    MyBall(ballX: ballX, ballY: ballY),
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
                    MyButton(icon: Icons.play_arrow, function: startGame),
                    MyButton(icon: Icons.arrow_back, function: moveLeft),
                    MyButton(icon: Icons.arrow_upward, function: fireMissile),
                    MyButton(icon: Icons.arrow_forward, function: moveRight),
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
