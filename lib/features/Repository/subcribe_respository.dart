import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscribeChannelProvider = Provider(
  (ref) => Subscribe(
    firestore: FirebaseFirestore.instance,
  ),
);

class Subscribe {
  FirebaseFirestore? firestore;

  Subscribe({
    required this.firestore,
  });

  Future<void> subscribeChannel({
    required String userId,
    required String currentUserId,
    required List subscriptions,
  }) async {
    // Ngăn người dùng tự đăng ký chính mình
    if (userId == currentUserId) {
      return;
    }

    if (!subscriptions.contains(currentUserId)) {
      // Thêm currentUserId nếu chưa đăng ký
      await firestore!.collection("users").doc(userId).update(
        {
          "subscriptions": FieldValue.arrayUnion([currentUserId]),
        },
      );
    } else {
      // Gỡ bỏ currentUserId nếu đã đăng ký
      await firestore!.collection("users").doc(userId).update(
        {
          "subscriptions": FieldValue.arrayRemove([currentUserId]),
        },
      );
    }
  }
}
