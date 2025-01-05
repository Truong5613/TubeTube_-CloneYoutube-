import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentText;
  final String videoId;
  final String commentId;
  final String displayName;
  final String profilePic;
  final DateTime time;
  final String uid;

  CommentModel({
    required this.commentText,
    required this.videoId,
    required this.commentId,
    required this.displayName,
    required this.profilePic,
    required this.time,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'commentText': commentText,
      'videoId': videoId,
      'commentId': commentId,
      'displayName': displayName,
      'profilePic': profilePic,
      'time': time,
      'uid': uid,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentText: map['commentText'] as String,
      videoId: map['videoId'] as String,
      commentId: map['commentId'] as String,
      displayName: map['displayName'] as String,
      profilePic: map['profilePic'] as String,
      time: map["time"] is Timestamp
          ? (map["time"] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(
        map["time"] as int,
      ),
      uid: map['uid'] as String,
    );
  }
}
