import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubetube/features/Model/comment_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentProvider = Provider(
  (ref) => CommentReepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class CommentReepository {
  final FirebaseFirestore firestore;

  CommentReepository({required this.firestore});

  Future<void> uploadCommentToFirestore({
    required String commentText,
    required String videoId,
    required String displayName,
    required String profilePic,
    required String uid,
  }) async {
    String commentId = const Uuid().v4();
    CommentModel comment = CommentModel(
        commentText: commentText,
        videoId: videoId,
        commentId: commentId,
        displayName: displayName,
        profilePic: profilePic,
        time: DateTime.now(),
        uid: uid);
    await firestore.collection("comments").doc(commentId).set(comment.toMap());
  }

  // Xóa bình luận
  Future<void> deleteCommentFromFirestore(String commentId) async {
    try {
      await firestore.collection("comments").doc(commentId).delete();
    } catch (e) {
      throw Exception("Không thể xóa bình luận: $e");
    }
  }

  // Sửa bình luận
  Future<void> editCommentInFirestore({
    required String commentId,
    required String newCommentText,
  }) async {
    try {
      await firestore.collection("comments").doc(commentId).update({
        'commentText': newCommentText,
        'time': DateTime.now(), // Cập nhật thời gian sửa
      });
    } catch (e) {
      throw Exception("Không thể sửa bình luận: $e");
    }
  }
}
