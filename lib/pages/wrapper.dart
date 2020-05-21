import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:insta/pages/authenticate.dart';
import 'package:insta/pages/create_account.dart';
import 'package:insta/pages/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool accountCreated;
  bool userAccountChecked;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(
        context); //accessing the firebase user from the provider package
    final userRef = Firestore.instance.collection("users");
    // return either the Home or Authenticate widget
    if (user == null) {
      setState(() {
        userAccountChecked = false;
      });
      return Authenticate();
    } else {
      if (!userAccountChecked) {
        checkUserAccountExists(userRef, user.uid);
        userAccountChecked = true;
      }
      if (accountCreated) {
        return Home();
      } else {
        return CreateAccount(
          accountHasBeenCreated: accountHasBeenCreated,
        );
      }
    }
  }

  accountHasBeenCreated() {
    setState(() {
      accountCreated = true;
    });
  }

  Future<void> checkUserAccountExists(userRef, userID) async {
    final DocumentSnapshot doc = await userRef.document(userID).get();
    if (!doc.exists) {
      setState(() {
        accountCreated = false;
      });
    } else {
      setState(() {
        accountCreated = true;
      });
    }
  }
}
