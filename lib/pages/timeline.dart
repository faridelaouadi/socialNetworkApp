import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta/widgets/header.dart';
import 'package:insta/widgets/progress.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(isAppTitle: true),
      body: circularProgress(),
    );
  }
}
