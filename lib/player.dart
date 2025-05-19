import 'package:flutter/material.dart';

const double playerWidth = 50;
const double playerHeight = 50;

class MyPlayer extends StatelessWidget {
  final double playerX;

  const MyPlayer({super.key, required this.playerX});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.pink,
      alignment: Alignment(playerX, 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.deepPurple,
          height: playerHeight,
          width: playerWidth,
        ),
      ),
    );
  }
}
