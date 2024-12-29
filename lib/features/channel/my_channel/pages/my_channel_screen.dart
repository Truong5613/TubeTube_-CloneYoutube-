import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/colors.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/cores/widgets/image_button.dart';
import 'package:tubetube/features/auth/provider/user_provider.dart';
import 'package:tubetube/features/channel/my_channel/parts/buttons.dart';
import 'package:tubetube/features/channel/my_channel/parts/tab_bar.dart';
import 'package:tubetube/features/channel/my_channel/parts/tab_bar_view.dart';
import 'package:tubetube/features/channel/my_channel/parts/top_header.dart';

class MyChannelScreen extends ConsumerWidget {
  const MyChannelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(currentUserProvider).when(
        data: (currentUser)=> DefaultTabController(
          length: 7,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    //Thong tin TopHeader
                    TopHeader(user: currentUser),

                    const Text("More about this channel"),

                    Buttons(),
                    // Tao Thanh Tab
                    PageTabBar(),
                    TabPages(),
                  ],
                ),
              ),
            ),
          ),
        ),
        error: (error, stackTrace) => const ErrorPage() ,
        loading: ()=> const Loader(),
    );
  }
}
