import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:tubetube/features/Provider&Repository/short_video_repository.dart';
import 'package:tubetube/home_page.dart';
import 'package:uuid/uuid.dart';

class ShortVideoEdit extends ConsumerStatefulWidget {
  final String shortVideoId;
  final String Oldcaption;
  const ShortVideoEdit(  {Key? key, required this.shortVideoId,required this.Oldcaption,})
      : super(key: key);

  @override
  ConsumerState<ShortVideoEdit> createState() => _ShortVideoEditState();
}

class _ShortVideoEditState extends ConsumerState<ShortVideoEdit> {
  final captionController = TextEditingController();
  late String userId;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the old caption
    captionController.text = widget.Oldcaption;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: const Text(
          "Chỉnh sửa Video Shorts",
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
              const Text(
                "Nhập Chú Thích",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
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
                    text: "CẬP NHẬT VIDEO",
                    onPressed: () async {
                      try {
                        // Cập nhật video
                        await ref
                            .watch(shortVideoProvider)
                            .updateShortVideoInFirestore(
                              caption: captionController.text,
                              shortvideoId: widget.shortVideoId,
                            );

                        // Quay lại trang chủ sau khi cập nhật thành công
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false, // Xóa toàn bộ stack
                        );
                      } catch (error) {
                        // Hiển thị thông báo lỗi nếu có
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cập nhật thất bại: $error')),
                        );
                      }
                    },
                    colour: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
