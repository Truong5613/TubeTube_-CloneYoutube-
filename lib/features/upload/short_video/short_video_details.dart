import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/method.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:tubetube/features/upload/short_video/short_video_repository.dart';
import 'package:tubetube/home_page.dart';
import 'package:uuid/uuid.dart';

class ShortVideoDetails extends ConsumerStatefulWidget {
  final File video;

  const ShortVideoDetails({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<ShortVideoDetails> createState() => _ShortVideoDetailsState();
}

class _ShortVideoDetailsState extends ConsumerState<ShortVideoDetails> {
  final captionController = TextEditingController();
  final DateTime date = DateTime.now();
  String randomNumber = const Uuid().v4();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: const Text(
          "Chi tiết Video Shorts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: captionController,
                decoration: InputDecoration(
                    hintText: "Viết chú thích ...",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ))),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: FlatButton(
                    text: "ĐĂNG VIDEO", onPressed: () async {
                  try {
                    String videoUrl = await  putFileInStorage(widget.video, randomNumber , "short_video");
                    // Upload video
                    await ref.watch(shortVideoProvider).addShortVideoTofirestore(
                      caption: captionController.text,
                      Video: videoUrl,
                      datePublished: date,
                    );

                    // Navigate to Homepage
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false, // Xóa toàn bộ stack
                    );
                  } catch (error) {
                    // Hiển thị thông báo lỗi nếu có
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đăng video thất bại: $error')),
                    );
                  }

                }, colour: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
