import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:insta/pages/authenticate.dart';
import 'package:insta/pages/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<FirebaseUser>(context); //accessing the firebase user from the provider package
    // return either the Home or Authenticate widget
    if (user == null){
      return Authenticate();
    }else{
      print(user.email);
      return Home();
    }

  }
}
