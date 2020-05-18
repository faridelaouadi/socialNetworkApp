import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor, Color(0xff002aff)]
    )
    ),
      child: Center(
        child: SpinKitChasingDots(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}