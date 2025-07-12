import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/learner/learner_main_tab.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

/// Custom dark theme that uses #151515 as scaffold background.
final ThemeData customDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF151515),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF151515),
    foregroundColor: Colors.white,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF151515),
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  colorScheme: const ColorScheme.dark(
    background: Color(0xFF151515),
    primary: Colors.blue,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SayHello App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,   // system / light / dark
      theme: ThemeData.light(),             // light theme
      darkTheme: customDarkTheme,           // custom dark theme
      home: const LearnerMainTab(),
    );
  }
}
