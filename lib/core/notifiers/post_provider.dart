import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/core/notifiers/auth_provider.dart';
import '../models/post_model.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PostModel> _posts = [];
  bool _isUploading = false;

  List<PostModel> get posts => _posts;
  bool get isUploading => _isUploading;

  void fetchPosts() {
    _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _posts = snapshot.docs
              .map((d) => PostModel.fromMap(d.data()))
              .toList();
          notifyListeners();
        });
  }

  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<String> addPost({
    required String content,
    required context,
    List<String>? imageFileurls,
    String? videoFileurl,
    String mediaType = "text",
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = await authProvider.getUserID();
    final userName = await authProvider.getUserName();

    try {
      _isUploading = true;
      notifyListeners();

      // List<String> imageUrls = [];
      // String videoUrl = "";

      // if (mediaType == "images" &&
      //     imageFiles != null &&
      //     imageFiles.isNotEmpty) {
      //   imageUrls = await FirebaseStorageHelper.uploadMultipleImages(
      //     imageFiles,
      //     userId.toString(),
      //   );
      // } else
      // if (mediaType == "video" && videoFile != null) {
      //   videoUrl = await FirebaseStorageHelper.uploadSingleFile(
      //     videoFile,
      //     'posts/$userId/videos',
      //   );
      // }

      final postRef = _firestore.collection('posts').doc();
      await postRef.set({
        'postId': postRef.id,
        'userId': userId,
        'userName': userName,
        'content': content,
        'images': imageFileurls,
        'videoUrl': videoFileurl,
        'mediaType': mediaType,
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isUploading = false;
      notifyListeners();
      return "success";
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final likeDoc = await postRef.collection('likes').doc(userId).get();

    if (!likeDoc.exists) {
      await postRef.collection('likes').doc(userId).set({
        'likedAt': FieldValue.serverTimestamp(),
      });
      await postRef.update({'likeCount': FieldValue.increment(1)});
    } else {
      await postRef.collection('likes').doc(userId).delete();
      await postRef.update({'likeCount': FieldValue.increment(-1)});
    }
  }

  Future<bool> checklikePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final likeDoc = await postRef.collection('likes').doc(userId).get();
    if (likeDoc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String commentText,
  }) async {
    try {
      String commentId = _firestore.collection('posts').doc().id;

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
            'commentId': commentId,
            'userId': userId,
            'userName': userName,
            'commentText': commentText,
            'createdAt': FieldValue.serverTimestamp(),
          });

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint("Error adding comment: $e");
      rethrow;
    }
  }

  /// ✅ Delete Comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      debugPrint("Error deleting comment: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
