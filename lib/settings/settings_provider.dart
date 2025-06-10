class SettingsProvider {
  SettingsProvider({required this.callbackOnSettingsChange});

  final Function() callbackOnSettingsChange;

  bool _showButtonsForPlayerMovement = true;

  bool get showButtonsForPlayerMovement => _showButtonsForPlayerMovement;

  set showButtonsForPlayerMovement(bool value) {
    //print("value is $value");
    if (value != _showButtonsForPlayerMovement) {
      _showButtonsForPlayerMovement = value;
      callbackOnSettingsChange();
    }
  }

  // ToDo: load and save settings
}
