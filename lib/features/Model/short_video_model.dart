class ShortVideoModel {
  final String caption;
  final String userId;
  final String shortVideo;
  final DateTime datePublished;
  final List likes;
  ShortVideoModel(
      {required this.caption,
      required this.userId,
      required this.shortVideo,
      required this.datePublished,
      required this.likes,});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'caption': caption,
      'userId': userId,
      'shortVideo': shortVideo,
      'datePublished': datePublished.millisecondsSinceEpoch,
      'likes': likes,
    };
  }

  factory ShortVideoModel.fromMap(Map<String, dynamic> map) {
    return ShortVideoModel(
      caption: map['caption'] as String,
      userId: map['userId'] as String,
      shortVideo: map['shortVideo'] as String,
      datePublished:
          DateTime.fromMillisecondsSinceEpoch(map['datePublished'] as int),
      likes: List.from(
        (map['likes'] as List),
      ),
    );
  }
}
