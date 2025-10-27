import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final List<String> images;
  final String videoUrl;
  final String mediaType;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.images,
    required this.videoUrl,
    required this.mediaType,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'],
      userId: map['userId'],
      userName: map['userName'],
      content: map['content'],
      images: List<String>.from(map['images'] ?? []),
      videoUrl: map['videoUrl'] ?? "",
      mediaType: map['mediaType'],
      likeCount: map['likeCount'],
      commentCount: map['commentCount'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'images': images,
      'videoUrl': videoUrl,
      'mediaType': mediaType,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt,
    };
  }
}
