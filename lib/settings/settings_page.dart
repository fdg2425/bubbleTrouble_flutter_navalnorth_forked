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
              child: Text(
                  "This game was developed based on a video of Mitch Koko and a GitHub project from Irina Vasilescu. "
                  "They used different designs.\nWhich one should be used ?",
                  style: textStyleNormal),
            ),
            RadioListTile<bool>(
              title: Text("Irina's one (blue and green and player as an alien)",
                  style: textStyleNormal),
              value: true,
              groupValue: widget.settingsProvider.showIrinaLayout,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    widget.settingsProvider.showIrinaLayout = true;
                  });
                }
              },
            ),
            RadioListTile<bool>(
              title: Text(
                  "Mitch's one (pink and grey and player as a rectangle)",
                  style: textStyleNormal),
              value: false,
              groupValue: widget.settingsProvider.showIrinaLayout,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    widget.settingsProvider.showIrinaLayout = false;
                  });
                }
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 10),
              child: Text("Which controls should be shown to move the player?",
                  style: textStyleNormal),
            ),
            // without a SizedBox around the RadioListTile I got
            // "BoxConstraints forces an infinite width."
            RadioListTile<bool>(
              title: Text(
                  "a special panning area to move the player with gestures",
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
            RadioListTile<bool>(
              title: Text(
                  "buttons with left and right arrows as used by Mitch and Irina",
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
                      "This is version 0.5 from 05-Jul-2025,\n"
                      "developed during a Flutter training at FDG.",
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
