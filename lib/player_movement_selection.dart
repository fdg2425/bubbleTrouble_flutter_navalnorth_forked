import 'package:flutter/material.dart';

class PlayerMovementSelection extends StatelessWidget {
  const PlayerMovementSelection(
      {super.key, required this.usePanning, required this.callback});

  final bool usePanning;
  final Function(bool value) callback;
  final textStyleTitle = const TextStyle(color: Colors.white, fontSize: 18);
  final textStyleBody = const TextStyle(color: Colors.white, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("How to move the player ?", style: textStyleTitle),
        // without a SizedBox around the RadioListTile I got
        // "BoxConstraints forces an infinite width."
        Row(
          children: [
            SizedBox(
              width: 200,
              //height: 20,
              child: RadioListTile<bool>(
                title: Text("with buttons", style: textStyleBody),
                //dense: true,
                visualDensity:
                    const VisualDensity(horizontal: -2.0, vertical: -4.0),
                value: false,
                groupValue: usePanning,
                onChanged: (bool? value) {
                  if (value != null) {
                    callback(false);
                  }
                },
              ),
            ),
            SizedBox(
              width: 200,
              //height: 20,

              child: RadioListTile<bool>(
                title: Text("with panning", style: textStyleBody),
                //dense: true,
                visualDensity:
                    const VisualDensity(horizontal: -2.0, vertical: -4.0),
                value: true,
                groupValue: usePanning,
                onChanged: (bool? value) {
                  if (value != null) {
                    callback(true);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
