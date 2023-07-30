import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditAudioScreen extends StatefulWidget {
  final dynamic audio;
  final String collection;

  const EditAudioScreen({
    Key? key,
    required this.audio,
    required this.collection,
  }) : super(key: key);

  @override
  _EditAudioScreenState createState() => _EditAudioScreenState();
}

class _EditAudioScreenState extends State<EditAudioScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController audioUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.audio['title'];
    authorController.text = widget.audio['author'];
    imageUrlController.text = widget.audio['image'];
    audioUrlController.text = widget.audio['audioUrl'];
  }

  File? _imageFile;
  File? _audioFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit AudioBook Screen',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  height: 115,
                  width: 115,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      CircleAvatar(
                        radius: 0.0,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: (_imageFile != null)
                            ? Image.file(
                                File(_imageFile!.path.toString()),
                                fit: BoxFit.cover,
                              ).image
                            : NetworkImage(widget.audio['image']),
                      ),
                      Positioned(
                        right: -16,
                        bottom: 0,
                        child: SizedBox(
                          height: 46,
                          width: 46,
                          child: GestureDetector(
                            onTap: getImage,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white),
                                child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: getAudio,
                child: TextField(
                  onTap: getAudio,
                  controller: audioUrlController,
                  decoration: const InputDecoration(
                    suffix: Icon(
                      Icons.audio_file,
                    ),
                    labelText: 'Audio URL',
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final title = titleController.text;
                    final author = authorController.text;
                    final imageUrl = imageUrlController.text;
                    final audioUrl = audioUrlController.text;

                    final bookId = widget.audio.id;
                    final collection = widget.collection;

                    final CollectionReference booksCollection =
                        FirebaseFirestore.instance.collection(collection);

                    await booksCollection.doc(bookId).update({
                      'title': title,
                      'author': author,
                      'image': imageUrl,
                      'audioUrl': audioUrl,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Audio updated successfully'),
                      ),
                    );

                    // Navigate back to the BooksScreen after updating the book
                    Navigator.pop(context);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update audio: $error'),
                      ),
                    );
                  }
                },
                child: const Text('Update Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['mp3'],
      allowMultiple: false,
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.first.path.toString());
        audioUrlController.text = _audioFile!.path
            .split('/')
            .last; // Display the selected audio file name
      });

      try {
        String audioUrl = await uploadAudioToFirestoreStorage(_audioFile!);

        final bookId = widget.audio.id;
        final collection = widget.collection;
        final CollectionReference booksCollection =
            FirebaseFirestore.instance.collection(collection);

        await booksCollection.doc(bookId).update({
          'audioUrl': audioUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio updated successfully'),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update audio: $error'),
          ),
        );
      }
    }
  }

  Future<String> uploadAudioToFirestoreStorage(File audioFile) async {
    final firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child('audio_files');

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final firebase_storage.UploadTask uploadTask =
        storageReference.child(fileName).putFile(audioFile);

    final firebase_storage.TaskSnapshot storageSnapshot =
        await uploadTask.whenComplete(() {});

    String audioUrl = await storageSnapshot.ref.getDownloadURL();

    return audioUrl;
  }

  Future getImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path.toString());
        // Update the image URL in the controller
        imageUrlController.text = ''; // Clear the previous URL
      });

      try {
        String imageUrl = await uploadImageToFirestoreStorage(_imageFile!);

        final bookId = widget.audio.id;
        final collection = widget.collection;
        final CollectionReference booksCollection =
            FirebaseFirestore.instance.collection(collection);

        await booksCollection.doc(bookId).update({
          'image': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio image updated successfully'),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update book image: $error'),
          ),
        );
      }
    }
  }

  Future<String> uploadImageToFirestoreStorage(File imageFile) async {
    final firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child('audio_images');

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final firebase_storage.UploadTask uploadTask =
        storageReference.child(fileName).putFile(imageFile);

    final firebase_storage.TaskSnapshot storageSnapshot =
        await uploadTask.whenComplete(() {});

    String imageUrl = await storageSnapshot.ref.getDownloadURL();

    return imageUrl;
  }
}
