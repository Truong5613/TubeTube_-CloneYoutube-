import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavigation extends StatefulWidget {
  final Function(int index) onPressed;
  const BottomNavigation({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentIndex = 0;

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
          GButton(icon: Icons.cloud_upload, text: "Upload"),
          GButton(icon: Icons.search, text: "Search"),
          GButton(icon: Icons.logout, text: "Log out"),
        ],
        onTabChange: (index) {
          setState(() {
            currentIndex = index;
          });
          widget.onPressed(index);
        },
        selectedIndex: currentIndex,
      ),
    );
  }
}
