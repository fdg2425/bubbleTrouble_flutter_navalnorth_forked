import '../helper_classes/layout.dart';
import '../main.dart';

class SettingsProvider {
  SettingsProvider({required this.callbackOnSettingsChange}) {
    bool? test = globalPrefs.getBool("showButtons");
    if (test != null) {
      _showButtonsForPlayerMovement = test;
    }

    test = globalPrefs.getBool("showIrina");
    if (test != null) {
      _showIrinaLayout = test;
    }
  }

  final Function() callbackOnSettingsChange;

  bool _showButtonsForPlayerMovement = false;
  bool get showButtonsForPlayerMovement => _showButtonsForPlayerMovement;
  set showButtonsForPlayerMovement(bool value) {
    //print("value is $value");
    if (value != _showButtonsForPlayerMovement) {
      _showButtonsForPlayerMovement = value;
      globalPrefs.setBool("showButtons", value);
      callbackOnSettingsChange();
    }
  }

  bool _showIrinaLayout = true;
  bool get showIrinaLayout => _showIrinaLayout;
  set showIrinaLayout(bool value) {
    if (value != _showIrinaLayout) {
      _showIrinaLayout = value;
      globalPrefs.setBool("showIrina", value);
      callbackOnSettingsChange();
    }
  }

  Layout get layout => _showIrinaLayout ? Layout.irina() : Layout.mitch();

  // ToDo: load and save settings
}
