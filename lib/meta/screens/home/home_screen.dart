import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/app/constants/constants.dart';
import 'package:socialmedia/app/routes/app_route.dart';
import 'package:socialmedia/core/notifiers/auth_provider.dart';
import 'package:socialmedia/core/notifiers/post_provider.dart';
import 'package:socialmedia/meta/screens/home/post_image.dart';
import 'package:socialmedia/meta/screens/home/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
  }

  void showCommentsBottomSheet(BuildContext context, String postId) {
    final commentProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Comments",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: commentProvider.getCommentsStream(postId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text("No comments yet. Be the first!"),
                          );
                        }
                        return ListView.builder(
                          controller: controller,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var data =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return ListTile(
                              title: Text(
                                data['userName'],
                                style: const TextStyle(
                                  color: CColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                              subtitle: Text(
                                data['commentText'],
                                style: const TextStyle(
                                  color: CColors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: authProvider.userId == data['userId']
                                    ? () => commentProvider.deleteComment(
                                        postId: postId,
                                        commentId: data['commentId'],
                                      )
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Add a comment...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              final userId = authProvider.userId;
                              final userName = await authProvider.getUserName();
                              if (commentController.text.isNotEmpty) {
                                await commentProvider.addComment(
                                  postId: postId,
                                  userId: userId,
                                  userName: userName.toString(),
                                  commentText: commentController.text.trim(),
                                );
                                commentController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final postProv = Provider.of<PostProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    Text(
                      "Social Media",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {},
                      child: const Icon(Icons.exit_to_app_rounded, size: 30),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: postProv.getPostsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final posts = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: posts.length,
                      itemBuilder: (context, i) {
                        final p = posts[i];

                        return Card(
                          elevation: 2,
                          color: CColors.cardbg,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.blueGrey,
                                      child: Text(
                                        p.userName.isNotEmpty
                                            ? p.userName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.userName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: CColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          timeAgo(
                                            p.createdAt,
                                          ), // Firestore Timestamp -> DateTime
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: CColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: CColors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (p.mediaType == 'images' &&
                                    p.images.isNotEmpty)
                                  PostImageSlider(images: p.images),

                                if (p.mediaType == 'video' &&
                                    p.videoUrl.isNotEmpty)
                                  VideoPlayerWidget(videoUrl: p.videoUrl),

                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        FutureBuilder<bool>(
                                          future: postProv.checklikePost(
                                            p.postId,
                                            auth.userId,
                                          ),
                                          builder: (context, snapshot) {
                                            bool isLiked =
                                                snapshot.data ??
                                                false; // Default to false if not yet loaded

                                            return IconButton(
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.thumb_up_alt
                                                    : Icons
                                                          .thumb_up_alt_outlined,
                                                color: CColors.white,
                                              ),
                                              onPressed: () async {
                                                await postProv.likePost(
                                                  p.postId,
                                                  auth.userId,
                                                );

                                                setState(() {});
                                              },
                                            );
                                          },
                                        ),

                                        Text(
                                          '${p.likeCount}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: CColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.comment_outlined,
                                            color: CColors.white,
                                          ),
                                          onPressed: () {
                                            showCommentsBottomSheet(
                                              context,
                                              p.postId,
                                            );
                                          },
                                        ),
                                        Text(
                                          '${p.commentCount}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: CColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CColors.black,
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.uploadRoute);
        },
        child: const Icon(Icons.upload, size: 30, color: CColors.white),
      ),
    );
  }
}
