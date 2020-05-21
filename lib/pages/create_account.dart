import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/auth.dart';
import 'package:insta/pages/wrapper.dart';
import 'package:insta/widgets/header.dart';
import 'package:provider/provider.dart';
import 'package:insta/widgets/progress.dart';

import '../constants.dart';

class CreateAccount extends StatefulWidget {
  final Function accountHasBeenCreated;
  final CollectionReference userRef;
  final FirebaseUser user;

  CreateAccount({this.accountHasBeenCreated, this.userRef, this.user});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String username;
  String bio;
  String displayName;
  String error = "";
  bool loading = false;

  @override
  Widget build(BuildContext parentContext) {
    final AuthService _auth = AuthService(context: context);
    final user = Provider.of<FirebaseUser>(context);
    return Scaffold(
        appBar: header(
          isAppTitle: false,
          titleText: "Setup Profile",
          leading: Icon(Icons.arrow_back),
          onPress: _auth.signOut,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  loading
                      ? linearProgress()
                      : SizedBox(
                          height: 0,
                        ),
                  Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Center(
                      child: Text(
                        "Modify your profile",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user.photoUrl !=
                                      null
                                  ? user.photoUrl
                                  : "https://wordypix.co.uk/wp-content/uploads/2015/12/profile.jpg"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              onChanged: (val) {
                                setState(() {
                                  username = val;
                                });
                              },
                              validator: (String value) {
                                if (value.length <= 3) {
                                  return 'Username needs to be more than 3 characters';
                                } else {
                                  return null;
                                }
                              },
                              decoration: kTextFieldDecorationForWhiteBackground
                                  .copyWith(
                                      labelText: "Username",
                                      hintText: "Must be atleast 3 characters"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Enter your name';
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (val) {
                                setState(() {
                                  displayName = val;
                                });
                              },
                              initialValue: user.displayName,
                              decoration: kTextFieldDecorationForWhiteBackground
                                  .copyWith(
                                      labelText: "Display Name",
                                      hintText: "What shall we call you?"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              onChanged: (val) {
                                setState(() {
                                  username = val;
                                });
                              },
                              enabled: false,
                              initialValue: user.email,
                              decoration: kTextFieldDecorationForWhiteBackground
                                  .copyWith(
                                      labelText: "Email Address",
                                      filled: true,
                                      fillColor: Color(0x10000000)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              onChanged: (val) {
                                setState(() {
                                  bio = val;
                                });
                              },
                              decoration: kTextFieldDecorationForWhiteBackground
                                  .copyWith(
                                      labelText: "Bio",
                                      hintText:
                                          "Something interesting about you..."),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                error,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                            ),
                            RaisedButton(
                              child: Text("Create profile"),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() => loading = true);
                                  final QuerySnapshot existingUsernames =
                                      await userRef
                                          .where("username",
                                              isEqualTo: username)
                                          .getDocuments();
                                  if (existingUsernames.documents.length == 0) {
                                    //the username is unique and not taken by anyone els
                                    final user = widget.user;
                                    widget.userRef.document(user.uid).setData({
                                      "id": user.uid,
                                      "username": username,
                                      "email": user.email,
                                      "displayName": displayName != null
                                          ? displayName
                                          : user.displayName,
                                      "photoURL": user.photoUrl != null
                                          ? user.photoUrl
                                          : "https://wordypix.co.uk/wp-content/uploads/2015/12/profile.jpg",
                                      "timestamp": DateTime.now(),
                                      "bio": bio != null
                                          ? bio
                                          : "Edit me with something interesting",
                                    });
                                    widget.accountHasBeenCreated(user.uid);
                                  } else {
                                    setState(() {
                                      loading = false;
                                      error =
                                          "Username already taken, try again";
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
