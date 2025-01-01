import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tubetube/features/Model/comment_model.dart';
class CommentTile extends StatelessWidget {
  final CommentModel comment;
  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                  CachedNetworkImageProvider(comment.profilePic),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                timeago.format(comment.time, locale: 'vi')
                ,
                style: const TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_vert),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              right: MediaQuery.sizeOf(context).width * 0.56,
            ),
            child: Text(comment.commentText),
          ),
        ],
      ),
    );
  }
}
