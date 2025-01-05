// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tubetube/features/Model/comment_model.dart';
import 'package:tubetube/features/Model/user_model.dart';



class VideoFirstComment extends StatelessWidget {
  final List<CommentModel> comments;
  final UserModel user;
  const VideoFirstComment({
    Key? key,
    required this.comments,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5),
            Text("Có ${comments.length}"),
            const Text(
              "  Bình Luận",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7.5),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(
                  comments[0].profilePic,
                ),
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 280,
                child: Text(
                  comments[0].commentText,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}