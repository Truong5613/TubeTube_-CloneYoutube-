import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/method.dart';
import 'package:tubetube/features/Provider&Repository/video_repository.dart';
import 'package:tubetube/home_page.dart';
import 'package:uuid/uuid.dart';



class VideoDetailsPage extends ConsumerStatefulWidget {
  final File? video;
  const VideoDetailsPage({
    this.video,
  });

  @override
  ConsumerState<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends ConsumerState<VideoDetailsPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  File? image;
  bool isThumbnailSelected = false;
  String randomNumber = const Uuid().v4();
  String videoId = const Uuid().v4();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 10,
              right: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Nhập Tiêu Đề",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Nhập tiêu đề video",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Nhập Mô Tả",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Nhập mô tả Video",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
        
                // select thumnbnail
        
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(
                        Radius.circular(11),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        // pick image
                        image = await pickImage();
                        isThumbnailSelected = true;
                        setState(() {});
                      },
                      child: const Text(
                        "Chọn ảnh đại diện video",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                isThumbnailSelected
                    ? Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Image.file(
                    image!,
                    cacheHeight: 160,
                    cacheWidth: 400,
                  ),
                )
                    : const SizedBox(),
        
                isThumbnailSelected
                    ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(
                        Radius.circular(11),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        // publish video
        
                        try {
                          String thumbnail = await putFileInStorage(image, randomNumber, "image");
                          String videoUrl = await putFileInStorage(widget.video, randomNumber, "video");
        
                          ref.read(longVideoProvider).uploadVideoToFirestore(
                            videoUrl: videoUrl,
                            thumbnail: thumbnail,
                            title: titleController.text,
                            videoId: videoId,
                            datePublished: DateTime.now(),
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            description: descriptionController.text,
                          );
        
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                                (route) => false, // Xóa toàn bộ stack
                          );
                          showErrorSnackBar("Đăng Video thành công!", context);
                        } catch (e) {
                          showErrorSnackBar("Đăng video thất bại: $e", context);
                        }
                      },
                      child: const Text(
                        "Đăng Video",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}