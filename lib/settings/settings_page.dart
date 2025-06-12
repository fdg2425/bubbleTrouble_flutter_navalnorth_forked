import 'package:flutter/material.dart';

import 'settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.settingsProvider});

  final SettingsProvider settingsProvider;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final textStyleNormal = const TextStyle(fontSize: 18);
  final textStyleUnderlined =
      const TextStyle(fontSize: 18, decoration: TextDecoration.underline);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Height of the divider
          child: Divider(height: 1, thickness: 1, color: Colors.grey),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 10),
              child: Text("Which controls should be shown to move the player?",
                  style: textStyleNormal),
            ),
            // without a SizedBox around the RadioListTile I got
            // "BoxConstraints forces an infinite width."
            RadioListTile<bool>(
              title: Text("buttons with left and right arrows",
                  style: textStyleNormal),
              value: true,
              groupValue: widget.settingsProvider.showButtonsForPlayerMovement,
              onChanged: (bool? value) {
                if (value != null) {
                  // next setState is needed to update the Radiobuttons
                  setState(() {
                    widget.settingsProvider.showButtonsForPlayerMovement = true;
                  });
                }
              },
            ),
            RadioListTile<bool>(
              title: Text(
                  "an extra panning area to move the player with gestures",
                  style: textStyleNormal),
              value: false,
              groupValue: widget.settingsProvider.showButtonsForPlayerMovement,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    widget.settingsProvider.showButtonsForPlayerMovement =
                        false;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Remark", style: textStyleUnderlined),
                  Text(
                      "In case you have a keyboard, you can use ArrowLeft and ArrowRight keys to move the player "
                      "and ArrowUp or Space key to fire a missile.\n"
                      "Panning in the playing area moves the player too, but in this case your finger might hide the player or the balls, "
                      "therefore the option for an extra panning area below the playground.",
                      style: textStyleNormal),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Version info", style: textStyleUnderlined),
                  Text(
                      "This is version 0.2 from 12-June-2025,\n"
                      "developped during a Flutter training at FDG.",
                      style: textStyleNormal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
