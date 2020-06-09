import 'package:flutter/material.dart';
import 'package:insta/pages/wrapper.dart';
import 'package:insta/widgets/post.dart';

class PostScreen extends StatelessWidget {
  final String userID;
  final String postID;

  PostScreen({this.postID, this.userID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(userID)
          .collection('userPosts')
          .document(postID)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: AppBar(title: Text(post.description)),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
