import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tubetube/cores/widgets/image_item.dart';
import 'package:tubetube/features/account/ChannelSubcriberPage.dart';
import 'package:tubetube/features/account/TermOfService.dart';
import 'package:tubetube/features/auth/pages/login_page.dart';
import 'package:tubetube/features/channel/my_channel/pages/channel_setting.dart';
import 'package:tubetube/home_page.dart';
import 'package:tubetube/main.dart';

class Items extends StatelessWidget {
  const Items({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng popup
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng popup
                await GoogleSignIn().signOut(); // Đăng xuất Google
                await FirebaseAuth.instance.signOut();
                await FirebaseAuth.instance.currentUser?.reload();
                Phoenix.rebirth(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                      (Route<dynamic> route) => false, // Xóa toàn bộ lịch sử trang
                );
              },
              child: const Text('Đăng Xuất'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 9),
          SizedBox(
            height: 33,
            child: ImageItem(
              imageName: "settings.png",
              itemClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyChannelSettings(),
                  ),
                );
              },
              itemText: "Đổi Thông Tin Người Dùng",
              haveColor: false,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 35,
            child: ImageItem(
              imageName: "notification.png",
              itemClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscribeChannelPage(),
                  ),
                );
              },
              itemText: "Kênh Đã Đăng Ký",
              haveColor: false,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 35,
            child: ImageItem(
              imageName: "help.png",
              itemClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsOfServicePage(),
                  ),
                );
              },
              itemText: "Chính Sách Sử Dụng ",
              haveColor: false,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 35,
            child: ImageItem(
              imageName: "logout.png",
              itemClicked: () => _showLogoutConfirmation(context),
              itemText: "Đăng Xuất",
              haveColor: false,
            ),
          ),
        ],
      ),
    );
  }
}
