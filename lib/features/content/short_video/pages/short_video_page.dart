import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/content/short_video/pages/Short_video_tile.dart';

class ShortVideoPage extends StatelessWidget {
  const ShortVideoPage({super.key});

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

            final shortVideoMaps = snapshot.data!.docs;

            return PageView.builder(
              scrollDirection: Axis.vertical, // Vuốt theo chiều dọc
              itemCount: shortVideoMaps.length,
              itemBuilder: (context, index) {
                ShortVideoModel shortVideo =
                ShortVideoModel.fromMap(shortVideoMaps[index].data());
                return ShortVideoTile(shortVideo: shortVideo);
              },
            );
          },
        ),
      ),
    );
  }
}
