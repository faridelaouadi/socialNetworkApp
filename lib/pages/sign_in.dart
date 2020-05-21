import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta/widgets/loading.dart';

import '../auth.dart';
import '../constants.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  String error = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService(context: context);
    return loading
        ? Loading()
        : Scaffold(
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor,
                    Color(0xff002aff)
                  ])),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Instagram",
                    style: TextStyle(
                      fontFamily: "Billabong",
                      fontSize: 90,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(50, 20, 50, 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            validator: (val) =>
                                val.isEmpty ? "Enter an email" : null,
                            decoration: kTextFieldDecorationForRainbowBackground
                                .copyWith(labelText: "Email Address"),
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                          ), //Text field for email
                          SizedBox(height: 20),
                          TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            validator: (val) =>
                                val.isEmpty ? "Enter a password" : null,
                            decoration: kTextFieldDecorationForRainbowBackground
                                .copyWith(labelText: "Password"),
                            obscureText: true,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                          ), //text field for password
                          SizedBox(height: 20),
                          Text(error),
                          SizedBox(height: 10),
                          RaisedButton(
                            padding: EdgeInsets.all(10),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.white,
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                fontFamily: "Billabong",
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                bool result = await _auth.signInEmailPassword(
                                    email, password);
                                if (result == false) {
                                  setState(() {
                                    loading = false;
                                    error =
                                        "Credentials were wrong, please try again!";
                                  });
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () async {
                              dynamic authResult =
                                  await _auth.signInWithGoogle();
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "https://cdn.clipart.email/bc499919aa4b64cdabaa262186b3aa86_google-logo-background-png-download-10241024-free-transparent-_900-900.jpeg"),
                            )),
                        GestureDetector(
                            onTap: () async {
                              dynamic authResult =
                                  await _auth.signInWithFacebook();
                              if (authResult) {
                                print(
                                    "User has signed into facebook so the firebase user should change aswell. ");
                              }
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "https://facebookbrand.com/wp-content/uploads/2019/04/f_logo_RGB-Hex-Blue_512.png?w=512&h=512"),
                            )),
                      ],
                    ),
                  ),
                  RaisedButton(
                      padding: EdgeInsets.all(10),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.white,
                      child: Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        widget.toggleView();
                      })
                ],
              ),
            ),
          );
  }
}
