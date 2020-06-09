import 'package:flutter/material.dart';
import 'package:insta/pages/post_screen.dart';
import 'package:insta/widgets/custom_image.dart';
import 'package:insta/widgets/post.dart';

class PostTile extends StatelessWidget {
  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postID: post.postID,
                  userID: post.ownerID,
                )));
  }

  final Post post;
  PostTile({this.post});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaURL),
    );
  }
}
