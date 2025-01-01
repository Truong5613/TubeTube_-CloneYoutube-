import 'package:flutter/material.dart';
import 'package:tubetube/features/content/Long_video/long_video_screen.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_page.dart';

List pages = [
  LongVideoScreen(),
  ShortVideoPage(),
  Center(
    child: Text("Upload"),
  ),
  Center(
    child: Text("Home"),
  ),
  Center(
    child: Text("Home"),
  ),
];
