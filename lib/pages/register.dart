import 'package:flutter/material.dart';
import 'package:insta/widgets/loading.dart';
import '../auth.dart';
import '../constants.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
                    margin: EdgeInsets.fromLTRB(50, 5, 50, 30),
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
                                val.isEmpty ? "Don't leave it empty" : null,
                            decoration: kTextFieldDecorationForRainbowBackground
                                .copyWith(labelText: "Email Address"),
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            validator: (val) => val.length < 6
                                ? "Password needs to be atleast 6 chars"
                                : null,
                            decoration: kTextFieldDecorationForRainbowBackground
                                .copyWith(labelText: "Password"),
                            obscureText: true,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            validator: (val) => val != password
                                ? "Passwords needs to match"
                                : null,
                            decoration: kTextFieldDecorationForRainbowBackground
                                .copyWith(labelText: "Confirm Password"),
                            obscureText: true,
                          ),
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
                              "Register",
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
                                bool result = await _auth.registerEmailPassword(
                                    email, password);
                                if (result == false) {
                                  setState(() {
                                    error =
                                        "Registration failed... please try again.";
                                    loading = false;
                                  });
                                }
                              }
                            },
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          RaisedButton(
                            padding: EdgeInsets.all(10),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.white,
                            child: Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () => widget.toggleView(),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
