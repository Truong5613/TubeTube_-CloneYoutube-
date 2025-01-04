import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_page.dart';

final earchChannelVideosProvider = FutureProvider.family((ref, userId) async {
  final videosMap = await FirebaseFirestore.instance
      .collection("videos")
      .where("userId", isEqualTo: userId).get();
  final List<VideoModel> videos = videosMap.docs.map((video)=>VideoModel.fromMap(video.data())).toList();
  return videos;
});
final eachChannelShortVideosProvider = FutureProvider.family((ref, userId) async {
  final shortvideosMap = await FirebaseFirestore.instance
      .collection("shorts")
      .where("userId", isEqualTo: userId).get();
  final List<ShortVideoModel> shortvideos = shortvideosMap.docs.map((shortVideo)=>ShortVideoModel.fromMap(shortVideo.data())).toList();
  return shortvideos;
});