import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:insta/models/user.dart';
import 'package:insta/pages/wrapper.dart';
import 'package:insta/widgets/progress.dart';

import '../auth.dart';

class EditProfile extends StatefulWidget {
  final String currentUserID;

  EditProfile({this.currentUserID});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool bioValid = true;
  bool nameValid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserID).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Edit Profile: ${user.username}",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: isLoading
            ? circularProgress()
            : ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 30, bottom: 8),
                          child: CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoURL),
                            radius: 50,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              buildBioField(),
                            ],
                          ),
                        ),
                        RaisedButton(
                          onPressed: updateProfileData,
                          child: Text(
                            "Update profile",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        RaisedButton(
                          onPressed: logOut,
                          child: Text(
                            "Log Out",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ));
  }

  logOut() {
    final AuthService _auth = AuthService(context: context);
    _auth.signOut();
    Navigator.pop(context);
  }

  buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Display name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
              hintText: "Update display name",
              errorText: nameValid ? null : "Name too short!"),
        )
      ],
    );
  }

  buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
              hintText: "Update Bio",
              errorText: bioValid ? null : "Bio too long!"),
        )
      ],
    );
  }

  void updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? nameValid = false
          : nameValid = true;
      bioController.text.trim().length > 20 || bioController.text.isEmpty
          ? bioValid = false
          : bioValid = true;
    });

    if (nameValid && bioValid) {
      userRef.document(widget.currentUserID).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackBar = SnackBar(
        content: Text("Profile updated..."),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }
}
