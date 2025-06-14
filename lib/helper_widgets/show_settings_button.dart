import 'dart:math';
import 'package:flutter/material.dart';
import '../settings/settings_provider.dart';
import '../settings/settings_page.dart';

class ShowSettingsButton extends StatelessWidget {
  const ShowSettingsButton(
      {super.key,
      required this.finalTop,
      required this.finalRight,
      required this.animationValue,
      required this.playingAreaSize,
      required this.settingsProvider});

  final double finalTop;
  final double finalRight;
  final double animationValue;
  final Size playingAreaSize;
  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    var mTransform = Matrix4.rotationX(animationValue * 4 * pi);
    mTransform.multiply(Matrix4.rotationY(animationValue * pi));

    return Positioned(
        top: finalTop + (1 - animationValue) * playingAreaSize.height / 2,
        right: finalRight + (1 - animationValue) * playingAreaSize.width / 2,
        child: Transform(
          transform: mTransform,
          alignment: Alignment.center,
          child: Container(
              decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: IconButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(
                          settingsProvider: settingsProvider,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings))),
        ));
  }
}
