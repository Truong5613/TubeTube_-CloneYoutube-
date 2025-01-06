import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/Repository/subcribe_respository.dart';
import 'package:tubetube/features/channel/my_channel/pages/my_channel_screen.dart';
import 'package:tubetube/features/channel/users_channel/user_channel_page.dart';

class SearchChannelTile extends ConsumerWidget {
  final UserModel user;
  const SearchChannelTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserModel> currentuser = ref.watch(currentUserProvider);
    bool isSub = user.subscriptions.contains(FirebaseAuth.instance.currentUser!.uid);

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: GestureDetector(
        onTap: () {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && user.userId == currentUser.uid) {
            // Nếu là chính tài khoản người dùng, chuyển sang trang MyUserPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyChannelScreen(), // Trang cá nhân của người dùng
              ),
            );
          } else {
            // Nếu không phải, chuyển sang trang UserChannelPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserChannelPage(userId: user.userId),
              ),
            );
          }
        },

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.profilePic),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "@${user.username}",
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    user.subscriptions.isEmpty
                        ? "0 ĐĂNG KÝ"
                        : "${user.subscriptions.length} đăng ký",
                    style: const TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 35,
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: (FirebaseAuth.instance.currentUser!.uid != user.userId)
                          ? ElevatedButton(
                        onPressed: () async {
                          if (isSub) {
                            await ref.watch(subscribeChannelProvider).unsubscribeChannel(
                              userId: user.userId,
                              currentUserId: FirebaseAuth.instance.currentUser!.uid,
                              subscriptions: user.subscriptions,
                              ref: ref,
                            );
                          }
                          else {
                            await ref.watch(subscribeChannelProvider).subscribeChannel(
                              userId: user.userId,
                              currentUserId: FirebaseAuth.instance.currentUser!.uid,
                              subscriptions: user.subscriptions,
                              ref: ref,
                            );
                          }
                          ref.refresh(subscribeChannelProvider);
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
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
