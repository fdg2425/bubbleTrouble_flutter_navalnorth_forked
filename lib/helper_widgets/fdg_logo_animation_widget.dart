import 'dart:math';

import 'package:flutter/material.dart';

class FdgLogoAnimationWidget extends StatelessWidget {
  const FdgLogoAnimationWidget({
    super.key,
    required this.finalTop,
    required this.finalLeft,
    required Animation<double> animation,
    required this.playingAreaSize,
  }) : _animation = animation;

  final double finalTop;
  final double finalLeft;
  final Animation<double> _animation;
  final Size playingAreaSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: finalTop + (1 - _animation.value) * playingAreaSize.height / 2,
      left: finalLeft + (1 - _animation.value) * playingAreaSize.width / 2,
      child: Transform(
        transform: Matrix4.rotationX(_animation.value * 4 * pi),
        alignment: Alignment.center,
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Image.asset(
              "assets/images/FDG_Logo.png",
              width: 90 - (1 - _animation.value) * 90,
            )),
      ),
    );
  }
}
