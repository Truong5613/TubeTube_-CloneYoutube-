import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/Provider&Repository/short_video_repository.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/content/comment/comment_sheet_shortvideo.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShortVideoTile extends ConsumerStatefulWidget {
  final ShortVideoModel shortVideo;

  const ShortVideoTile({super.key, required this.shortVideo});

  @override
  ConsumerState<ShortVideoTile> createState() => _ShortVideoTileState();
}

class _ShortVideoTileState extends ConsumerState<ShortVideoTile> {
  late VideoPlayerController shortVideoController;
  bool isMuted = false; // Mute sound by default
  bool isPlaying = true; // Video plays by default
  bool _isCaptionExpanded = false; // Track if the caption is expanded

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    shortVideoController = VideoPlayerController.network(widget.shortVideo.shortVideo)
      ..initialize().then((_) {
        setState(() {});
        shortVideoController.play();
        shortVideoController.setLooping(true);
        shortVideoController.setVolume(1); // Mute by default
      });
  }

  @override
  void dispose() {
    shortVideoController.dispose();
    super.dispose();
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      shortVideoController.setVolume(isMuted ? 0.0 : 1.0);
    });
  }

  void togglePlayPause() {
    setState(() {
      if (isPlaying) {
        shortVideoController.pause();
      } else {
        shortVideoController.play();
      }
      isPlaying = !isPlaying;
    });
  }

  void toggleCaption() {
    setState(() {
      _isCaptionExpanded = !_isCaptionExpanded;
    });
  }

  likeVideo() async {
    setState(() {
      if (widget.shortVideo.likes.contains(FirebaseAuth.instance.currentUser!.uid)) {
        widget.shortVideo.likes.remove(FirebaseAuth.instance.currentUser!.uid);
      } else {
        widget.shortVideo.likes.add(FirebaseAuth.instance.currentUser!.uid);
      }
    });
    await ref.watch(shortVideoProvider).likeShortVideo(
      likes: widget.shortVideo.likes,
      shortvideoId: widget.shortVideo.shortvideoId,
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserModel> user = ref.watch(anyUserDataProvider(widget.shortVideo.userId));
    return Stack(
      children: [
        // Video player
        GestureDetector(
          onTap: togglePlayPause,
          child: shortVideoController.value.isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: SizedBox(
                width: shortVideoController.value.size.width,
                height: shortVideoController.value.size.height,
                child: VideoPlayer(shortVideoController),
              ),
            ),
          )
              : const Center(child: CircularProgressIndicator()),
        ),

        // Overlay for actions and details
        Positioned(
          bottom: 20,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Transparent background
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and User info
                Row(
                  children: [
                    user.when(
                      data: (userData) {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(userData.profilePic),
                          radius: 16,
                        );
                      },
                      loading: () => const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 16,
                      ),
                      error: (error, stackTrace) => const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    user.when(
                      data: (userData) => Text(
                        userData.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stackTrace) => const Text(
                        "Unknown User",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Caption text with "See More" feature
                Text(
                  _isCaptionExpanded
                      ? widget.shortVideo.caption
                      : widget.shortVideo.caption.length > 40
                      ? '${widget.shortVideo.caption.substring(0, 40)}...'
                      : widget.shortVideo.caption,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: _isCaptionExpanded ? null : 4,
                  overflow: _isCaptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (widget.shortVideo.caption.length > 40) // Caption length threshold
                  TextButton(
                    onPressed: toggleCaption,
                    child: Text(
                      _isCaptionExpanded ? "Rút Gọn" : "Xem Thêm",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 10),
                // Timeago (posted date)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeago.format(widget.shortVideo.datePublished, locale: 'vi'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(
                        isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: toggleMute,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Action buttons (like, comment, share)
        Positioned(
          right: 10,
          bottom: 250,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Transparent background
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up,
                      color: widget.shortVideo.likes.contains(FirebaseAuth.instance.currentUser!.uid)
                          ? Colors.blue
                          : Colors.white,
                      size: 30),
                  onPressed: likeVideo,
                ),
                Text(
                  "${widget.shortVideo.likes.length}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.white, size: 30),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => ShortVideoCommentSheet(shortVideo: widget.shortVideo),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Play/Pause overlay icon
        if (!isPlaying)
          Center(
            child: IconButton(
              icon: Icon(
                Icons.play_circle_filled,
                color: Colors.white.withOpacity(0.7),
                size: 70,
              ),
              onPressed: togglePlayPause,
            ),
          ),
      ],
    );
  }
}
