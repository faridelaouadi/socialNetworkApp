import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String photoURL;
  final String bio;

  User(
      {this.displayName,
      this.email,
      this.username,
      this.bio,
      this.id,
      this.photoURL});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc["id"],
      username: doc["username"],
      email: doc["email"],
      displayName: doc["displayName"],
      photoURL: doc["photoURL"],
      bio: doc["bio"],
    );
  }
}
