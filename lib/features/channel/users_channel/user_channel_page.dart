import 'package:flutter/material.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tubetube/features/Provider/channel_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return ref.watch(anyUserDataProvider(widget.userId)).when(
                    data: (user) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset("assets/images/flutter background.png"),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: CachedNetworkImageProvider(user.profilePic),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.displayName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(user.username, style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                                  Text("${user.subscriptions.length} Đăng ký - ${user.videos} Video")
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FlatButton(text: "Đăng Ký", onPressed: () {}, colour: Colors.black),
                        ),
                        TabBar(
                          tabs: [
                            Tab(text: 'Videos'),
                            Tab(text: 'Short Video'),
                          ],
                        ),
                      ],
                    ),
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
                        return ref.watch(earchChannelVideosProvider(widget.userId)).when(
                          data: (videos) => ListView.builder(
                            itemCount: videos.length,
                            itemBuilder: (context, index) => Post(video: videos[index]),
                          ),
                          error: (error, stackTrace) => const ErrorPage(),
                          loading: () => const Loader(),
                        );
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        return ref.watch(eachChannelShortVideosProvider(widget.userId)).when(
                          data: (shorts) => ListView.builder(
                            itemCount: shorts.length,
                            itemBuilder: (context, index) => ShortPost(video: shorts[index]),
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
