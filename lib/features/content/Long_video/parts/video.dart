import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:tubetube/cores/colors.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/Model/comment_model.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/Repository/subcribe_respository.dart';
import 'package:tubetube/features/auth/provider/user_provider.dart';
import 'package:tubetube/features/channel/users_channel/user_channel_page.dart';
import 'package:tubetube/features/content/Long_video/Widget/video_first_comment.dart';
import 'package:tubetube/features/content/Long_video/parts/post.dart';
import 'package:tubetube/features/content/comment/comment_provider.dart';
import 'package:tubetube/features/content/comment/comment_sheet.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:tubetube/features/content/Long_video/Widget/video_externel_button.dart';
import 'package:tubetube/features/upload/long_video/video_repository.dart';
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
  bool isSub = false;
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

  likeVideo() async {
    setState(() {
      if (widget.video.likes.contains(FirebaseAuth.instance.currentUser!.uid)) {
        widget.video.likes.remove(FirebaseAuth.instance.currentUser!.uid);
      } else {
        widget.video.likes.add(FirebaseAuth.instance.currentUser!.uid);
      }
    });
    await ref.watch(longVideoProvider).likeVideo(
      likes: widget.video.likes,
      videoId: widget.video.videoId,
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
    );
    ref.refresh(longVideoProvider);
  }

  Future<void> shareVideo(String videoUrl, String title) async {
    await FlutterShare.share(
      title: title,
      text: 'Hãy xem video ${widget.video.title} này!!!!',
      linkUrl: videoUrl,
      chooserTitle: 'Chia sẻ Video này ',
    );
  }
  @override
  Widget build(BuildContext context) {

    final user = ref.watch(anyUserDataProvider(widget.video.userId));
    final AsyncValue<UserModel> currentuser = ref.watch(currentUserProvider);

    isSub = user.value!.subscriptions.contains(FirebaseAuth.instance.currentUser!.uid);

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
                                    colors:const VideoProgressColors(
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
              :const Padding(
                  padding:const EdgeInsets.only(bottom: 100),
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
                          ? "Không lượt xem"
                          : "${widget.video.views} lượt xem",
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserChannelPage(userId: widget.video.userId),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.value!.profilePic),
                    ),
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
                          ? "0 ĐĂNG KÝ"
                          : "${user.value!.subscriptions.length} đăng ký",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 35,
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: (FirebaseAuth.instance.currentUser!.uid != user.value!.userId)
                          ? ElevatedButton(
                        onPressed: () async {
                          // If already subscribed, unsubscribe
                          if (user.value!.subscriptions.contains(FirebaseAuth.instance.currentUser!.uid)) {
                            isSub = false;
                            await ref.watch(subscribeChannelProvider).unsubscribeChannel(
                              userId: widget.video.userId,
                              currentUserId: FirebaseAuth.instance.currentUser!.uid,
                              subscriptions: user.value!.subscriptions,
                              ref: ref,
                            );
                            setState(() {});
                          }
                          // If not subscribed, subscribe
                          else {
                            isSub = true;
                            await ref.watch(subscribeChannelProvider).subscribeChannel(
                              userId: widget.video.userId,
                              currentUserId: FirebaseAuth.instance.currentUser!.uid,
                              subscriptions: user.value!.subscriptions,
                              ref: ref,
                            );
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSub ? Colors.grey : Colors.red,
                        ),
                        child: Text(
                          isSub ? "ĐÃ ĐĂNG KÝ" : "ĐĂNG KÝ",
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      )
                          : const SizedBox(),
                    ),
                  )
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
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 5),
                            child: Text(
                              "${widget.video.likes.length}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: likeVideo,
                            child: Icon(
                              Icons.favorite,
                              color: widget.video.likes.contains(
                                      FirebaseAuth.instance.currentUser!.uid)
                                  ? Colors.red
                                  : Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 9, right: 9),
                      child: VideoExtraButton(
                        onPressed: () async {
                          await shareVideo(
                              widget.video.videoUrl, widget.video.title);
                        },
                        text: "Chia Sẻ",
                        iconData: Icons.share,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 9, right: 9),
                      child: VideoExtraButton(
                        onPressed: () async {},
                        text: "Tải Xuống",
                        iconData: Icons.download,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Khu Binh Luan
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: GestureDetector(
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
                      height: 120,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final AsyncValue<List<CommentModel>> comments =
                                  ref.watch(
                                commentsProvider(widget.video.videoId),
                              );
                              if (comments.value!.isEmpty) {
                                return const SizedBox(
                                  height: 20,
                                );
                              }
                              return VideoFirstComment(
                                comments: comments.value!,
                                user: user.value!,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: CachedNetworkImageProvider(
                                    currentuser.value!.profilePic,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
