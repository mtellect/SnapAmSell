import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConfig {
  static const String appName = "SnapAmSell";
  static const String appIcon = "assets/images/ic_launcher.png";
  static const String appFont = "";
  static const int appVersion = 0;
  static const Color appColor = Color(0xFFFF842F);
  static const Color appColor_dark = Color(0xFFE5762A);
  static const Color textColor = Color(0xFF5c4eb2);
  static const bool isProduction = false;

  static TextStyle textStyle({double size, FontWeight weight, Color color}) =>
      GoogleFonts.pacifico(
        fontWeight: weight,
        fontSize: size,
        color: color,
      );
}
