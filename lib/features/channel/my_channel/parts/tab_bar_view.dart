import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:tubetube/features/Provider&Repository/channel_provider.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/content/Long_video/parts/post.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_post.dart';

class TabPages extends ConsumerStatefulWidget {
  final String Userid;

  const TabPages({super.key, required this.Userid});

  @override
  _TabPagesState createState() => _TabPagesState();
}

class _TabPagesState extends ConsumerState<TabPages> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
          // Combined Video and Short Video
          Consumer(
            builder: (context, ref, child) {
              // StreamBuilder for videos collection
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('videos')
                    .where('userId', isEqualTo: widget.Userid)
                    .snapshots(),
                builder: (context, videoSnapshot) {
                  if (videoSnapshot.connectionState == ConnectionState.waiting) {
                    return const Loader(); // Show loader while videos data is being fetched
                  }

                  if (videoSnapshot.hasError) {
                    return const ErrorPage(); // Handle errors when fetching videos
                  }

                  if (!videoSnapshot.hasData || videoSnapshot.data == null) {
                    return const ErrorPage(); // Handle empty data for videos
                  }

                  final videoMaps = videoSnapshot.data!.docs;
                  final videos = videoMaps.map((video) {
                    return VideoModel.fromMap(video.data()); // Convert Firestore doc to VideoModel
                  }).toList();

                  // StreamBuilder for shorts collection
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('shorts')
                        .where('userId', isEqualTo: widget.Userid)
                        .snapshots(),
                    builder: (context, shortSnapshot) {
                      if (shortSnapshot.connectionState == ConnectionState.waiting) {
                        return const Loader(); // Show loader while shorts data is being fetched
                      }

                      if (shortSnapshot.hasError) {
                        return const ErrorPage(); // Handle errors when fetching shorts
                      }

                      if (!shortSnapshot.hasData || shortSnapshot.data == null) {
                        return const ErrorPage(); // Handle empty data for shorts
                      }

                      final shortMaps = shortSnapshot.data!.docs;
                      final shorts = shortMaps.map((shortVideo) {
                        return ShortVideoModel.fromMap(shortVideo.data()); // Convert Firestore doc to ShortVideoModel
                      }).toList();

                      // Combine and shuffle videos and shorts
                      final combinedData = [...videos, ...shorts];
                      combinedData.shuffle();

                      // Return ListView.builder to display both videos and shorts
                      return ListView.builder(
                        itemCount: combinedData.length,
                        itemBuilder: (context, index) {
                          final item = combinedData[index];

                          if (item is VideoModel) {
                            return Post(video: item); // Show Post for VideoModel
                          }

                          if (item is ShortVideoModel) {
                            return ShortPost(video: item); // Show ShortPost for ShortVideoModel
                          }

                          return const SizedBox(); // Fallback for unsupported types
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          // Video
          Consumer(
            builder: (context, ref, child) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('videos')
                    .where('userId', isEqualTo: widget.Userid) // Assuming the video collection is filtered by userId
                    .snapshots(), // Listen for changes in the collection
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader(); // Show loader while data is being fetched
                  }

                  if (snapshot.hasError) {
                    return const ErrorPage(); // Handle errors
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const ErrorPage(); // Handle empty data
                  }

                  final videoMaps = snapshot.data!.docs;
                  final videos = videoMaps.map((video) {
                    return VideoModel.fromMap(video.data()); // Convert Firestore document to VideoModel
                  }).toList();

                  return ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return Post(video: videos[index]); // Return the Post widget for each video
                    },
                  );
                },
              );
            },
          ),


          // Short Video
          Consumer(
            builder: (context, ref, child) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('shorts')
                    .where('userId', isEqualTo: widget.Userid) // Assuming the video collection is filtered by userId
                    .snapshots(), // Listen for changes in the collection
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader(); // Show loader while data is being fetched
                  }

                  if (snapshot.hasError) {
                    return const ErrorPage(); // Handle errors
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const ErrorPage(); // Handle empty data
                  }

                  final ShortvideoMaps = snapshot.data!.docs;
                  final shortvideos = ShortvideoMaps.map((shortVideo) {
                    return ShortVideoModel.fromMap(shortVideo.data()); // Convert Firestore document to VideoModel
                  }).toList();

                  return ListView.builder(
                    itemCount: shortvideos.length, // Danh sách các video
                    itemBuilder: (context, index) {
                      final video = shortvideos[index]; // Lấy video ở vị trí index
                      return ShortPost(
                        key: ValueKey(video.shortvideoId), // Đảm bảo Key duy nhất cho mỗi video
                        video: video,
                      );
                    },
                  );
                },
              );
            },
          ),

          // User Description
          Consumer(
            builder: (context, ref, child) {
              return ref.watch(anyUserDataProvider(widget.Userid)).when(
                data: (user) => Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mô Tả:",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.description.isEmpty ? "Không có mô tả" : user.description,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stackTrace) => const ErrorPage(),
                loading: () => const Loader(),
              );
            },
          ),
        ],
      ),
    );
  }
}
