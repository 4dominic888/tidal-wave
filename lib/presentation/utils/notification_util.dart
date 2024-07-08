import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationUtil{

  static void showSuccessNotification({required String title, required String description}) {
    showSimpleNotification(
      Text(title),
      subtitle: Text(description),
      autoDismiss: true,
      foreground: Colors.white,
      background: Colors.green,
      trailing: const Icon(Icons.check),
      duration: const Duration(seconds: 3)
    );
  }

  static void showErrorNotification({required String title, required String description}) {
    showSimpleNotification(
      Text(title),
      subtitle: Text(description),
      autoDismiss: true,
      foreground: Colors.white,
      background: Colors.red,
      trailing: const Icon(Icons.error),
      duration: const Duration(seconds: 5)
    );
  }
}