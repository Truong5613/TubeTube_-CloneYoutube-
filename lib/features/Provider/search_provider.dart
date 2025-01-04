import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tubetube/features/Model/video_model.dart';

final allChannelsProvider = Provider((ref) async {
  final usersMap = await FirebaseFirestore.instance.collection('users').get();
  List<UserModel> users = usersMap.docs
      .map(
        (user) => UserModel.fromMap(
          user.data(),
        ),
      )
      .toList();
  return users;
});

final allVideoProvider = Provider((ref) async {
  final videosMap = await FirebaseFirestore.instance.collection('videos').get();
  List<VideoModel> videos = videosMap.docs
      .map(
        (user) => VideoModel.fromMap(
          user.data(),
        ),
      )
      .toList();
  return videos;
});
