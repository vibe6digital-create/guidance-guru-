import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void pushNamed(String route, {Object? arguments}) {
    Navigator.pushNamed(this, route, arguments: arguments);
  }

  void pushReplacementNamed(String route, {Object? arguments}) {
    Navigator.pushReplacementNamed(this, route, arguments: arguments);
  }

  void pushAndRemoveAll(String route) {
    Navigator.pushNamedAndRemoveUntil(this, route, (_) => false);
  }

  void pop([dynamic result]) {
    Navigator.pop(this, result);
  }
}

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get initials {
    final words = trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return isNotEmpty ? this[0].toUpperCase() : '';
  }
}

extension WidgetExtensions on Widget {
  Widget padAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  Widget padHorizontal(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: this,
    );
  }

  Widget padVertical(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: this,
    );
  }
}

extension NumExtensions on num {
  SizedBox get height => SizedBox(height: toDouble());
  SizedBox get width => SizedBox(width: toDouble());
}
