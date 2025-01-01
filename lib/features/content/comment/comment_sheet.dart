import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/Model/comment_model.dart';
import 'package:tubetube/features/auth/provider/user_provider.dart';
import 'package:tubetube/features/content/comment/comment_tile.dart';
import 'package:tubetube/features/upload/comments/comment_Repository.dart';

import 'package:tubetube/features/Model/video_model.dart';

class CommentSheet extends ConsumerStatefulWidget {
  final VideoModel video;

  const CommentSheet({
    required this.video,
  });

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).whenData((user) => user);
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bình Luận",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
            ),
            child: const Text(
              "Hãy bình luận 1 cách lịch sự",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("comments")
                .where("videoId", isEqualTo: widget.video.videoId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const ErrorPage();
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              final commentsMap = snapshot.data!.docs;
              final List<CommentModel> comments = commentsMap
                  .map((comment) => CommentModel.fromMap(comment.data()))
                  .toList();
              return Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return CommentTile(
                      comment: comments[index],
                    );
                  },
                ),
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 8, left: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 8),
                  child:  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.value!.profilePic),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  width: 280,
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintText: "Viết bình luận ... ",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await ref.watch(commentProvider).uploadCommentToFirestore(
                          commentText: commentController.text,
                          videoId: widget.video.videoId,
                          displayName: user.value!.displayName,
                          profilePic: user.value!.profilePic,
                        );
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.blueAccent,
                    size: 35,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
