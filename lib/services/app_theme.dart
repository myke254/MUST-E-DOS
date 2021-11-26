import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  get darkTheme => ThemeData(
      primarySwatch: Colors.green,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(titleTextStyle: GoogleFonts.varelaRound()));

  get lightTheme => ThemeData(
      primarySwatch: Colors.teal,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(titleTextStyle: GoogleFonts.varelaRound()));
}
