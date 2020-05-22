import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/auth.dart';
import 'package:insta/pages/wrapper.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthService()
          .user, //accessing the user stream from the authService class.
      child: MaterialApp(
        title: 'FlutterShare',
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
