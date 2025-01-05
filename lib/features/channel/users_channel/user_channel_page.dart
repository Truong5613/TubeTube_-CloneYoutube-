import 'package:flutter/material.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:tubetube/features/Provider/channel_provider.dart';
import 'package:tubetube/features/Repository/subcribe_respository.dart';
import 'package:tubetube/features/auth/provider/user_provider.dart';
import 'package:tubetube/features/content/Long_video/parts/post.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_post.dart';

class UserChannelPage extends StatefulWidget {
  final String userId;

  const UserChannelPage({super.key, required this.userId});

  @override
  State<UserChannelPage> createState() => _UserChannelPageState();
}

class _UserChannelPageState extends State<UserChannelPage> {
  bool isSubscribed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return ref.watch(anyUserDataProvider(widget.userId)).when(
                        data: (user) {
                          // Kiểm tra trạng thái đăng ký của người dùng
                          isSubscribed = user.subscriptions.contains(
                            ref
                                    .watch(currentUserProvider)
                                    .asData
                                    ?.value
                                    .userId ??
                                '',
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                  "assets/images/flutter background.png"),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              user.profilePic),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user.displayName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text(user.username,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blueGrey)),
                                        Text(
                                            "${user.subscriptions.length} Đăng ký - ${user.videos} Video")
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: FlatButton(
                                  text: isSubscribed ? "Đã Đăng Ký" : "Đăng Ký",
                                  onPressed: () async {
                                    final userId = ref
                                        .watch(currentUserProvider)
                                        .asData
                                        ?.value
                                        .userId;

                                    if (userId != null) {
                                      // Nếu đã đăng ký, thực hiện hủy đăng ký
                                      if (isSubscribed) {
                                        await ref
                                            .watch(subscribeChannelProvider)
                                            .unsubscribeChannel(
                                              userId: widget.userId,
                                              currentUserId: userId,
                                              subscriptions: user.subscriptions,
                                              ref: ref,
                                            );
                                      }
                                      // Nếu chưa đăng ký, thực hiện đăng ký
                                      else {
                                        await ref
                                            .watch(subscribeChannelProvider)
                                            .subscribeChannel(
                                              userId: widget.userId,
                                              currentUserId: userId,
                                              subscriptions: user.subscriptions,
                                              ref: ref,
                                            );
                                      }

                                      // Cập nhật trạng thái và giao diện
                                      setState(() {
                                        isSubscribed = !isSubscribed;
                                      });
                                    }
                                  },
                                  colour:
                                      isSubscribed ? Colors.grey : Colors.red,
                                ),
                              ),
                              const TabBar(
                                tabs: [
                                  Tab(text: 'Home'),
                                  Tab(text: 'Videos'),
                                  Tab(text: 'Short Video'),
                                  Tab(text: 'About'),
                                ],
                              ),
                            ],
                          );
                        },
                        error: (error, stackTrace) => const ErrorPage(),
                        loading: () => const Loader(),
                      );
                },
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final videos = ref
                            .watch(earchChannelVideosProvider(widget.userId));
                        final shorts = ref.watch(
                            eachChannelShortVideosProvider(widget.userId));

                        return videos.when(
                          data: (videoData) {
                            return shorts.when(
                              data: (shortData) {
                                // Combine both video and short data in one list
                                final combinedData = [
                                  ...videoData,
                                  ...shortData
                                ];
                                // Sort combined data by a specific property (e.g., 'createdAt' or 'timestamp')
                                combinedData.shuffle();
                                return ListView.builder(
                                  itemCount: combinedData.length,
                                  itemBuilder: (context, index) {
                                    final item = combinedData[index];

                                    if (item is VideoModel &&
                                        item.type == 'video') {
                                      return Post(video: item);
                                    }

                                    // Handle short type separately
                                    if (item is ShortVideoModel &&
                                        item.type == 'short') {
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
                    Consumer(
                      builder: (context, ref, child) {
                        return ref
                            .watch(earchChannelVideosProvider(widget.userId))
                            .when(
                              data: (videos) => ListView.builder(
                                itemCount: videos.length,
                                itemBuilder: (context, index) =>
                                    Post(video: videos[index]),
                              ),
                              error: (error, stackTrace) => const ErrorPage(),
                              loading: () => const Loader(),
                            );
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        return ref
                            .watch(
                                eachChannelShortVideosProvider(widget.userId))
                            .when(
                              data: (shorts) => ListView.builder(
                                itemCount: shorts.length, // Danh sách các video
                                itemBuilder: (context, index) {
                                  final video = shorts[index]; // Lấy video ở vị trí index
                                  return ShortPost(
                                    key: ValueKey(video.shortvideoId), // Đảm bảo Key duy nhất cho mỗi video
                                    video: video,
                                  );
                                },
                              ),
                              error: (error, stackTrace) => const ErrorPage(),
                              loading: () => const Loader(),
                            );
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        return ref
                            .watch(anyUserDataProvider(widget.userId))
                            .when(
                              data: (user) => Padding(
                                padding: const EdgeInsets.only(top: 20,left: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Mô Tả:",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                                    Text(
                                      user.description.isEmpty ? "Không có mô tả" :user.description,
                                      style: TextStyle(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
