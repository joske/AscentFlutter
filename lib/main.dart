import 'dart:io';

import 'package:ascent/home-ios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData androidTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    );

    final ThemeData androidDarkTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    );

    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Ascents',
        // Theme follows system setting automatically when not specified
        home: Builder(
          builder: (context) {
            final brightness = MediaQuery.platformBrightnessOf(context);
            return Theme(
              data: brightness == Brightness.dark
                  ? ThemeData.dark().copyWith(
                      cardColor: Colors.grey[850],
                      scaffoldBackgroundColor: Colors.black,
                    )
                  : ThemeData.light(),
              child: CupertinoHome(title: 'Ascents'),
            );
          },
        ),
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      );
    } else {
      return MaterialApp(
        title: 'Ascents',
        theme: androidTheme,
        darkTheme: androidDarkTheme,
        home: MaterialHome(title: 'Ascents'),
      );
    }
  }
}
