import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/content/short_video/pages/Short_video_tile.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_page.dart';
import 'package:tubetube/home_page.dart';
import 'package:video_thumbnail/video_thumbnail.dart'; // Import video_thumbnail package
import 'package:tubetube/cores/widgets/flat_button.dart';

class ShortPost extends StatelessWidget {
  final ShortVideoModel video;

  const ShortPost({Key? key, required this.video}) : super(key: key);

  // Lấy thumbnail từ video URL
  Future<String?> _getThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = "${video.hashCode}_${video.shortvideoId}.png"; // Tạo tên file duy nhất
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: "${tempDir.path}/$fileName",
        imageFormat: ImageFormat.PNG,
        quality: 75,
        timeMs: 5000,
      );
      return thumbnail;
    } catch (e) {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Vị trí của bóng
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnails or Cover Image for the short video
            FutureBuilder<String?>(
              future: _getThumbnail(video.shortVideo),
              // Get thumbnail from video
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Icon(Icons.error);
                } else if (snapshot.hasData && snapshot.data != null) {
                  // If thumbnail is successfully generated, show it
                  return Image.file(
                    File(snapshot.data!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Icon(Icons.error); // Show error icon if no thumbnail
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption text
                  Text(
                    video.caption,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Likes and Date Published info
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined,
                          size: 18, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text("${video.likes.length} Likes"),
                      const SizedBox(width: 16),
                      Text(
                          "${video.datePublished.day}/${video.datePublished
                              .month}/${video.datePublished.year}",
                          style:
                          TextStyle(color: Colors.blueGrey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Button to view the post
                  FlatButton(
                    text: "Xem Video",
                    onPressed: () {
                      // First, navigate to HomePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Scaffold(
                                appBar: AppBar(
                                  leading: IconButton(
                                    icon: Icon(Icons.arrow_back,color: Colors.black,),
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // This will navigate back to the previous page
                                    },
                                  ),
                                ),
                                body: SafeArea(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: ShortVideoPage(shortVideoId: video.shortvideoId),
                                  ),
                                ),
                              ),
                        ),
                      );
                    },
                    colour: Colors.blue,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
