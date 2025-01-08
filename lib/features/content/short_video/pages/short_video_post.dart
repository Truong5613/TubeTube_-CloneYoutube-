import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tubetube/cores/method.dart';
import 'package:tubetube/features/Model/short_video_model.dart';
import 'package:tubetube/features/Provider&Repository/short_video_repository.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
import 'package:tubetube/features/content/short_video/pages/Short_video_tile.dart';
import 'package:tubetube/features/content/short_video/pages/short_video_page.dart';
import 'package:tubetube/features/upload/short_video/short_video_edit.dart';
import 'package:tubetube/home_page.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';

class ShortPost extends ConsumerStatefulWidget {
  final ShortVideoModel video;

  const ShortPost({Key? key, required this.video}) : super(key: key);

  @override
  _ShortPostState createState() => _ShortPostState();
}

class _ShortPostState extends ConsumerState<ShortPost> {
  bool _isCaptionExpanded = false;

  // Lấy thumbnail từ video URL
  Future<String?> _getThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          "${widget.video.hashCode}_${widget.video.shortvideoId}.png"; // Tạo tên file duy nhất
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

  void toggleCaption() {
    setState(() {
      _isCaptionExpanded = !_isCaptionExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    // Placeholder values for checking if user is owner or admin
    final isOwner = currentUser.value?.userId == widget.video.userId;
    final isAdmin = currentUser.value?.type ==
        'admin'; // Add your logic to check if the user is an admin

    final isBanned = widget.video.isBanned;

    if (isBanned && !(isAdmin || isOwner)) {
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
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'This video has been banned.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );
    }

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
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnails or Cover Image for the short video
            FutureBuilder<String?>(
              future: _getThumbnail(widget.video.shortVideo),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Icon(Icons.error);
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Image.file(
                    File(snapshot.data!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Center(child: Icon(Icons.error)); // Handle error gracefully
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
                    _isCaptionExpanded
                        ? widget.video.caption
                        : widget.video.caption.length > 40
                        ? '${widget.video.caption.substring(0, 40)}...'
                        : widget.video.caption,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: _isCaptionExpanded ? null : 4,
                    overflow: _isCaptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (widget.video.caption.length > 40) // Caption length threshold
                    TextButton(
                      onPressed: toggleCaption,
                      child: Text(
                        _isCaptionExpanded ? "Rút Gọn" : "Xem Thêm",
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Likes and Date Published info
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined,
                          size: 18, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text("${widget.video.likes.length} Likes"),
                      const SizedBox(width: 16),
                      Text(
                        "${widget.video.datePublished.day}/${widget.video.datePublished.month}/${widget.video.datePublished.year}",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Button to view the post
                  Row(
                    children: [
                      // Disable the "View Video" button if banned
                      if (!isBanned)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShortVideoPage(
                                    shortVideoId: widget.video.shortvideoId),
                              ),
                            );
                          },
                          child: Text("Xem Video"),
                          style: TextButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      const Spacer(),
                      if (widget.video.isHidden)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Video bị ẩn',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (widget.video.isBanned)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Video bị cấm',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      PopupMenuButton<int>(
                        onSelected: (value) async {
                          switch (value) {
                            case 0:
                            // Edit Video
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShortVideoEdit( // Assuming VideoDetailsPage is your edit screen
                                   shortVideoId: widget.video.shortvideoId, Oldcaption: widget.video.caption,
                                  ),
                                ),
                              );
                              break;
                            case 1:
                            // Delete Video
                              bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Xóa Video'),
                                      content: const Text(
                                          'Bạn có chắc chắn muốn xóa video này không?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text(
                                              'Hủy'), // Adjusted label for clarity
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deleteFileFromUrl(
                                                widget.video.shortVideo);
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Có'),
                                        ),
                                      ],
                                    );
                                  });

                              if (confirmDelete == true) {
                                await ref
                                    .watch(shortVideoProvider)
                                    .deleteShortVideo(
                                    videoId: widget.video.shortvideoId,
                                    userId: widget.video.userId);
                              }
                              break;
                            case 2:
                            // Toggle Visibility
                              await ref
                                  .watch(shortVideoProvider)
                                  .toggleVisibility(
                                videoId: widget.video.shortvideoId,
                                isHidden: widget.video.isHidden,
                              );
                              break;
                            case 3:
                            // Ban or Unban Video
                              await ref.watch(shortVideoProvider).toggleBan(
                                  videoId: widget.video.shortvideoId,
                                  isBanned: widget.video.isBanned);
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            if (isOwner) ...[
                              const PopupMenuItem<int>(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Sửa Video'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<int>(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 8),
                                    Text('Xóa Video'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<int>(
                                value: 2,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 8),
                                    Text('Ẩn Video'),
                                  ],
                                ),
                              ),
                            ],
                            if (isAdmin)
                              const PopupMenuItem<int>(
                                value: 3,
                                child: Row(
                                  children: [
                                    Icon(Icons.block),
                                    SizedBox(width: 8),
                                    Text('Ban Video'),
                                  ],
                                ),
                              ),
                          ];
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
