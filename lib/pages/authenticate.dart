import 'package:flutter/material.dart';
import 'package:insta/pages/register.dart';
import 'package:insta/pages/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool signInPage = true;

  void toggleView(){
    setState(() {
      signInPage = !signInPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (signInPage){
      return SignIn(toggleView: toggleView,);
    }else{
      return Register(toggleView: toggleView,);
    }
  }
}
