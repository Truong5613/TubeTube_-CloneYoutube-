import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tubetube/features/Model/user_model.dart';
class TopHeader extends StatelessWidget {
  final UserModel user;
  const TopHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 38,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(user.profilePic),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child:  Text(
            user.displayName,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: RichText(
            text: TextSpan(
              style:const TextStyle(
                color: Colors.blueGrey,
              ),
              children: [
                TextSpan(text: "${user.username}  "),
                TextSpan(text: "${user.subscriptions.length} Đăng ký  "),
                TextSpan(text: "${user.videos} Video"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
