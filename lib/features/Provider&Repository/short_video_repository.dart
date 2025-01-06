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
        type: 'short');
    await firestore.collection("shorts").add(shortVideo.toMap());
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
}
