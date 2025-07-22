import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Logo / Icon
              Center(
                child: Icon(
                  Icons.language,
                  size: 72,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 16),
              // App Name
              Center(
                child: Text(
                  'Polyglot Learner',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Choose your role to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Learner Sign In
              _buildOptionButton(
                context,
                icon: Icons.login,
                label: 'Learner Sign In',
                onTap: () => Navigator.pushNamed(context, '/learner-signin'),
              ),
              const SizedBox(height: 16),

              // Learner Sign Up
              _buildOptionButton(
                context,
                icon: Icons.person_add,
                label: 'Learner Sign Up',
                onTap: () => Navigator.pushNamed(context, '/learner-signup'),
              ),
              const SizedBox(height: 16),

              // Instructor Sign In
              _buildOptionButton(
                context,
                icon: Icons.school,
                label: 'Instructor Sign In',
                onTap: () => Navigator.pushNamed(context, '/instructor-signin'),
              ),
              const SizedBox(height: 16),

              // Instructor Sign Up
              _buildOptionButton(
                context,
                icon: Icons.how_to_reg,
                label: 'Instructor Sign Up',
                onTap: () => Navigator.pushNamed(context, '/instructor-signup'),
              ),
              const Spacer(),
              Center(
                child: Text(
                  '© 2025 Polyglot App',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.purple),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
