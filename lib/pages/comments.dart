import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'wrapper.dart';

class Comments extends StatefulWidget {
  final String postID;
  final String postOwnerID;
  final String postMediaURL;

  Comments({this.postID, this.postMediaURL, this.postOwnerID});

  @override
  CommentsState createState() => CommentsState(
      postID: this.postID,
      postMediaURL: this.postMediaURL,
      postOwnerID: this.postOwnerID);
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postID;
  final String postOwnerID;
  final String postMediaURL;

  CommentsState({this.postID, this.postMediaURL, this.postOwnerID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments..."),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text("Post"),
            ),
          )
        ],
      ),
    );
  }

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .document(postID)
          .collection('comments')
          .orderBy("timeStamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(children: comments);
      },
    );
  }

  void addComment() {
    commentsRef.document(postID).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timeStamp": DateTime.now(),
      "avatarURL": currentUser.photoURL,
      "userID": currentUser.id,
    });
    if (postOwnerID == currentUser.id) {
      activityFeedRef.document(postOwnerID).collection("feedItems").add({
        "type": "comment",
        "commentData": commentController.text,
        "username": currentUser.username,
        "userID": currentUser.id,
        "userProfileImg": currentUser.photoURL,
        "postID": postID,
        "mediaURL": postMediaURL,
        "timeStamp": DateTime.now()
      });
    }
    commentController.clear();
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userID;
  final String avatarURL;
  final String comment;
  final DateTime timeStamp;

  Comment(
      {this.username,
      this.userID,
      this.avatarURL,
      this.comment,
      this.timeStamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userID: doc['userID'],
      avatarURL: doc['avatarURL'],
      comment: doc['comment'],
      timeStamp: doc['timeStamp'].toDate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
            title: Text(
              comment,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            //title: Text(comment),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatarURL),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 3),
                Text(username),
                SizedBox(height: 3),
                Text(timeago.format(timeStamp)),
              ],
            )
            //subtitle: Text(timeago.format(timeStamp)),
            ),
        Divider(),
      ],
    );
  }
}
