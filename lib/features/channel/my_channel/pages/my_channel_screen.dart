import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/colors.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/cores/widgets/image_button.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/channel/my_channel/parts/buttons.dart';
import 'package:tubetube/features/channel/my_channel/parts/tab_bar.dart';
import 'package:tubetube/features/channel/my_channel/parts/tab_bar_view.dart';
import 'package:tubetube/features/channel/my_channel/parts/top_header.dart';

class MyChannelScreen extends ConsumerStatefulWidget {
  const MyChannelScreen({super.key});

  @override
  _MyChannelScreenState createState() => _MyChannelScreenState();
}

class _MyChannelScreenState extends ConsumerState<MyChannelScreen> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(currentUserProvider).when(
      data: (currentUser) => DefaultTabController(
        length: 7,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  // Thong tin TopHeader
                  TopHeader(user: currentUser),
                  const Text("Tổng Quát Kênh Này"),
                  // Tao Thanh Tab
                  PageTabBar(),
                  TabPages(Userid: FirebaseAuth.instance.currentUser!.uid),
                ],
              ),
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => const ErrorPage(),
      loading: () => const Loader(),
    );
  }
}
