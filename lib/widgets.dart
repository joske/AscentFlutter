import 'dart:io';

import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class PlatformWidget<I extends Widget, A extends Widget> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return createAndroidWidget(context);
    } else if (Platform.isIOS) {
      return createIosWidget(context);
    }
    return new Container();
  }

  I createIosWidget(BuildContext context);
  A createAndroidWidget(BuildContext context);
}

class PlatformScaffold extends PlatformWidget<CupertinoPageScaffold, Scaffold> {
  final String title;
  final Widget child;
  final VoidCallback fabOnPressed;
  final String fabTooltip;
  final Widget fabChild;

  PlatformScaffold({this.title, this.child, this.fabChild, this.fabOnPressed, this.fabTooltip});

  @override
  Scaffold createAndroidWidget(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: child,
      floatingActionButton: fabChild != null
          ? FloatingActionButton(
              child: fabChild,
              tooltip: fabTooltip,
              onPressed: fabOnPressed,
            )
          : Container(),
    );
  }

  @override
  CupertinoPageScaffold createIosWidget(BuildContext context) {
    return new CupertinoPageScaffold(
        navigationBar: new CupertinoNavigationBar(
            middle: new Text(title),
            trailing: fabChild != null
                ? CupertinoButton(
                    onPressed: fabOnPressed,
                    child: fabChild,
                  )
                : Container()),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            child,
          ],
        ));
  }
}

class PlatformTextField extends PlatformWidget<CupertinoTextField, TextField> {
  final TextEditingController controller;
  PlatformTextField({this.controller});

  @override
  TextField createAndroidWidget(BuildContext context) {
    return new TextField(
      controller: this.controller,
    );
  }

  @override
  CupertinoTextField createIosWidget(BuildContext context) {
    return new CupertinoTextField(
      controller: this.controller,
    );
  }
}

class PlatformApp extends PlatformWidget<CupertinoApp, MaterialApp> {
  final Widget home;
  final ThemeData theme;
  final String title;

  PlatformApp({this.title, this.theme, this.home});

  @override
  MaterialApp createAndroidWidget(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: theme,
      home: home,
    );
  }

  @override
  CupertinoApp createIosWidget(BuildContext context) {
    return CupertinoApp(
      title: title,
      home: home,
    );
  }
}

class PlatformListTile extends PlatformWidget<CupertinoListTile, ListTile> {
  final Widget title;
  final Widget subtitle;

  PlatformListTile({this.title, this.subtitle});

  @override
  ListTile createAndroidWidget(BuildContext context) {
    return new ListTile(
      title: Card(
        child: this.title,
      ),
      subtitle: subtitle,
    );
  }

  @override
  CupertinoListTile createIosWidget(BuildContext context) {
    return new CupertinoListTile(
      title: this.title,
      subtitle: subtitle,
    );
  }
}

class PlatformButton extends PlatformWidget<CupertinoButton, ElevatedButton> {
  final VoidCallback onPressed;
  final Widget child;

  PlatformButton({this.child, this.onPressed});

  @override
  ElevatedButton createAndroidWidget(BuildContext context) {
    return new ElevatedButton(
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  CupertinoButton createIosWidget(BuildContext context) {
    return new CupertinoButton(
      child: child,
      onPressed: onPressed,
      color: Colors.blue,
    );
  }
}

class PlatformSwitch extends PlatformWidget<CupertinoSwitch, Switch> {
  final onChanged;
  final value;

  PlatformSwitch({this.onChanged, this.value});

  @override
  Switch createAndroidWidget(BuildContext context) {
    return new Switch(
      onChanged: onChanged,
      value: value,
    );
  }

  @override
  CupertinoSwitch createIosWidget(BuildContext context) {
    return new CupertinoSwitch(
      onChanged: onChanged,
      value: value,
    );
  }
}

class ItemWidget extends PlatformWidget<Widget, Widget> {
  final Widget child;

  ItemWidget({this.child});

  @override
  Widget createAndroidWidget(BuildContext context) => new Card(
        child: child,
      );
  @override
  Widget createIosWidget(BuildContext context) => child;
}
