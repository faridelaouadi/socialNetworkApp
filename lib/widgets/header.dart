import 'package:flutter/material.dart';

header(
    {bool isAppTitle,
    String titleText,
    Icon leading,
    Function onPress,
    List<Widget> trailing}) {
  return AppBar(
    title: Text(
      isAppTitle ? "Instagram" : titleText,
      style: TextStyle(
          color: Colors.black,
          fontFamily: isAppTitle ? "Billabong" : "",
          fontSize: isAppTitle ? 40 : 20),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    leading: leading != null
        ? IconButton(
            icon: leading,
            onPressed: onPress,
          )
        : null,
    actions: trailing,
  );
}
