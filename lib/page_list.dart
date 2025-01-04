import 'package:flutter/material.dart';
import 'package:tubetube/features/Search/pages/search_screen.dart';
import 'package:tubetube/features/auth/pages/logout_page.dart';
import 'package:tubetube/features/content/Long_video/long_video_screen.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_page.dart';

List pages = const [
  LongVideoScreen(),
  ShortVideoPage(),
  Center(
    child: Text("Upload"),
  ),
  SearchScreen(),
  LogoutPage(),
];
