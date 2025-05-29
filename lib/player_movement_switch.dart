import 'package:flutter/material.dart';

class PlayerMovementSwitch extends StatelessWidget {
  const PlayerMovementSwitch(
      {super.key, required this.usePanning, required this.callback});

  final bool usePanning;
  final Function(bool value) callback;
  final textStyle = const TextStyle(color: Colors.white, fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("How to move the player ?", style: textStyle),
        Row(
          children: [
            Text("with buttons", style: textStyle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Switch(value: usePanning, onChanged: callback),
            ),
            Text("with panning", style: textStyle),
          ],
        ),
      ],
    );
  }
}
