import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta/models/user.dart';
import 'package:insta/pages/edit_profile.dart';
import 'package:insta/widgets/header.dart';
import 'package:insta/auth.dart';
import 'package:insta/widgets/post.dart';
import 'package:insta/widgets/post_tile.dart';
import 'package:insta/widgets/progress.dart';
import 'wrapper.dart';

class Profile extends StatefulWidget {
  final String profileID;

  Profile({this.profileID});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  bool isLoading = false;
  int postCount;
  int followersCount;
  int followingCount;
  List<Post> posts = [];
  String postOrientation = "Grid";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkFollowing();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileID)
        .collection("userFollowers")
        .getDocuments();
    setState(() {
      followersCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileID)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  checkFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileID)
        .collection("userFollowers")
        .document(currentUser.id)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  void getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileID)
        .collection("userPosts")
        .orderBy('timeStamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: header(
//          isAppTitle: false,
//          titleText: currentUser.username,
//          trailing: [
//            Padding(
//              padding: const EdgeInsets.only(right: 20.0),
//              child: IconButton(
//                icon: Icon(Icons.exit_to_app),
//                color: Colors.black,
//                onPressed: () => _auth.signOut(),
//              ),
//            ),
//          ],
//          onPress: _auth.signOut,
//        ),
        body: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(
            height: 0.0,
          ),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    ));
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.document(widget.profileID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Text(
                user.username,
                style: TextStyle(fontSize: 20),
              ),
              Divider(
                color: Colors.black,
                height: 40,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(user.photoURL),
                    backgroundColor: Colors.grey,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn(
                                "posts", postCount != null ? postCount : 0),
                            buildCountColumn("followers", followersCount),
                            buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[buildProfileButton()],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  user.username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }

  buildProfileButton() {
    if (currentUser.id == widget.profileID) {
      return buildButton(text: "Settings", function: editProfile);
    } else if (isFollowing) {
      //i am viewing someone else's profile
      return buildButton(text: "Unfollow", function: handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton(text: "Follow", function: handleFollowUser);
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // make authenticated user a follower of the other user (update their followers)
    followersRef
        .document(widget.profileID)
        .collection("userFollowers")
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //put other user in our following (update my following)
    followingRef
        .document(currentUser.id)
        .collection("userFollowing")
        .document(widget.profileID)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //add activity feed item for that user to notify them taht we are following them
    activityFeedRef
        .document(widget.profileID)
        .collection("feedItems")
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // make authenticated user a follower of the other user (update their followers)
    followersRef
        .document(widget.profileID)
        .collection("userFollowers")
        .document(currentUser.id)
        .setData({});
    //put other user in our following (update my following)
    followingRef
        .document(currentUser.id)
        .collection("userFollowing")
        .document(widget.profileID)
        .setData({});
    //add activity feed item for that user to notify them taht we are following them
    activityFeedRef
        .document(widget.profileID)
        .collection("feedItems")
        .document(currentUser.id)
        .setData({
      "type": "follow",
      "ownerID": widget.profileID,
      "username": currentUser.username,
      "userID": currentUser.id,
      "userProfileImg": currentUser.photoURL,
      "timeStamp": DateTime.now(),
    });
  }

  buildButton({
    String text,
    Function function,
  }) {
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border:
                  Border.all(color: isFollowing ? Colors.grey : Colors.blue),
              borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserID: currentUser.id)));
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
    if (posts.isEmpty) {
      return Center(
          child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Text(
                "No posts...",
                style: TextStyle(fontSize: 20),
              )));
    }
    if (postOrientation == "Grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(
          child: PostTile(
            post: post,
          ),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else {
      return Column(
        children: posts,
      );
    }
  }

  toggleOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => toggleOrientation("Grid"),
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == "Grid" ? Colors.blue : Colors.grey,
          ),
        ),
        IconButton(
          onPressed: () => toggleOrientation("List"),
          icon: Icon(
            Icons.list,
            color: postOrientation == "List" ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}
