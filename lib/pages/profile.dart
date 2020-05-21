import 'package:flutter/material.dart';
import 'package:insta/widgets/header.dart';
import 'package:insta/auth.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService(context: context);
    return Scaffold(
      appBar: header(
        isAppTitle: false,
        titleText: "Profile",
        leading: Icon(Icons.arrow_back),
        onPress: _auth.signOut,
      ),
      body: Center(
        child: Text(
          "Profile page",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
