import 'package:flutter/material.dart';
import 'package:tubetube/cores/colors.dart';

class VideoExtraButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final VoidCallback onPressed;

  const VideoExtraButton({
    Key? key,
    required this.text,
    required this.iconData,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
          color: softBlueGreyBackGround,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(iconData),
            const SizedBox(width: 5),
            Text(text),
          ],
        ),
      ),
    );
  }
}
