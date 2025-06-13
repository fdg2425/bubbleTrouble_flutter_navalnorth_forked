import 'dart:math';

import 'package:flutter/material.dart';

class FdgLogoAnimationWidget extends StatelessWidget {
  const FdgLogoAnimationWidget({
    super.key,
    required this.finalTop,
    required this.finalLeft,
    required this.animationValue,
    required this.playingAreaSize,
  });

  final double finalTop;
  final double finalLeft;
  final double animationValue;
  final Size playingAreaSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: finalTop + (1 - animationValue) * playingAreaSize.height / 2,
      left: finalLeft + (1 - animationValue) * playingAreaSize.width / 2,
      child: Transform(
        transform: Matrix4.rotationX(animationValue * 4 * pi),
        alignment: Alignment.center,
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Image.asset(
              "assets/images/FDG_Logo.png",
              width: 90 - (1 - animationValue) * 90,
            )),
      ),
    );
  }
}
