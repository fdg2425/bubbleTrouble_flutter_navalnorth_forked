import '../helper_classes/layout.dart';

class SettingsProvider {
  SettingsProvider({required this.callbackOnSettingsChange});

  final Function() callbackOnSettingsChange;

  bool _showButtonsForPlayerMovement = false;
  bool get showButtonsForPlayerMovement => _showButtonsForPlayerMovement;
  set showButtonsForPlayerMovement(bool value) {
    //print("value is $value");
    if (value != _showButtonsForPlayerMovement) {
      _showButtonsForPlayerMovement = value;
      callbackOnSettingsChange();
    }
  }

  bool _showIrinaLayout = true;
  bool get showIrinaLayout => _showIrinaLayout;
  set showIrinaLayout(bool value) {
    if (value != _showIrinaLayout) {
      _showIrinaLayout = value;
      _layout = _showIrinaLayout ? Layout.irina() : Layout.mitch();
      callbackOnSettingsChange();
    }
  }

  Layout _layout = Layout.irina();
  Layout get layout => _layout;

  // ToDo: load and save settings
}
