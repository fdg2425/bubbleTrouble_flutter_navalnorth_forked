import 'package:flutter/material.dart';
import 'package:saute_mouton/homepage.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Declare a global late variable for SharedPreferences
// This will be initialized once in the main function.
late SharedPreferences globalPrefs;

void main() async {
  // Ensure that the Flutter binding is initialized. This is required before
  // calling any plugin-specific code, including SharedPreferences.getInstance().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the global SharedPreferences instance here.
  // This ensures it's available throughout the app after startup.
  globalPrefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FDG Bubble Trouble",
      home: HomePage(),
    );
  }
}
