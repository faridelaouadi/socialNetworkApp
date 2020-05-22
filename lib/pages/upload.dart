import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'wrapper.dart';
import 'package:image/image.dart' as Im;
import 'wrapper.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File _image;
  bool isUploading = false;
  String postID = Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return _image == null ? buildSplashScreen() : buildUploadForm();
  }

  Widget buildSplashScreen() {
    return Container(
      color: Colors.deepOrange.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 260,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Upload image",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              onPressed: () => selectImage(context),
              color: Colors.deepPurple,
            ),
          )
        ],
      ),
    );
  }

  selectImage(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: takePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from gallery"),
                onPressed: chooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  takePhoto() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  chooseFromGallery() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postID.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _image = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postID.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadURL = await storageSnap.ref.getDownloadURL();
    return downloadURL;
  }

  createPostInFirestore({String mediaURL, String location, String caption}) {
    postsRef
        .document(currentUser.id)
        .collection("userPosts")
        .document(postID)
        .setData({
      "postID": postID,
      "ownerID": currentUser.id,
      "username": currentUser.username,
      "mediaURL": mediaURL,
      "caption": caption,
      "timeStamp": DateTime.now(),
      "location": location,
      "likes": {},
    });
  }

  postPicture() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaURL = await uploadImage(_image);
    createPostInFirestore(
        mediaURL: mediaURL,
        location: locationController.text,
        caption: captionController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      _image = null;
      isUploading = false;
      postID = Uuid().v4();
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            onPressed: isUploading ? null : () => postPicture(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_image),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(currentUser.photoURL),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.deepOrange,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use current location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Colors.blue,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedLocation = "${placemark.locality} , ${placemark.country}";
    locationController.text = formattedLocation;
  }
}
