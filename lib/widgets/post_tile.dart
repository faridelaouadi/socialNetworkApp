import 'package:flutter/material.dart';
import 'package:insta/widgets/custom_image.dart';
import 'package:insta/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("full screen post"),
      child: cachedNetworkImage(post.mediaURL),
    );
  }
}
