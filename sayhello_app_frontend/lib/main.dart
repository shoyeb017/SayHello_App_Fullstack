import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/supabase_config.dart';
import 'services/storage_service.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/learner_provider.dart';
import 'providers/course_provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/instructor_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/session_provider.dart';
import 'providers/recorded_class_provider.dart';

import 'screens/auth/landing_page.dart';
import 'screens/permissions/permission_wrapper.dart';
import 'package:sayhello_app_frontend/screens/auth/learner_signin.dart';
import 'package:sayhello_app_frontend/screens/auth/instructor_signin.dart';
import 'package:sayhello_app_frontend/screens/auth/learner_signup.dart';
import 'package:sayhello_app_frontend/screens/auth/instructor_signup.dart';

import 'screens/learner/learner_main_tab.dart';
import 'screens/instructor/instructor_main_tab.dart';

void main() async {
  // Ensure proper Flutter binding initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize storage
  try {
    await StorageService().initializeStorage();
    print('Storage initialized successfully');
  } catch (e) {
    print('Failed to initialize storage: $e');
  }

  // Set preferred orientations for better video experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => LearnerProvider()),
        ChangeNotifierProvider(create: (_) => InstructorProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => RecordedClassProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
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
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'SayHello App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode, // system / light / dark
      theme: ThemeData.light(), // light theme
      darkTheme: customDarkTheme, // custom dark theme
      // Internationalization configuration
      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
        Locale('ja', ''), // Japanese
        Locale('bn', ''), // Bangla
        Locale('ko', ''), // Korean
      ],

      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => const PermissionWrapper(),
        '/landing': (BuildContext context) => const LandingPage(),
        '/learner-signin': (BuildContext context) => const LearnerSignInPage(),
        '/instructor-signin': (BuildContext context) =>
            const InstructorSignInPage(),
        '/learner-signup': (BuildContext context) => const LearnerSignupPage(),
        '/instructor-signup': (BuildContext context) =>
            const InstructorSignupPage(),
        '/learner-main': (BuildContext context) => const LearnerMainTab(),
        '/instructor-main': (BuildContext context) => const InstructorMainTab(),
      },
    );
  }
}
