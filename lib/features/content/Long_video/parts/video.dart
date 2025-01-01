// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:tubetube/cores/colors.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:tubetube/cores/widgets/long_video/video_externel_buttons.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/auth/provider/user_provider.dart';
import 'package:tubetube/features/content/Long_video/parts/post.dart';
import 'package:tubetube/features/content/comment/comment_sheet.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:video_player/video_player.dart';

class Video extends ConsumerStatefulWidget {
  final VideoModel video;

  const Video({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  ConsumerState<Video> createState() => _VideoState();
}

class _VideoState extends ConsumerState<Video> {
  bool isShowIcons = true;
  bool isPlaying = false;
  VideoPlayerController? _controller;

  @override
  void initState() {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    )..initialize().then((_) {
        setState(() {});
      });
  }

  toggleVideoPlayer() {
    if (_controller!.value.isPlaying) {
      //Tam dung video
      _controller!.pause();
      isPlaying = false;
      setState(() {});
    } else {
      //Tiep Tuc Video
      _controller!.play();
      isPlaying = true;
      setState(() {});
    }
  }

  goBackward() {
    Duration position = _controller!.value.position;
    position = position - Duration(seconds: 1);
    _controller!.seekTo(position);
  }

  goForward() {
    Duration position = _controller!.value.position;
    position = position + Duration(seconds: 1);
    _controller!.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserModel> user =
        ref.watch(anyUserDataProvider(widget.video.userId));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(176),
          child: _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: GestureDetector(
                    onTap: isShowIcons
                        ? () {
                            isShowIcons = false;
                            setState(() {});
                          }
                        : () {
                            isShowIcons = true;
                            setState(() {});
                          },
                    child: Stack(
                      children: [
                        VideoPlayer(_controller!),
                        isShowIcons
                            ? Positioned(
                                left: 182,
                                top: 87,
                                child: GestureDetector(
                                  onTap: () {
                                    toggleVideoPlayer();
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/play.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        isShowIcons
                            ? Positioned(
                                left: 55,
                                top: 87,
                                child: GestureDetector(
                                  onTap: () {
                                    goBackward();
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/go_back_final.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        isShowIcons
                            ? Positioned(
                                right: 55,
                                top: 87,
                                child: GestureDetector(
                                  onTap: () {
                                    goForward();
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/go_ahead_final.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        isShowIcons
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: 10,
                                  child: VideoProgressIndicator(
                                    _controller!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: Colors.red,
                                      bufferedColor: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(bottom: 100),
                  child: CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 4,
                  ),
                ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 10),
              child: Text(
                widget.video.title,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7, top: 5),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Text(
                      widget.video.views == 0
                          ? "No view"
                          : "${widget.video.views} views",
                      style: const TextStyle(
                        fontSize: 13.4,
                        color: Color(0xff5F5F5F),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 8),
                    child: Text(
                      timeago.format(widget.video.datePublished, locale: 'vi'),
                      style: const TextStyle(
                        fontSize: 13.4,
                        color: Color(0xff5F5F5F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                top: 9,
                right: 9,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        CachedNetworkImageProvider(user.value!.profilePic),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 5,
                    ),
                    child: Text(
                      user.value!.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5, left: 5),
                    child: Text(
                      user.value!.subscriptions.isEmpty
                          ? "0 Subcriptions"
                          : "${user.value!.subscriptions.length} subcriptions",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 35,
                    width: 100,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FlatButton(
                        text: "Subscribe",
                        onPressed: () {},
                        colour: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9, top: 10.5, right: 9),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        color: softBlueGreyBackGround,
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.thumb_up,
                              size: 15.5,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Icon(
                            Icons.thumb_down,
                            size: 15.5,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 9, right: 9),
                      child: VideoExtraButton(
                        text: "Share",
                        iconData: Icons.share,
                      ),
                    ),
                    const VideoExtraButton(
                      text: "Remix",
                      iconData: Icons.analytics_outlined,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 9, right: 9),
                      child: VideoExtraButton(
                        text: "Download",
                        iconData: Icons.download,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Khu Binh Luan
            GestureDetector(
              onTap: () {
                // Hiển thị CommentSheet
                showModalBottomSheet(
                  context: context,
                  builder: (context) => CommentSheet(video: widget.video),
                );
              },
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bình Luận",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              backgroundImage: CachedNetworkImageProvider(
                                user.value!.profilePic,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  "Viết bình luận...",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("videos")
                    .where("videoId", isNotEqualTo: widget.video.videoId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return ErrorPage();
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Loader();
                  }

                  final videosMap = snapshot.data!.docs;
                  final videos = videosMap
                      .map(
                        (video) => VideoModel.fromMap(video.data()),
                      )
                      .toList();
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return Post(
                        video: videos[index],
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
