import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/Provider&Repository/user_data_service.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/Search/widgets/search_channel_tile.dart';

class SubscribeChannelPage extends ConsumerWidget {
  const SubscribeChannelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsyncValue = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kênh Đã Đăng Ký'),
      ),
      body: currentUserAsyncValue.when(
        data: (currentUser) {
          final alluser = ref.watch(allUsersProvider);
          return ListView.builder(
            itemCount: alluser.value!.length,
            itemBuilder: (context, index) {
              final user = alluser.value![index];

              final isSubscribed = user.subscriptions.contains(FirebaseAuth.instance.currentUser!.uid);

              // Nếu không có currentUserId trong subscribers, bỏ qua
              if (!isSubscribed) {
                return const SizedBox.shrink(); // Không hiển thị gì nếu không đăng ký
              }
              return SearchChannelTile(user: user);

            },
          );

        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
