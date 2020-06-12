import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta/models/user.dart';
import 'package:insta/pages/comments.dart';
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
        bool isPostOwner = user.id == ownerID;
        print(isPostOwner);
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

  deletePost() async {
    //delete the post from the database
    postsRef
        .document(ownerID)
        .collection("userPosts")
        .document(postID)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //delete the image from storage
    storageRef.child("post_$postID.jpg").delete();
    //delete activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerID)
        .collection("feedItems")
        .where("postID", isEqualTo: postID)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //delete all comments linked with the post
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postID)
        .collection('comments')
        .getDocuments();

    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    Navigator.pop(context);
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                ),
              ),
            ],
          );
        });
  }

  handleLike() {
    alreadyLiked = likes[currentUserID] == true;
    if (alreadyLiked) {
      postsRef
          .document(ownerID)
          .collection("userPosts")
          .document(postID)
          .updateData({'likes.$currentUserID': false});
      removeLikeFromActivityFeed();
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
      addLikeToActivityFeed();
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
              onTap: () => showComments(
                context,
                postID: postID,
                ownerID: ownerID,
                mediaURL: mediaURL,
              ),
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

  showComments(BuildContext context,
      {String postID, String ownerID, String mediaURL}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
          postID: postID, postOwnerID: ownerID, postMediaURL: mediaURL);
    }));
  }

  addLikeToActivityFeed() {
    bool isPostOwner = currentUserID == ownerID;
    if (!isPostOwner) {
      activityFeedRef
          .document(ownerID)
          .collection("feedItems")
          .document(postID)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userID": currentUser.id,
        "userProfileImg": currentUser.photoURL,
        "postID": postID,
        "mediaURL": mediaURL,
        "timeStamp": DateTime.now()
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isPostOwner = currentUserID == ownerID;
    if (!isPostOwner) {
      activityFeedRef
          .document(ownerID)
          .collection("feedItems")
          .document(postID)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }
}
