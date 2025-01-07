import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/screens/error_page.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/Provider&Repository/User_Repository.dart';
import 'package:tubetube/features/channel/my_channel/widgets/edit_setting_dialog.dart';
import 'package:tubetube/features/channel/my_channel/widgets/setting_field_item.dart';



class MyChannelSettings extends ConsumerStatefulWidget {
  const MyChannelSettings({super.key});

  @override
  ConsumerState<MyChannelSettings> createState() => _MyChannelSettingsState();
}

class _MyChannelSettingsState extends ConsumerState<MyChannelSettings> {
  bool isSwiched = false;

  @override
  Widget build(BuildContext context) {
    return ref.watch(currentUserProvider).when(
      data: (currentUser) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(  // Make the body scrollable to avoid overflow
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 170,
                        width: double.infinity,
                        child: Image.asset(
                          "assets/images/background.png", //################
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 180,
                        top: 60,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(
                            currentUser.profilePic,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 10,
                        child: Image.asset(
                          "assets/icons/camera.png",
                          height: 34,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // second part
                  const SizedBox(height: 14),

                  SettingsItem(
                    identifier: "Tên hiển thị",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SettingsDialog(
                          identifier: "Nhập tên hiển thị mới của bạn",
                          onSave: (name) {
                            ref.watch(editSettingsProvider).editDisplayName(ref, name);
                            Navigator.pop(context);  // Close the dialog after saving
                          },
                        ),
                      );
                    },
                    value: currentUser.displayName,
                  ),
                  const SizedBox(height: 14),
                  SettingsItem(
                    identifier: "Tên người dùng",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SettingsDialog(
                          identifier: "Nhập tên người dùng mới",
                          onSave: (username) {
                            ref.watch(editSettingsProvider).editusername(ref, username);
                            Navigator.pop(context);  // Close the dialog after saving
                          },
                        ),
                      );
                    },
                    value: currentUser.username,
                  ),
                  const SizedBox(height: 14),
                  SettingsItem(
                    identifier: "Mô tả",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SettingsDialog(
                          identifier: "Nhập Mô tả mới",
                          onSave: (description) {
                            ref.watch(editSettingsProvider).editDescription(ref, description);
                            Navigator.pop(context);  // Close the dialog after saving
                          },
                        ),
                      );
                    },
                    value: currentUser.description,
                  ),

                  const Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Text(
                      "Những thay đổi của bạn ở đây sẽ là thông tin hiển thị trên TubeTube và Google Services",
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
