import 'package:flutter/material.dart';
import 'package:insta/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  final Function accountHasBeenCreated;
  CreateAccount({this.accountHasBeenCreated});
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(
        isAppTitle: false,
        titleText: "Create Account",
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Create Account page",
              style: TextStyle(fontSize: 40),
            ),
            RaisedButton(
              child: Text("Create Account"),
              onPressed: widget.accountHasBeenCreated,
            )
          ],
        ),
      ),
    );
  }
}
