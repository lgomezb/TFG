import 'package:flutter/material.dart';

class CustomTheme { //1
  static ThemeData get lightTheme { //2
    return ThemeData( //3
      primaryColor: Color.fromRGBO(238,211,196,1),
      accentColor: Color.fromRGBO(222,150,88,1),
      hoverColor: Color.fromRGBO(156, 114, 104, 1),
      hintColor: Color.fromRGBO(198,184,178,1),
      dividerColor: Colors.white,
      buttonColor: Color.fromRGBO(221,214,214,1),
      scaffoldBackgroundColor: Color.fromRGBO(123,56,0, 1),
      canvasColor: Color.fromRGBO(217,163,150,1),
      platform: TargetPlatform.android,

    ); //3
  } //2
} //1