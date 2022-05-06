// @dart=2.9
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
    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Ascents',
        theme: const CupertinoThemeData(brightness: Brightness.light),
        home: CupertinoHome(title: 'Ascents'),
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      );
    } else {
      return MaterialApp(
        title: 'Ascents',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        home: MaterialHome(title: 'Ascents'),
      );
    }
  }
}
