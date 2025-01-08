import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubetube/features/auth/pages/logout_page.dart';
import 'package:tubetube/main.dart';

class BottomNavigation extends StatefulWidget {
  final Function(int index) onPressed;
  const BottomNavigation({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentIndex = 0;

  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Đóng và không logout
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Xác nhận logout
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (result == true) {
      await GoogleSignIn().signOut(); // Đăng xuất Google
      await FirebaseAuth.instance.signOut(); // Đăng xuất Firebase
      await FirebaseAuth.instance.currentUser?.reload();
      await FirebaseFirestore.instance.clearPersistence(); // Xóa cache cục bộ
      await clearLocalData();
      Phoenix.rebirth(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
            (route) => false, // Xóa tất cả các route trước đó
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng xuất thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 3),
      child: GNav(
        rippleColor: Colors.purple.withOpacity(0.1), // Hiệu ứng chạm
        hoverColor: Colors.purple.withOpacity(0.2), // Hiệu ứng hover
        haptic: true, // Phản hồi xúc giác
        tabBorderRadius: 20, // Bo góc tròn hơn cho các tab
        tabActiveBorder: Border.all(
          color: Colors.purple,
          width: 1.2,
        ), // Viền nổi bật khi chọn
        tabBorder: Border.all(
          color: Colors.grey.shade300,
          width: 0.8,
        ), // Viền mờ hơn khi không chọn
        tabShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.15),
            blurRadius: 10,
          )
        ], // Đổ bóng tinh tế hơn
        curve: Curves.easeInOut, // Hiệu ứng mượt mà
        duration: const Duration(milliseconds: 300),
        gap: 8, // Khoảng cách giữa biểu tượng và text
        color: Colors.grey[600], // Màu biểu tượng khi chưa chọn
        activeColor: Colors.purple, // Màu biểu tượng khi chọn
        iconSize: 24, // Kích thước biểu tượng không thay đổi
        tabBackgroundColor: Colors.purple.withOpacity(0.1), // Nền tab khi chọn
        padding: const EdgeInsets.symmetric(
          horizontal: 19.5,
          vertical: 5,
        ),
        tabs: const [
          GButton(icon: Icons.home, text: "Home"),
          GButton(icon: Icons.videocam, text: "Shorts"),
          GButton(icon: Icons.cloud_upload),
          GButton(icon: Icons.search, text: "Search",textStyle: TextStyle(fontSize: 12),),
          GButton(icon: Icons.logout),
        ],
        onTabChange: (index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 4) {
            _confirmLogout(); // Hộp thoại xác nhận khi nhấn logout
          } else {
            widget.onPressed(index);
          }
        },
        selectedIndex: currentIndex,
      ),
    );
  }
}
