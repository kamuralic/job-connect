import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData myTheme() {
  TextTheme _myTextTheme(TextTheme base) {
    return base.copyWith(
      //this for main headings
      headline1: base.headline1!.copyWith(
          fontFamily: 'Blinker',
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold),
      subtitle1: base.subtitle1!.copyWith(
          fontFamily: 'Blinker',
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold),
      subtitle2: base.subtitle2!.copyWith(
          fontFamily: 'Blinker',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.normal),
      //for small headings
      headline2: base.headline2!.copyWith(
          fontFamily: 'Blinker',
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold),
      //for gray small headings
      headline3: base.headline3!.copyWith(
          fontFamily: 'Blinker',
          color: HexColor("#474E8C"),
          fontSize: 15,
          fontWeight: FontWeight.bold),
      //for Red small text
      headline4: base.headline4!.copyWith(
          fontFamily: 'Blinker',
          color: HexColor("#dc2430"),
          fontSize: 15,
          fontWeight: FontWeight.bold),
      headline5: base.headline5!.copyWith(
          fontFamily: 'Blinker',
          color: HexColor("#BABABF"),
          fontSize: 15,
          fontWeight: FontWeight.normal),
      // for titles and bodytexts
      bodyText1: base.bodyText1!.copyWith(
          fontFamily: 'Blinker',
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.normal),
      //for very small body texts
      bodyText2: base.bodyText2!.copyWith(
          fontFamily: 'Blinker',
          color: HexColor("#BABABF"),
          fontSize: 12,
          fontWeight: FontWeight.normal),
    );
  }

  final ThemeData base = ThemeData.light();
  return base.copyWith(
      textTheme: _myTextTheme(base.textTheme),
      primaryColor: HexColor("#dc2430"),
      accentColor: HexColor("#474E8C"),
      scaffoldBackgroundColor: Colors.grey.shade200,
      iconTheme: IconThemeData(color: HexColor("#dc2430"), size: 24));
}
