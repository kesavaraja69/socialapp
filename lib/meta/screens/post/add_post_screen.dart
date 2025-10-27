import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/app/constants/constants.dart';
import 'package:socialmedia/core/notifiers/post_provider.dart';
import 'package:socialmedia/meta/widgets/custom_button.dart';
import 'package:socialmedia/meta/widgets/custom_snackbar.dart';
import 'package:socialmedia/meta/widgets/custom_textfield.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  late TextEditingController _contentController;
  late TextEditingController _imgController;
  late TextEditingController _videoUrlController;
  String mediaType = 'text';
  List<File> imageFiles = [];
  List<String> imageUrls = [];

  File? videoFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _imgController = TextEditingController();
    _videoUrlController = TextEditingController();
  }

  Future<bool> _requestStoragePermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // For Android 13 and above
      if (await Permission.photos.isDenied ||
          await Permission.videos.isDenied) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          status = await Permission.videos.request();
        }
      } else {
        status = PermissionStatus.granted;
      }
    } else {
      status = await Permission.photos.request();
    }

    return status.isGranted;
  }

  Future<void> pickImages() async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission && mounted) {
      SnackbarUtil.show(context, "Storage permission denied");
      return;
    }

    List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        imageFiles = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> pickVideo() async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission && mounted) {
      SnackbarUtil.show(context, "Storage permission denied");

      return;
    }

    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        videoFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _imgController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                "Write Content here : ",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ),
            CustomTextField(
              hintText: "Write something...",
              controller: _contentController,
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Select Media Type: ",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                ),
                DropdownButton<String>(
                  value: mediaType,
                  items: [
                    DropdownMenuItem(value: 'text', child: Text('Text Only')),
                    DropdownMenuItem(value: 'images', child: Text('Images')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      mediaType = value!;
                      imageFiles.clear();
                      videoFile = null;
                    });
                  },
                ),
              ],
            ),
            if (mediaType == 'images')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6),

                  TextField(
                    controller: _imgController,
                    decoration: InputDecoration(
                      labelText: 'Enter Image URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (_imgController.text.isNotEmpty) {
                            setState(() {
                              imageUrls.add(_imgController.text.trim());
                              _imgController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  imageUrls.isEmpty
                      ? Text(
                          "No images added yet",
                          style: TextStyle(color: Colors.grey),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(imageUrls[index]),
                              ),
                              title: Text(
                                imageUrls[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    imageUrls.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),

            // if (mediaType == 'video')
            //   Column(
            //     children: [
            //       SizedBox(height: 6),
            //       CustomButton(
            //         text: "Select Video",
            //         widthFactor: 1.5,
            //         gradientColors: [CColors.black, CColors.black],
            //         textColor: CColors.white,
            //         onPressed: pickVideo,
            //       ),
            //       if (videoFile != null)
            //         Padding(
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 12,
            //             vertical: 6,
            //           ),
            //           child: Text(
            //             'Video Selected: ${videoFile!.path.split('/').last}',
            //             style: TextStyle(
            //               fontSize: 17,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //     ],
            //   ),
            if (mediaType == 'video')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  TextField(
                    controller: _videoUrlController,
                    decoration: InputDecoration(
                      labelText: 'Enter Video URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _videoUrlController.clear();
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.url,
                  ),

                  const SizedBox(height: 12),

                  if (_videoUrlController.text.isNotEmpty)
                    Text(
                      'Video URL: ${_videoUrlController.text}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: CustomButton(
                text: "Upload Post",
                widthFactor: 1.5,
                gradientColors: [CColors.black, CColors.black],
                textColor: CColors.white,
                onPressed: () async {
                  final provider = Provider.of<PostProvider>(
                    context,
                    listen: false,
                  );
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(child: CircularProgressIndicator()),
                  );
                  await provider
                      .addPost(
                        context: context,
                        content: _contentController.text,
                        imageFileurls: imageUrls,
                        videoFileurl: _videoUrlController.text,
                        mediaType: mediaType,
                      )
                      .then((result) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (result == "success") {
                            SnackbarUtil.show(
                              context,
                              "Post uploaded successfully!",
                            );
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                            SnackbarUtil.show(context, 'Error: $result');
                          }
                        }
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
