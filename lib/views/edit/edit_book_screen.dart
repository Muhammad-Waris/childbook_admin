import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditBookScreen extends StatefulWidget {
  final dynamic book;
  final String collection;

  const EditBookScreen({Key? key, required this.book, required this.collection})
      : super(key: key);

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController pdfUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.book['title'];
    authorController.text = widget.book['author'];
    imageUrlController.text = widget.book['image'];
    pdfUrlController.text = widget.book['pdfUrl'];
  }

  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Book Screen',
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
                            : NetworkImage(widget.book['image']),
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
                onTap: getBook,
                child: TextField(
                  onTap: getBook,
                  controller: pdfUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Pdf URL',
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
                    final pdfUrl = pdfUrlController.text;

                    final bookId = widget.book.id;
                    final collection = widget.collection;

                    final CollectionReference booksCollection =
                        FirebaseFirestore.instance.collection(collection);

                    await booksCollection.doc(bookId).update({
                      'title': title,
                      'author': author,
                      'image': imageUrl,
                      'pdfUrl': pdfUrl,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Book updated successfully'),
                      ),
                    );

                    // Navigate back to the BooksScreen after updating the book
                    Navigator.pop(context);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update book: $error'),
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

        final bookId = widget.book.id;
        final collection = widget.collection;
        final CollectionReference booksCollection =
            FirebaseFirestore.instance.collection(collection);

        await booksCollection.doc(bookId).update({
          'image': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book image updated successfully'),
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
        firebase_storage.FirebaseStorage.instance.ref().child('book_images');

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final firebase_storage.UploadTask uploadTask =
        storageReference.child(fileName).putFile(imageFile);

    final firebase_storage.TaskSnapshot storageSnapshot =
        await uploadTask.whenComplete(() {});

    String imageUrl = await storageSnapshot.ref.getDownloadURL();

    return imageUrl;
  }

  Future getBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        type: FileType.custom);

    if (result != null) {
      setState(() {});
    }
  }
}
