import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationUtils {
  /// Safely navigates back or to home if no previous route exists
  static void goBackOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// Navigates to a specific route
  static void goTo(BuildContext context, String route) {
    context.go(route);
  }

  /// Pushes a new route onto the navigation stack
  static void push(BuildContext context, String route) {
    context.push(route);
  }

  /// Replaces the current route with a new one
  static void replace(BuildContext context, String route) {
    context.pushReplacement(route);
  }
}
