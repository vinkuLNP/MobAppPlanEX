import 'package:flutter/material.dart';

extension AppContextExtensions on BuildContext {
  // THEME & COLORS
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // SIZE / MEDIA QUERY
  MediaQueryData get mq => MediaQuery.of(this);
  double get width => mq.size.width;
  double get height => mq.size.height;

  // Responsive breakpoints
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1000;
  bool get isDesktop => width >= 1000;

  // PADDING & SPACING
  EdgeInsets get padding => const EdgeInsets.all(16);
  EdgeInsets get horizontalPadding => const EdgeInsets.symmetric(horizontal: 16);
  EdgeInsets get verticalPadding => const EdgeInsets.symmetric(vertical: 16);
  EdgeInsets get pagePadding => const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
  EdgeInsets get smallPadding => const EdgeInsets.all(8);
  EdgeInsets get largePadding => const EdgeInsets.all(24);

  // Shortcut for common spacing widgets
  SizedBox get gap8 => const SizedBox(height: 8);
  SizedBox get gap16 => const SizedBox(height: 16);
  SizedBox get gap20 => const SizedBox(height: 20);
  SizedBox get gap24 => const SizedBox(height: 24);
  SizedBox get gap40 => const SizedBox(height: 40);



}
