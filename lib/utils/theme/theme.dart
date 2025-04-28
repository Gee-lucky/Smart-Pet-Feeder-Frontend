import 'package:flutter/material.dart';

class AppThemeColors {

  static const primaryColor = Color.fromARGB(255, 0, 49, 83);
  static const primaryColorDark = Color.fromARGB(255, 0, 49, 73);
  static const secondaryColor = Color.fromARGB(255, 255, 255, 255);
  static const whiteSmoke = Color.fromARGB(255, 245, 245, 245);
  static const darkWhiteOnLight = Color.fromARGB(255, 150, 150, 150);
  static const darkWhiteOnDark = Color.fromARGB(255, 50, 50, 50);
  static const onPrimaryColor = Color.fromARGB(190, 0, 49, 83);
  static const brightness = Colors.white;
  static const shadowColorOnLight = Color.fromARGB(150, 0, 0, 0);

}

class AppThemeColor{
  static var lightTheme = ThemeData(
    primaryColor: AppThemeColors.primaryColor,
    primaryColorDark: AppThemeColors.primaryColor,
    highlightColor: AppThemeColors.whiteSmoke,
    cardColor: AppThemeColors.darkWhiteOnLight,
    shadowColor: AppThemeColors.shadowColorOnLight,
  );

  static var darkTheme = ThemeData(
    primaryColor: AppThemeColors.primaryColorDark,
    primaryColorDark: AppThemeColors.primaryColorDark,
    highlightColor: AppThemeColors.whiteSmoke,
    cardColor: AppThemeColors.darkWhiteOnDark,
    shadowColor: AppThemeColors.shadowColorOnLight,
  );


}