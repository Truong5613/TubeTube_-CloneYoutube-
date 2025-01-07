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

  Future<void> unsubscribeChannel({
    required String userId,
    required String currentUserId,
    required List<String> subscriptions,
    required WidgetRef ref, // Pass ref here to trigger refresh
  }) async {
    subscriptions.remove(currentUserId);
    await firestore!.collection("users").doc(userId).update({
      "subscriptions": subscriptions,
    });
  }

  Future<void> subscribeChannel({
    required String userId,
    required String currentUserId,
    required List subscriptions,
    required WidgetRef ref, // Pass ref here to trigger refresh
  }) async {
    // Prevent users from subscribing to themselves
    if (userId == currentUserId) {
      return;
    }
    subscriptions.add(currentUserId);
    await firestore!.collection("users").doc(userId).update({
      "subscriptions": subscriptions,
    });
    }
  }

