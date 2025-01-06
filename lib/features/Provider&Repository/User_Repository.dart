import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Provider&Repository/user_provider.dart';
final editSettingsProvider = Provider(
      (ref) => EditSettingsField(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class EditSettingsField {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  EditSettingsField({
    required this.firestore,
    required this.auth,
  });

  // Helper function to update user data and their comments
  Future<void> updateUserDataAndComments(WidgetRef ref, String field, String value) async {
    String userId = auth.currentUser!.uid;

    // Check if the current userId matches
    if (userId == auth.currentUser!.uid) {
      // Update the user's own data
      await firestore.collection("users").doc(userId).update({
        field: value,
      });

      // If the updated field is displayName, update all comments made by the user
      if (field == "displayName") {
        // Update displayName in all comments where the userId matches
        await firestore.collection("comments")
            .where("uid", isEqualTo: userId)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              "displayName": value, // Update the display name in the comment
            });
          }
        });
      }

      // Refresh the user data after the update
      ref.refresh(currentUserProvider);
    }
  }

  // Edit display name and update comments
  editDisplayName(WidgetRef ref, String displayName) async {
    await updateUserDataAndComments(ref, "displayName", displayName);
  }

  editusername(WidgetRef ref, String username) async {
    await firestore.collection("users").doc(auth.currentUser!.uid).update({
      "username": username,
    });
    // Refresh the user data after the update
    ref.refresh(currentUserProvider);
  }

  editDescription(WidgetRef ref, String description) async {
    await firestore.collection("users").doc(auth.currentUser!.uid).update({
      "description": description,
    });
    // Refresh the user data after the update
    ref.refresh(currentUserProvider);
  }
}