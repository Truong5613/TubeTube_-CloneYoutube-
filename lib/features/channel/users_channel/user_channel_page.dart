import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:tubetube/features/Provider&Repository/channel_provider.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/Provider&Repository/subcribe_respository.dart';
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
                        // StreamBuilder for videos collection
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('videos')
                              .where('userId', isEqualTo: widget.userId)
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
                                  .where('userId', isEqualTo: widget.userId)
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
                    Consumer(
                      builder: (context, ref, child) {
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('videos')
                              .where('userId', isEqualTo: widget.userId) // Assuming the video collection is filtered by userId
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
                    Consumer(
                      builder: (context, ref, child) {
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('shorts')
                              .where('userId', isEqualTo: widget.userId) // Assuming the video collection is filtered by userId
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
