import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta/models/user.dart';
import 'package:insta/pages/wrapper.dart';
import 'package:insta/widgets/custom_image.dart';
import 'package:insta/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postID;
  final String ownerID;
  final String username;
  final String location;
  final String description;
  final String mediaURL;
  final dynamic likes;

  Post({
    this.postID,
    this.ownerID,
    this.username,
    this.location,
    this.description,
    this.mediaURL,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postID: doc['postID'],
      ownerID: doc['ownerID'],
      username: doc['username'],
      location: doc['location'],
      description: doc['caption'],
      mediaURL: doc['mediaURL'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postID: this.postID,
        ownerID: this.ownerID,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaURL: this.mediaURL,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserID = currentUser?.id;
  final String postID;
  final String ownerID;
  final String username;
  final String location;
  final String description;
  final String mediaURL;
  int likeCount;
  Map likes;
  bool alreadyLiked;
  bool showHeart = false;

  _PostState({
    this.postID,
    this.ownerID,
    this.username,
    this.location,
    this.description,
    this.mediaURL,
    this.likes,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    alreadyLiked = likes[currentUserID] == true;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.document(ownerID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoURL),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print("show the user profile"),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
        );
      },
    );
  }

  handleLike() {
    alreadyLiked = likes[currentUserID] == true;
    if (alreadyLiked) {
      postsRef
          .document(ownerID)
          .collection("userPosts")
          .document(postID)
          .updateData({'likes.$currentUserID': false});
      setState(() {
        likeCount -= 1;
        alreadyLiked = false;
        likes[currentUserID] = false;
      });
    } else {
      postsRef
          .document(ownerID)
          .collection("userPosts")
          .document(postID)
          .updateData({'likes.$currentUserID': true});
      setState(() {
        likeCount += 1;
        alreadyLiked = true;
        likes[currentUserID] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLike,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaURL),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 400),
                  tween: Tween(begin: 0.8, end: 1.3),
                  curve: Curves.bounceOut,
                  cycles: 0,
                  builder: (context, animatorState, child) => Transform.scale(
                    scale: animatorState.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.redAccent,
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
            ),
            GestureDetector(
              child: Icon(
                alreadyLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
              onTap: handleLike,
            ),
            Padding(
              padding: EdgeInsets.only(top: 40, right: 20),
            ),
            GestureDetector(
              child: Icon(
                Icons.chat,
                size: 28,
                color: Colors.blue,
              ),
              onTap: () => print("Show the comments!"),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, right: 10),
              child: Text(
                "$username",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(description),
            )
          ],
        ),
      ],
    );
  }
}
