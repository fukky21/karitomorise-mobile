import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

PageTransitionsTheme _pageTransitionsTheme = const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

ThemeData defaultTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.main,
  accentColor: AppColors.main,
  scaffoldBackgroundColor: AppColors.grey15,
  dividerColor: AppColors.grey60,
  pageTransitionsTheme: _pageTransitionsTheme,
  textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
