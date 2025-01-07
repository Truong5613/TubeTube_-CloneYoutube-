class ShortVideoModel {
  final String shortvideoId;  // Video ID
  final String caption;  // Caption for the video
  final String userId;  // ID of the user who uploaded the video
  final String shortVideo;  // URL or path of the video
  final DateTime datePublished;  // Date when the video was published
  final List likes;  // List of likes for the video
  final String type;  // Type of video (e.g., 'short', 'full', etc.)
  final bool isHidden;
  final bool isBanned;
  // Constructor with named parameters
  ShortVideoModel({
    required this.shortvideoId,
    required this.caption,
    required this.userId,
    required this.shortVideo,
    required this.datePublished,
    required this.likes,
    required this.type,
    required this.isHidden,
    required this.isBanned,
  });

  // Convert the object to a Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'shortvideoId': shortvideoId,
      'caption': caption,
      'userId': userId,
      'shortVideo': shortVideo,
      'datePublished': datePublished.millisecondsSinceEpoch,
      'likes': likes,
      'type': type,
      'isHidden': isHidden,
      'isBanned': isBanned,
    };
  }

  // Create an instance from a Map
  factory ShortVideoModel.fromMap(Map<String, dynamic> map) {
    return ShortVideoModel(
      shortvideoId: map['shortvideoId'] as String,
      caption: map['caption'] as String,
      userId: map['userId'] as String,
      shortVideo: map['shortVideo'] as String,
      datePublished: DateTime.fromMillisecondsSinceEpoch(map['datePublished'] as int),
      likes: List.from(map['likes'] as List),
      type: map['type'] as String,
      isHidden: map['isHidden'] as bool,
      isBanned: map['isBanned'] as bool,
    );
  }
}
