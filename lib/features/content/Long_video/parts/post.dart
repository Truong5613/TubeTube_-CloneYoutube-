import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/auth/provider/user_provider.dart';
import 'package:tubetube/features/content/Long_video/parts/video.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends ConsumerWidget {
  final VideoModel video;

  const Post({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set Vietnamese locale for time ago formatting
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Fetch user data using the userId associated with the video
    final AsyncValue<UserModel> userModel =
    ref.watch(anyUserDataProvider(video.userId));

    final user = userModel.whenData((user) => user);

    return GestureDetector(
      onTap: () async {
        // Navigate to the video detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Video(
              video: video,
            ),
          ),
        );

        // Increment the view count in Firestore
        await FirebaseFirestore.instance
            .collection("videos")
            .doc(video.videoId)
            .update(
          {
            "views": FieldValue.increment(1),
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            // Display video thumbnail
            CachedNetworkImage(
              imageUrl: video.thumbnail,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 5),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    // Display user profile image
                    backgroundImage: CachedNetworkImageProvider(
                      user.value?.profilePic ?? '', // Handle null case
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        video.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 5),
                      child: Row(
                        children: [
                          // Display user name
                          Text(
                            user.value?.displayName ?? 'Unknown', // Handle null case
                            style: const TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              video.views == 0
                                  ? "0 lượt xem"
                                  : "${video.views} lượt xem",
                              style: const TextStyle(
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          // Display time ago
                          Text(
                            timeago.format(video.datePublished, locale: 'vi'),
                            style: const TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // You can implement more actions here if needed
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
