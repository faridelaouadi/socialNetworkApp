import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta/models/user.dart';
import 'package:insta/widgets/progress.dart';
import 'wrapper.dart';
import 'activity_feed.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot> searchResultsFuture;

  TextEditingController searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8),
      appBar: buildSearchBar(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }

  buildSearchBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchFieldController,
        decoration: InputDecoration(
          hintText: "Search for a user",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => clearSearch(),
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: 300,
            ),
            Text(
              "Find users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 30,
              ),
            )
          ],
        ),
      ),
    );
  }

  handleSearch(String value) {
    Future<QuerySnapshot> users =
        userRef.where("username", isGreaterThanOrEqualTo: value).getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          searchResults.add(UserResult(user: user));
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  clearSearch() {
    searchFieldController.clear();
    setState(() {
      searchResultsFuture = null;
    });
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult({this.user});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white10,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileID: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoURL),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
