import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta/pages/post_screen.dart';
import 'package:insta/pages/profile.dart';
import 'package:insta/pages/wrapper.dart';
import 'package:insta/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  Future userNotifications;

  @override
  void initState() {
    super.initState();
    userNotifications = getActivityFeed();
  }

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy("timeStamp", descending: true)
        .limit(10)
        .getDocuments();
    List<ActivityFeedItem> activityFeed = [];
    snapshot.documents.forEach((doc) {
      activityFeed.add(ActivityFeedItem.fromDocument(doc));
    });
    return activityFeed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(titleText: "Activity feed", isAppTitle: false),
        body: Container(
          child: FutureBuilder(
            future: userNotifications,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: const EdgeInsets.all(8),
                children: snapshot.data,
              );
            },
          ),
        ));
  }
}

Widget mediaPreview;
String activityItemText;

showProfile(BuildContext context, {String profileID}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Profile(
                profileID: profileID,
              )));
}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userID;
  final String type;
  final String mediaURL;
  final String postID;
  final String userProfileImg;
  final String commentData;
  final DateTime timeStamp;

  ActivityFeedItem(
      {this.mediaURL,
      this.postID,
      this.username,
      this.timeStamp,
      this.commentData,
      this.type,
      this.userID,
      this.userProfileImg});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc["username"],
      userID: doc["userID"],
      userProfileImg: doc["userProfileImg"],
      type: doc["type"],
      timeStamp: doc["timeStamp"].toDate(),
      commentData: doc["commentData"],
      mediaURL: doc["mediaURL"],
      postID: doc["postID"],
    );
  }

  showPost(context) {
    print("user ID is $userID");
    print("Post id is $postID");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postID: postID,
                  userID: currentUser.id,
                )));
  }

  configureMediaPreview(context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(mediaURL),
              )),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == "like") {
      activityItemText = " liked your post";
    } else if (type == "follow") {
      activityItemText = " is following you";
    } else if (type == "comment") {
      activityItemText = " commented : $commentData";
    } else {
      activityItemText = "Error, unknown type : $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileID: userID),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                        text: username,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " $activityItemText")
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(timeago.format(timeStamp)),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
