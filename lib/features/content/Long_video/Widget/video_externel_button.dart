// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tubetube/cores/colors.dart';



class VideoExtraButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final VoidCallback? onPressed;
  const VideoExtraButton({
    Key? key,
    required this.text,
    required this.iconData,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,  // Thêm sự kiện onPressed
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 3,
        ),
        decoration: const BoxDecoration(
          color: softBlueGreyBackGround,
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Row(
          children: [
            Icon(iconData),
            const SizedBox(width: 6),
            Text(text),
          ],
        ),
      ),
    );
  }
}