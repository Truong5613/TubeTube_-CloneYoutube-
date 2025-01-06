import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/video_model.dart';

final longVideoProvider = Provider(
      (ref) => VideoRepository(firestore: FirebaseFirestore.instance),
);

class VideoRepository {
  FirebaseFirestore firestore;

  VideoRepository({
    required this.firestore,
  });

  uploadVideoToFirestore({
    required String videoUrl,
    required String thumbnail,
    required String title,
    required String videoId,
    required DateTime datePublished,
    required String userId,
    required String description,
  }) async {
    VideoModel video = VideoModel(
      videoUrl: videoUrl,
      thumbnail: thumbnail,
      title: title,
      datePublished: datePublished,
      views: 0,
      videoId: videoId,
      userId: userId,
      likes: [],
      type: "video", isHidden: false, isBanned: false,
      description: description,
    );
    await firestore.collection("videos").doc(videoId).set(video.toMap());
    DocumentReference userRef = firestore.collection("users").doc(userId);
    await firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (snapshot.exists) {
        int currentVideoCount = snapshot.get('videos') ?? 0;
        transaction.update(userRef, {'videos': currentVideoCount + 1});
      } else {
        // If the user document doesn't exist, initialize it
        transaction.set(userRef, {'videos': 1});
      }
    });
  }
  Future<void> updateVideoInFirestore({
    required String videoId,
    required String thumbnail,
    required String title,
    required String description,
  }) async {
    try {
      await firestore.collection("videos").doc(videoId).update({
        'thumbnail': thumbnail,
        'title': title,
        'description': description,
      });
    } catch (e) {
      throw Exception("Failed to update video: $e");
    }
  }
  Future<void> likeVideo({
    required List? likes,
    required videoId,
    required currentUserId,
  }) async {
    if (likes!.contains(currentUserId)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoId)
          .update({
        "likes": FieldValue.arrayUnion([currentUserId])
      });
    }
    if (!likes.contains(currentUserId)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoId)
          .update({
        "likes": FieldValue.arrayRemove([currentUserId])
      });
    }
  }
  Future<void> deleteVideo({
    required String userId,
    required String videoId,
  }) async {
    await firestore.collection("videos").doc(videoId).delete();
    DocumentReference userRef = firestore.collection("users").doc(userId);
    await firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (snapshot.exists) {
        int currentVideoCount = snapshot.get('videos') ?? 0;
        transaction.update(userRef, {'videos': currentVideoCount - 1});
      } else {
        // If the user document doesn't exist, initialize it
        transaction.set(userRef, {'videos': 1});
      }
    });

  }

  Future<void> toggleVisibility({
    required String videoId,
    required bool isHidden,
  }) async {
    await firestore.collection("videos").doc(videoId).update({
      'isHidden': !isHidden,
    });
  }

  Future<void> toggleBan({
    required String videoId,
    required bool isBanned,
  }) async {
    await firestore.collection("videos").doc(videoId).update({
      'isBanned': !isBanned,
    });
  }

}