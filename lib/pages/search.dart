import 'package:flutter/material.dart';
import 'package:insta/widgets/header.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: true),
      body: Center(
        child: Text(
          "Search page",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
