import 'package:flutter/material.dart';
import '../../services/permission_service.dart';
import 'permission_request_page.dart';
import '../auth/landing_page.dart';

class PermissionWrapper extends StatefulWidget {
  const PermissionWrapper({super.key});

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _isLoading = true;
  bool _needsPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final hasBeenRequested =
          await PermissionService.hasPermissionsBeenRequested();

      setState(() {
        _needsPermissions = !hasBeenRequested;
        _isLoading = false;
      });
    } catch (e) {
      // If there's an error, proceed to the app
      setState(() {
        _needsPermissions = false;
        _isLoading = false;
      });
    }
  }

  void _onPermissionsHandled() {
    setState(() {
      _needsPermissions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.translate, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'SayHello App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ],
          ),
        ),
      );
    }

    if (_needsPermissions) {
      return PermissionRequestPage(onPermissionsHandled: _onPermissionsHandled);
    }

    return const LandingPage();
  }
}
