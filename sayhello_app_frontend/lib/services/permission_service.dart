import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _permissionsRequestedKey = 'permissions_requested';

  /// List of permissions required by the app
  static const List<Permission> _requiredPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.audio,
    Permission.notification,
    Permission.photos,
    Permission.storage, // For accessing media files
  ];

  /// Check if permissions have been requested before
  static Future<bool> hasPermissionsBeenRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsRequestedKey) ?? false;
  }

  /// Mark permissions as requested
  static Future<void> markPermissionsAsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsRequestedKey, true);
  }

  /// Get the status of all required permissions
  static Future<Map<Permission, PermissionStatus>>
  getPermissionStatuses() async {
    final Map<Permission, PermissionStatus> statuses = {};

    for (final permission in _requiredPermissions) {
      statuses[permission] = await permission.status;
    }

    return statuses;
  }

  /// Request a specific permission
  static Future<PermissionStatus> requestPermission(
    Permission permission,
  ) async {
    return await permission.request();
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Request all required permissions
  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    return await requestMultiplePermissions(_requiredPermissions);
  }

  /// Check if all permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    final statuses = await getPermissionStatuses();
    return statuses.values.every((status) => status.isGranted);
  }

  /// Get permission name for display
  static String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
      case Permission.audio:
        return 'Music and Audio';
      case Permission.notification:
        return 'Notifications';
      case Permission.photos:
        return 'Photos and Videos';
      case Permission.storage:
        return 'Storage';
      default:
        return permission.toString().split('.').last;
    }
  }

  /// Get permission description for display
  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Access camera to take photos and record videos for language learning';
      case Permission.microphone:
        return 'Access microphone for voice recording and pronunciation practice';
      case Permission.audio:
        return 'Play audio content and pronunciation guides';
      case Permission.notification:
        return 'Send you reminders and learning notifications';
      case Permission.photos:
        return 'Access photos and videos for language learning activities';
      case Permission.storage:
        return 'Store your learning progress and media files';
      default:
        return 'Required for app functionality';
    }
  }

  /// Get permission icon
  static String getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return '📷';
      case Permission.microphone:
        return '🎤';
      case Permission.audio:
        return '🔊';
      case Permission.notification:
        return '🔔';
      case Permission.photos:
        return '📸';
      case Permission.storage:
        return '💾';
      default:
        return '🔐';
    }
  }

  /// Open app settings for manual permission management
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Get required permissions list
  static List<Permission> get requiredPermissions => _requiredPermissions;
}
