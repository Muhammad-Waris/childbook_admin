import 'dart:io';

import 'package:childbook/constants/constants.dart';
import 'package:childbook/views/progressPopup.dart';
import 'package:childbook/widgets/textWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AddBooksScreen extends StatefulWidget {
  const AddBooksScreen({Key? key}) : super(key: key);

  @override
  State<AddBooksScreen> createState() => _AddBooksScreenState();
}

class _AddBooksScreenState extends State<AddBooksScreen> {
  TextEditingController _titlecontroller = TextEditingController();
  TextEditingController _authorcontroller = TextEditingController();
  File? _imageFile;
  File? _bookFile;
  String _selectedLanguage = 'English'; // Default selected language

  final Map<String, String> languageCollectionMap = {
    'English': 'ebooksenglish',
    'French': 'ebooksfrench',
    'Hausa': 'ebookhausa',
  };

  Future<void> saveBookToFirestore() async {
    String imageUrl = "";
    String pdfUrl = "";
    ProgressPopup(context);

    if (_imageFile != null) {
      FirebaseStorage storage = FirebaseStorage.instance;

      Reference ref = storage
          .ref('ebooks')
          .child(DateTime.now().microsecondsSinceEpoch.toString());

      await ref.putFile(File(_imageFile!.path));
      imageUrl = await ref.getDownloadURL();
      print(imageUrl);
    }

    if (_bookFile != null) {
      FirebaseStorage storage = FirebaseStorage.instance;

      Reference ref = storage
          .ref('ebooks')
          .child(DateTime.now().microsecondsSinceEpoch.toString());

      await ref.putFile(File(_bookFile!.path));
      pdfUrl = await ref.getDownloadURL();
      print(pdfUrl);
    }

    final CollectionReference booksRef = FirebaseFirestore.instance
        .collection(languageCollectionMap[_selectedLanguage]!);

    await booksRef.add({
      'title': _titlecontroller.text,
      'author': _authorcontroller.text,
      'pdfUrl': pdfUrl,
      'image': imageUrl
    });

    Navigator.pop(context);
    _authorcontroller.clear();
    _titlecontroller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Uploaded Successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primarycol,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            : const NetworkImage(
                                "https://media.gettyimages.com/id/157482029/photo/stack-of-books.jpg?s=612x612&w=gi&k=20&c=_Yaofm8sZLZkKs1eMkv-zhk8K4k5u0g0fJuQrReWfdQ="),
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
                                    color: primarycol,
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
              SizedBox(height: 3.h),
              TextFormField(
                controller: _titlecontroller,
                decoration: const InputDecoration(
                  hintText: "Enter title",
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 3.h),
              TextFormField(
                controller: _authorcontroller,
                decoration: const InputDecoration(
                  hintText: "Enter Author",
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 3.h),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                ),
                items: languageCollectionMap.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
              ),
              SizedBox(height: 3.h),
              InkWell(
                onTap: getBook,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Upload PDF File"),
                        Icon(
                          Icons.upload_file,
                          color: subtextcol,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              InkWell(
                onTap: saveBookToFirestore,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: primarycol),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    child: Center(
                      child: TextWidget(
                        text: "Submit",
                        size: 14.sp,
                        weight: FontWeight.w600,
                        color: Colors.white,
                        align: TextAlign.center,
                      ),
                    ),
                  ),
                ),
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
      });
    }
  }

  Future getBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        type: FileType.custom);

    if (result != null) {
      setState(() {
        _bookFile = File(result.files.single.path.toString());
      });
    }
  }
}
