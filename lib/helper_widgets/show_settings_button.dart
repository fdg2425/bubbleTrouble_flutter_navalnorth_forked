import 'package:flutter/material.dart';
import 'package:saute_mouton/settings/settings_provider.dart';

import '../settings/settings_page.dart';

class ShowSettingsButton extends StatelessWidget {
  const ShowSettingsButton(
      {super.key,
      required this.top,
      required this.right,
      required this.settingsProvider});

  final double top;
  final double right;
  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: top,
        right: right,
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
                icon: const Icon(Icons.settings))));
  }
}
