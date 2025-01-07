import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tubetube/features/Model/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Provider&Repository/comment_Repository.dart';

class CommentTile extends ConsumerStatefulWidget {
  final CommentModel comment;
  final String currentUserId; // Thêm ID của người dùng hiện tại
  final String videoOwnerId;  // Thêm ID của chủ sở hữu video

  const CommentTile({
    super.key,
    required this.comment,
    required this.currentUserId,
    required this.videoOwnerId,
  });

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    return Padding(
      padding: const EdgeInsets.only(left: 5, top: 7, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(widget.comment.profilePic),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.comment.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(widget.comment.time, locale: 'vi'),
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.comment.commentText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Thêm menu tùy chọn
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    // Xử lý logic xóa bình luận
                    await _deleteComment(context, widget.comment.commentId);
                  } else if (value == 'edit') {
                    // Xử lý logic sửa bình luận
                    _editComment(context, widget.comment);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return _buildMenuOptions();
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Xây dựng các tùy chọn menu dựa trên vai trò của người dùng
  List<PopupMenuEntry<String>> _buildMenuOptions() {
    if (widget.currentUserId == widget.comment.uid) {
      // Người dùng bình thường nhưng là chủ sở hữu bình luận
      return [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Xóa bình luận'),
        ),
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Sửa bình luận'),
        ),
      ];
    } else if (widget.currentUserId == widget.videoOwnerId) {
      // Chủ sở hữu video
      return [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Xóa bình luận'),
        ),

      ];
    }

    return [];
  }

  // Hàm xử lý xóa bình luận
  Future<void> _deleteComment(BuildContext context, String commentId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa bình luận này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng hộp thoại
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Xóa bình luận từ Firestore
              await ref.read(commentProvider).deleteCommentFromFirestore(commentId);
              Navigator.pop(context); // Đóng hộp thoại
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // Hàm xử lý sửa bình luận
  void _editComment(BuildContext context, CommentModel comment) {
    final TextEditingController editingController =
    TextEditingController(text: comment.commentText);

    showDialog(
      context: context,
      builder: (context) {
        if (!mounted) return Container();  // Prevent further action if widget is unmounted.
        return AlertDialog(
          title: const Text('Sửa bình luận'),
          content: TextField(
            controller: editingController,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Nhập nội dung bình luận mới...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (mounted) {
                  await ref.read(commentProvider).editCommentInFirestore(
                    commentId: comment.commentId,
                    newCommentText: editingController.text,
                  );
                  Navigator.pop(context); // Đóng hộp thoại
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

}
