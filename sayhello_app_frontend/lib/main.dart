import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';

import 'screens/auth/landing_page.dart';
import 'package:sayhello_app_frontend/screens/auth/learner_signin.dart';
import 'package:sayhello_app_frontend/screens/auth/instructor_signin.dart';
import 'package:sayhello_app_frontend/screens/auth/learner_signup.dart';
import 'package:sayhello_app_frontend/screens/auth/instructor_signup.dart';

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
      // home: const LearnerMainTab(),
      // home: const LandingPage(),

      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/learner-signin': (context) => const LearnerSignInPage(),
        '/instructor-signin': (context) => const InstructorSignInPage(),
        '/learner-signup': (context) => const LearnerSignupPage(),
        '/instructor-signup': (context) => const InstructorSignupPage(),
        '/learner-main': (context) => const LearnerMainTab(),
      },
    );
  }
}
