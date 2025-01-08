import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/method.dart';
import 'package:tubetube/features/Provider&Repository/video_repository.dart';
import 'dart:io';

import 'package:tubetube/home_page.dart';
import 'package:uuid/uuid.dart';

class EditVideoScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String oldThumbnail;
  final String oldTitle;
  final String oldDescription;

  EditVideoScreen({
    required this.videoId,
    required this.oldThumbnail,
    required this.oldTitle,
    required this.oldDescription,
  });

  @override
  _EditVideoScreenState createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends ConsumerState<EditVideoScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? image;

  bool isThumbnailChange = false;
  String randomNumber = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.oldTitle;
    descriptionController.text = widget.oldDescription;

    // Check if oldThumbnail is a URL or a file path
    if (widget.oldThumbnail.isNotEmpty) {
      if (widget.oldThumbnail.startsWith('http')) {
        // If it's a URL, display it as an Image.network
        image =
        null; // Set image to null as we will load it from the URL directly
      } else {
        // If it's a file path, load the file
        image = File(widget.oldThumbnail);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh Sửa Chi Tiết Video"),),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  "Nhập Tiêu Đề",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Nhập tiêu đề video",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Description
                const Text(
                  "Nhập Mô Tả",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Nhập mô tả Video",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        // Pick image
                        isThumbnailChange = true;
                        image = await pickImage();
                        setState(() {});
                      },
                      child: const Text(
                        "Chọn ảnh đại diện video",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // Display selected thumbnail

                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: image != null
                      ? Image.file(
                    image!,
                    cacheHeight: 160,
                    cacheWidth: 400,
                  )
                      : widget.oldThumbnail.startsWith('http')
                      ? Image.network(
                    widget.oldThumbnail,
                    cacheWidth: 400,
                    cacheHeight: 160,
                  )
                      : const SizedBox(), // Empty space when no image is selected
                ),

                // Submit button to post video

                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        try {
                          if (isThumbnailChange) {
                            await deleteFileFromUrl(widget.oldThumbnail);
                            String newThumbnailUrl = await putFileInStorage(
                                image, randomNumber, 'image');
                            ref.watch(longVideoProvider).updateVideoInFirestore(
                                videoId: widget.videoId,
                                thumbnail: newThumbnailUrl,
                                title: titleController.text,
                                description: descriptionController.text);
                          } else {
                            ref.watch(longVideoProvider).updateVideoInFirestore(
                                videoId: widget.videoId,
                                thumbnail: widget.oldThumbnail,
                                title: titleController.text,
                                description: descriptionController.text);
                          }

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                                (route) => false,
                          );
                          // Show success message
                          showErrorSnackBar(
                              "Chỉnh Sửa Video thành công!", context);
                        } catch (e) {
                          showErrorSnackBar(
                              "Chỉnh Sửa video thất bại: $e", context);
                        }
                      },
                      child: const Text(
                        "Chỉnh Sửa Video",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SnackBar for showing error messages
  void showErrorSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }
}
