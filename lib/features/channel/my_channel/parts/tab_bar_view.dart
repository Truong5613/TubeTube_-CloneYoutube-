import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:tubetube/features/Provider/channel_provider.dart';
import 'package:tubetube/features/content/Long_video/parts/post.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_post.dart';

class TabPages extends StatefulWidget {
  final String Userid;

  const TabPages({super.key, required this.Userid});

  @override
  State<TabPages> createState() => _TabPagesState();
}

class _TabPagesState extends State<TabPages> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final videos =
                  ref.watch(earchChannelVideosProvider(widget.Userid));
              final shorts =
                  ref.watch(eachChannelShortVideosProvider(widget.Userid));

              return videos.when(
                data: (videoData) {
                  return shorts.when(
                    data: (shortData) {
                      // Combine both video and short data in one list
                      final combinedData = [...videoData, ...shortData];
                      // Sort combined data by a specific property (e.g., 'createdAt' or 'timestamp')
                      combinedData.shuffle();
                      return ListView.builder(
                        itemCount: combinedData.length,
                        itemBuilder: (context, index) {
                          final item = combinedData[index];

                          if (item is VideoModel && item.type == 'video') {
                            return Post(video: item);
                          }

                          // Handle short type separately
                          if (item is ShortVideoModel && item.type == 'short') {
                            return ShortPost(video: item);
                          }
                          return const SizedBox(); // Fallback
                        },
                      );
                    },
                    error: (error, stackTrace) => const ErrorPage(),
                    loading: () => const Loader(),
                  );
                },
                error: (error, stackTrace) => const ErrorPage(),
                loading: () => const Loader(),
              );
            },
          ),

          //Video
          Consumer(
            builder: (context, ref, child) {
              return ref.watch(earchChannelVideosProvider(widget.Userid)).when(
                data: (videos) {
                  return ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return Post(video: videos[index]);
                    },
                  );
                },
                error: (error, stackTrace) {
                  return const ErrorPage();
                },
                loading: () {
                  return const Loader();
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              return ref
                  .watch(eachChannelShortVideosProvider(widget.Userid))
                  .when(
                    data: (shorts) => ListView.builder(
                      itemCount: shorts.length,
                      itemBuilder: (context, index) =>
                          ShortPost(video: shorts[index]),
                    ),
                    error: (error, stackTrace) => const ErrorPage(),
                    loading: () => const Loader(),
                  );
            },
          ),
          const Center(
            child: Text("About"),
          ),
        ],
      ),
    );
  }
}
