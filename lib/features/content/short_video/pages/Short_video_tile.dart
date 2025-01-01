import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/auth/provider/user_provider.dart';
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
  bool isMuted = false; // Âm thanh tắt mặc định
  bool isPlaying = true; // Video phát mặc định

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    shortVideoController = VideoPlayerController.network(widget.shortVideo.shortVideo)
      ..initialize().then((_) {
        setState(() {});
        shortVideoController.play();
        shortVideoController.setLooping(true);
        shortVideoController.setVolume(1); // Tắt âm thanh mặc định
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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserModel> user =
    ref.watch(anyUserDataProvider(widget.shortVideo.userId));

    return Stack(
      children: [
        // Video player
        GestureDetector(
          onTap: togglePlayPause,
          child: shortVideoController.value.isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: shortVideoController.value.size.width,
                height: shortVideoController.value.size.height,
                child: VideoPlayer(shortVideoController),
              ),
            ),
          )
              : Center(
            child: CircularProgressIndicator(),
          ),
        ),

        // Overlay for actions and details
        Positioned(
          bottom: 20,
          left: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Nền mờ
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption and User info
                Row(
                  children: [
                    // Avatar (ensure user data is loaded first)
                    user.when(
                      data: (userData) {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(userData.profilePic),
                          radius: 16,
                        );
                      },
                      loading: () => CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 16,
                      ),
                      error: (error, stackTrace) => CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Username
                    user.when(
                      data: (userData) => Text(
                        userData.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      loading: () => CircularProgressIndicator(),
                      error: (error, stackTrace) => Text(
                        "Unknown User",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Caption text
                Text(
                  widget.shortVideo.caption,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Timeago (posted date)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeago.format(widget.shortVideo.datePublished, locale: 'vi'),
                      style: TextStyle(color: Colors.white),
                    ),
                    // Volume toggle button
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
          bottom: 180,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Nền mờ
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.white, size: 30),
                  onPressed: () {
                    // Handle like action
                  },
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.comment, color: Colors.white, size: 30),
                  onPressed: () {
                    // Handle comment action
                  },
                ),
              ],
            ),
          ),
        ),

        // Play/Pause overlay icon
        if (!isPlaying)
          Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white.withOpacity(0.7),
              size: 80,
            ),
          ),
      ],
    );
  }
}
