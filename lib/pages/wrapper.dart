import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:insta/models/user.dart';
import 'package:insta/pages/authenticate.dart';
import 'package:insta/pages/create_account.dart';
import 'package:insta/pages/home.dart';
import 'package:provider/provider.dart';

final userRef = Firestore.instance.collection("users");
User currentUser;

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

    // return either the Home or Authenticate widget
    if (user == null) {
      setState(() {
        userAccountChecked = false;
      });
      return Authenticate();
    } else {
      if (!userAccountChecked) {
        checkUserAccountExists(user.uid);
        userAccountChecked = true;
      }
      if (accountCreated == true) {
        return Home();
      } else {
        return CreateAccount(
            accountHasBeenCreated: accountHasBeenCreated,
            userRef: userRef,
            user: user);
      }
    }
  }

  accountHasBeenCreated(userID) async {
    //refetch the userdata from firebase
    final DocumentSnapshot doc = await userRef.document(userID).get();
    currentUser = User.fromDocument(doc); //create user object for current user
    setState(() {
      accountCreated = true;
    });
  }

  Future<void> checkUserAccountExists(userID) async {
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
