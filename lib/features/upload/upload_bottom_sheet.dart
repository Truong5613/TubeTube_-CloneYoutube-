// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tubetube/cores/method.dart';
import 'package:tubetube/cores/widgets/image_item.dart';

class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffFFFFFF),
      child: Padding(
        padding: const EdgeInsets.only(left: 7, top: 12),
        child: SizedBox(
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Hoạt Động Đăng Tải",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 38,
                child: ImageItem(
                  itemText: "Tạo Video Ngắn",
                  itemClicked: () async {
                    pickShortVideo(context);
                  },
                  imageName: "short-video.png",
                  haveColor: true,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ImageItem(
                  itemText: "Tạo Video Dài",
                  itemClicked: () async {
                    await pickVideo(context);
                  },
                  imageName: "upload.png",
                  haveColor: true,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}