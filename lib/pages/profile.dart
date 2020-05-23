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
  bool isLoading = false;
  int postCount;
  List<Post> posts = [];
  String postOrientation = "Grid";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePosts();
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
    final AuthService _auth = AuthService(context: context);
    return Scaffold(
        appBar: header(
          isAppTitle: false,
          titleText: currentUser.username,
          trailing: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: Icon(Icons.exit_to_app),
                color: Colors.black,
                onPressed: () => _auth.signOut(),
              ),
            ),
          ],
          onPress: _auth.signOut,
        ),
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
                            buildCountColumn("followers", 0),
                            buildCountColumn("following", 0),
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
      //i am viweing my own profile
      return buildButton(text: "Edit Profile", function: editProfile);
    } else {
      //i am viewing someone else's profile
    }
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.blue),
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
