import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/content/short_video/pages/Short_video_tile.dart';

class ShortVideoPage extends StatelessWidget {
  final String? shortVideoId;  // Optional parameter for shortVideoId
  const ShortVideoPage({super.key, this.shortVideoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("shorts").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null || !snapshot.hasData) {
              return const ErrorPage();
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }

            var shortVideoMaps = snapshot.data!.docs;

            // Tạo một danh sách mới để chứa video hợp lệ
            List<dynamic> validShortVideos = [];

            // If a shortVideoId is provided, find that video in the collection
            if (shortVideoId != null) {
              final shortVideoIndex = shortVideoMaps.indexWhere(
                      (doc) => doc['shortvideoId'] == shortVideoId);

              if (shortVideoIndex != -1) {
                // Move the found video to the top of the list
                final shortVideo = shortVideoMaps.removeAt(shortVideoIndex);
                shortVideoMaps.insert(0, shortVideo);
              }
            }

            // Duyệt qua danh sách và chỉ thêm các video hợp lệ vào danh sách mới
            for (var doc in shortVideoMaps) {
              ShortVideoModel shortVideo = ShortVideoModel.fromMap(doc.data());

              if (!(shortVideo.isHidden || shortVideo.isBanned)) {
                validShortVideos.add(doc); // Thêm video hợp lệ vào danh sách mới
              }
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: validShortVideos.length,
              itemBuilder: (context, index) {
                ShortVideoModel shortVideo =
                ShortVideoModel.fromMap(validShortVideos[index].data());
                return ShortVideoTile(shortVideo: shortVideo);
              },
            );
          },
        ),
      ),

    );
  }
}
