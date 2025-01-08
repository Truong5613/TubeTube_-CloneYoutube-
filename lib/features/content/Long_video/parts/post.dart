import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/method.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/Provider&Repository/video_repository.dart';
import 'package:tubetube/features/channel/my_channel/pages/my_channel_screen.dart';
import 'package:tubetube/features/channel/users_channel/user_channel_page.dart';
import 'package:tubetube/features/content/Long_video/parts/video.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tubetube/features/upload/long_video/video_edit_page.dart';

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

    // Get current user data for checking ownership and admin status
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser.value?.userId == video.userId;
    final isAdmin = currentUser.value?.type == 'admin';

    // Check if video is hidden or banned, and whether the current user is allowed to see it
    if ((video.isHidden || video.isBanned) && !(isOwner || isAdmin)) {
      return const SizedBox(); // Hide video if not owner or admin
    }


    return Padding(
      padding: const EdgeInsets.only(top: 5,bottom: 5),
      child: GestureDetector(
        onTap: () async {
          if (video.isBanned) {
            return; // Do nothing if the video is banned or hidden
          }
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
                height: 200,
                width: 350,
                fit: BoxFit.cover,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 5),
                    child: GestureDetector(
                      onTap: (){
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null && video.userId == currentUser.uid) {
                          // Nếu là chính tài khoản người dùng, chuyển sang trang MyUserPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyChannelScreen(), // Trang cá nhân của người dùng
                            ),
                          );
                        } else {
                          // Nếu không phải, chuyển sang trang UserChannelPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserChannelPage(userId: video.userId),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        // Display user profile image
                        backgroundImage: CachedNetworkImageProvider(
                          user.value?.profilePic ?? '', // Handle null case
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text(
                              video.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (video.isHidden)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Video bị ẩn',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (video.isBanned)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Video bị cấm',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Row(
                          children: [
                            // Display user name
                            Text(
                              (user.value?.displayName ?? 'Không Rõ').length > 10
                                  ? '${(user.value?.displayName ?? 'Không Rõ').substring(0, 10)}...' // Cắt tối đa 6 ký tự
                                  : user.value?.displayName ?? 'Không Rõ', // Hiển thị đầy đủ nếu <= 6 ký tự
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),


                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
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
                  PopupMenuButton<int>(
                    onSelected: (value) async {
                      switch (value) {
                        case 0:
                        // Edit Video
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditVideoScreen( // Assuming VideoDetailsPage is your edit screen
                                videoId: video.videoId, oldThumbnail: video.thumbnail, oldTitle: video.title, oldDescription: video.description, // Pass the current video to the edit screen
                              ),
                            ),
                          );
                          break;
                        case 1:
                        // Delete Video
                          bool? confirmDelete = await showDialog<bool>(context: context, builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Xóa Video'),
                              content: const Text('Bạn có chắc chắn muốn xóa video này không?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Hủy'), // Adjusted label for clarity
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await deleteFileFromUrl(video.thumbnail);
                                    await deleteFileFromUrl(video.videoUrl);
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Có'),
                                ),
                              ],
                            );
                          });

                          if (confirmDelete == true) {
                            await ref.watch(longVideoProvider).deleteVideo(videoId: video.videoId, userId: video.userId);
                          }
                          break;
                        case 2:
                        // Toggle Visibility
                          await ref.watch(longVideoProvider).toggleVisibility(
                            videoId: video.videoId,
                            isHidden: video.isHidden,
                          );
                          break;
                        case 3:
                        // Ban or Unban Video
                          if (isAdmin && !isOwner) {
                            await ref.read(longVideoProvider).toggleBan(
                              videoId: video.videoId,
                              isBanned: video.isBanned,
                            );
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        if (isOwner) ...[
                          const PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Sửa Video'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Xóa Video'),
                              ],
                            ),
                          ),
                          PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(video.isHidden ? Icons.visibility : Icons.visibility_off),
                                const SizedBox(width: 8),
                                Text(video.isHidden ? 'Hiển thị Video' : 'Ẩn Video'),
                              ],
                            ),
                          ),
                        ],
                        if (isAdmin)
                          PopupMenuItem<int>(
                            value: 3,
                            child: Row(
                              children: [
                                Icon(video.isBanned ? Icons.block : Icons.refresh),
                                const SizedBox(width: 8),
                                Text(video.isBanned ? 'Gỡ Ban Video' : 'Ban Video'),
                              ],
                            ),
                          ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
