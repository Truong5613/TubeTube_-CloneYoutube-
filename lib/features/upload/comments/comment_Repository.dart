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
  }) async {
    String commentId = const Uuid().v4();
    CommentModel comment = CommentModel(
        commentText: commentText,
        videoId: videoId,
        commentId: commentId,
        displayName: displayName,
        profilePic: profilePic, time: DateTime.now());
    await firestore.collection("comments").doc(commentId).set(comment.toMap());
  }
}