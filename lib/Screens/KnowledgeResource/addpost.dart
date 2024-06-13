import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostDialog extends StatefulWidget {
  @override
  _AddPostDialogState createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  List<String> selectedTags = [];
  List<File> _images = [];

  final List<String> allTags = [
    "UI/UX",
    "Vercel",
    "Webflow",
    "Flutter",
    "Programming",
    "Database Manager",
    "System Administrator",
    "Quality Assurance",
    "Service Assurance",
    // Add more tags as needed
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Post'),
      content: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 5, vertical: 24),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'TAGS',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ...selectedTags.map((tag) => _buildTag(tag)),
                          GestureDetector(
                            onTap: _addNewTag,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.transparent),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Add tag',
                                      style: TextStyle(color: Colors.black)),
                                  SizedBox(width: 4),
                                  Icon(Icons.add),
                                ],
                              ),
                            ),
                          ),
                          if (selectedTags.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTags.clear();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.transparent),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Clear',
                                        style: TextStyle(color: Colors.black)),
                                    SizedBox(width: 4),
                                    Icon(Icons.clear),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 24),
                  border: InputBorder.none,
                ),
                maxLines: null,
                minLines: 8,
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: 'Link',
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 24),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _addLink,
                  icon: Icon(
                    Icons.link,
                    size: 30,
                  ),
                  color: Colors.blue,
                  tooltip: 'Add Link',
                ),
                IconButton(
                  onPressed: _uploadImage,
                  icon: Icon(
                    Icons.image,
                    size: 30,
                  ),
                  color: Colors.blue,
                  tooltip: 'Upload Image',
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildImagePreview(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _addPost(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
        color: Colors.yellow[800],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_images.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Image.file(_images[index]),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else {
      return SizedBox();
    }
  }

  void _addLink() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String link = '';
        return AlertDialog(
          title: Text('Add Link'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter the link:'),
                TextField(
                  onChanged: (value) {
                    link = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter link here',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (Uri.parse(link).isAbsolute) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link added: $link'),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid link'),
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addNewTag() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTag = '';
        return AlertDialog(
          title: Text('Add New Tag'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choose from existing tags:'),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: allTags.map((tag) {
                      if (selectedTags.contains(tag)) {
                        return SizedBox();
                      } else {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTags.add(tag);
                            });
                          },
                          child: Chip(
                            label: Text(tag),
                            backgroundColor: Colors.yellow[800],
                            labelStyle: TextStyle(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.transparent),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
                SizedBox(height: 70),
                Text('If not in the choices, add new:'),
                TextField(
                  onChanged: (value) {
                    newTag = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter tag name',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (selectedTags
                    .any((tag) => tag.toLowerCase() == newTag.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This tag is already added'),
                    ),
                  );
                } else if (newTag.isNotEmpty) {
                  setState(() {
                    selectedTags.add(newTag);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  void _removeTag(String tag) {
    setState(() {
      selectedTags.remove(tag);
    });
  }

  void _uploadImage() async {
    File? imageFile = await _getImage();
    if (imageFile != null) {
      setState(() {
        _images.add(imageFile);
      });
    }
  }

  Future<File?> _getImage() async {
    final result = await showDialog<File>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    Navigator.pop(context, File(image.path));
                  }
                },
                child: Text("Take a Picture"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    Navigator.pop(context, File(image.path));
                  }
                },
                child: Text("Choose from Gallery"),
              ),
            ],
          ),
        );
      },
    );
    return result;
  }

  void _addPost(BuildContext context) async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String link = _linkController.text;

    if (title.isEmpty || description.isEmpty || selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill up all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      String? userName = user.displayName;

      // Upload images first
      List<String> imageUrls = await _uploadImages();

      // Add post with image URLs
      await FirebaseFirestore.instance.collection('knowledge_resource').add({
        'title': title,
        'description': description,
        'userId': userId,
        'userName': userName,
        'datePosted': Timestamp.now(),
        'tags': selectedTags,
        'link': link,
        'imageUrls': imageUrls,
        'status': 'accepted',
      });

      // Navigate back to the knowledge resource page
      Navigator.pop(context);
    } else {
      print('User is not authenticated.');
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    for (var image in _images) {
      String imageName = path.basename(image.path);
      Reference ref = FirebaseStorage.instance.ref().child('images/$imageName');

      UploadTask uploadTask = ref.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }
}
