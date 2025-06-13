import 'dart:math';

import 'package:flutter/material.dart';

class TitleAnimationWidget extends StatelessWidget {
  const TitleAnimationWidget({
    super.key,
    required this.animationValue,
  });

  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, -0.6 + 0.6 * (1 - animationValue)),
      child: Transform(
        transform: Matrix4.rotationY(animationValue * 2 * pi),
        alignment: Alignment.topCenter,
        child: Text("Bubble Trouble\nwith Flutter",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'PixeloidSans',
                fontSize: 10 + 20 * animationValue)),
      ),
    );
  }
}
