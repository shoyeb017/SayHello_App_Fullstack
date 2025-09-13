import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class LearnerSignInPage extends StatefulWidget {
  const LearnerSignInPage({super.key});

  @override
  State<LearnerSignInPage> createState() => _LearnerSignInPageState();
}

class _LearnerSignInPageState extends State<LearnerSignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF7a54ff);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.learnerSignIn),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.deepPurple,
        actions: [
          // 🔧 SETTINGS ICON - This is the settings button in the app bar
          // Click this to open the settings bottom sheet with theme and language options
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => SettingsProvider.showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black26
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.welcomeBack,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.signInToContinue,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Username field
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.username,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        prefixIcon: Icon(Icons.person, color: primaryColor),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        prefixIcon: Icon(Icons.lock, color: primaryColor),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign In button - primary colored
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                print(
                                  '🖱️ SignIn: User clicked sign-in button',
                                );

                                final username = _usernameController.text
                                    .trim();
                                final password = _passwordController.text
                                    .trim();

                                print('📝 SignIn: Input validation...');
                                print(
                                  '   - Username: "$username" (length: ${username.length})',
                                );
                                print(
                                  '   - Password: [REDACTED] (length: ${password.length})',
                                );

                                if (username.isEmpty || password.isEmpty) {
                                  print(
                                    '❌ SignIn: Validation failed - empty fields',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!.required,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                print('✅ SignIn: Input validation passed');
                                print(
                                  '🔄 SignIn: Starting authentication process...',
                                );

                                setState(() => _isLoading = true);

                                try {
                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );

                                  print(
                                    '📞 SignIn: Calling AuthProvider.signInLearner()',
                                  );
                                  final success = await authProvider
                                      .signInLearner(username, password);

                                  print(
                                    '📊 SignIn: Authentication result: $success',
                                  );

                                  if (success) {
                                    print(
                                      '🎉 SignIn: Authentication successful!',
                                    );
                                    print(
                                      '👤 SignIn: Current user: ${authProvider.currentUser?.name}',
                                    );
                                    print(
                                      '🔄 SignIn: Navigating to main page...',
                                    );

                                    // Clear entire navigation stack and navigate to main page
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/learner-main',
                                      (route) => false, // Remove all previous routes
                                    );
                                  } else {
                                    print('❌ SignIn: Authentication failed');
                                    print(
                                      '💬 SignIn: Error message: ${authProvider.error}',
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          authProvider.error ??
                                              'Sign in failed',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e, stackTrace) {
                                  print(
                                    '💥 SignIn: Unexpected error occurred: $e',
                                  );
                                  print('📍 SignIn: Stack trace: $stackTrace');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Unexpected error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    print('🏁 SignIn: Resetting loading state');
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                        icon: _isLoading
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(Icons.login, color: Colors.white),
                        label: Text(
                          _isLoading
                              ? 'Signing in...'
                              : AppLocalizations.of(context)!.signIn,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: primaryColor.withOpacity(
                            0.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign Up link with outlined button style
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/learner-signup');
                        },
                        icon: Icon(Icons.person_add, color: primaryColor),
                        label: Text(
                          AppLocalizations.of(context)!.signUp,
                          style: TextStyle(color: primaryColor, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
