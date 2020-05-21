import 'package:flutter/material.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Access Camera",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
