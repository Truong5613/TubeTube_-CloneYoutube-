import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/short_video_model.dart';

final shortVideoProvider = Provider((ref) => ShortVideoRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

class ShortVideoRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ShortVideoRepository({required this.auth, required this.firestore});

  Future<void> addShortVideoTofirestore({
    required String caption,
    required String Video,
    required DateTime datePublished,
    required String userId,
    required String shortvideoId,
  }) async {
    ShortVideoModel shortVideo = ShortVideoModel(
        caption: caption,
        userId: userId,
        likes: [],
        shortVideo: Video,
        datePublished: datePublished,
        shortvideoId: shortvideoId,
        type: 'short',
        isBanned: false,
        isHidden: false);
    await firestore
        .collection("shorts")
        .doc(shortvideoId)
        .set(shortVideo.toMap());
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


  Future<void> likeShortVideo({
    required List? likes,
    required shortvideoId,
    required currentUserId,
  }) async {
    if (likes!.contains(currentUserId)) {
      await FirebaseFirestore.instance
          .collection("shorts")
          .doc(shortvideoId)
          .update({
        "likes": FieldValue.arrayUnion([currentUserId])
      });
    }
    if (!likes.contains(currentUserId)) {
      await FirebaseFirestore.instance
          .collection("shorts")
          .doc(shortvideoId)
          .update({
        "likes": FieldValue.arrayRemove([currentUserId])
      });
    }
  }

  Future<void> updateShortVideoInFirestore({
    required String shortvideoId,
    required String caption,
  }) async {
    try {
      // Update details in "shorts" collection
      await firestore.collection("shorts").doc(shortvideoId).update({
        'caption': caption,
      });
    } catch (e) {
      throw Exception("Failed to update video: $e");
    }
  }

  Future<void> deleteShortVideo({
    required String userId,
    required String videoId,
  }) async {
    // Delete video from "shorts" collection
    await firestore.collection("shorts").doc(videoId).delete();

    // Update user video count
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
    // Toggle the 'isHidden' field of the video in "shorts" collection
    await firestore.collection("shorts").doc(videoId).update({
      'isHidden': !isHidden,
    });
  }

  // Toggle ban status of video (isBanned)
  Future<void> toggleBan({
    required String videoId,
    required bool isBanned,
  }) async {
    // Toggle the 'isBanned' field of the video in "shorts" collection
    await firestore.collection("shorts").doc(videoId).update({
      'isBanned': !isBanned,
    });
  }

}
