import 'package:flutter/material.dart';
import 'ball.dart';

class BallWidget extends StatelessWidget {
  final Ball ball;

  const BallWidget({super.key, required this.ball});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(ball.alignX, ball.alignY),
      child: Container(
        width: 20,
        height: 20,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      ),
    );
  }
}
