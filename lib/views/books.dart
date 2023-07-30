import 'package:childbook/constants/constants.dart';
import 'package:childbook/views/addBooks.dart';
import 'package:childbook/widgets/textWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'edit/edit_book_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final Map<String, String> languageCollectionMap = {
    'English': 'ebooksenglish',
    'French': 'ebooksfrench',
    'Hausa': 'ebookhausa',
  };

  Future<void> deleteBook(String bookId, String collection) async {
    try {
      final CollectionReference booksCollection =
          FirebaseFirestore.instance.collection(collection);
      await booksCollection.doc(bookId).delete();
      print('Book deleted successfully');
    } catch (error) {
      print('Error deleting book: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primarycol,
        title: Center(
          child: TextWidget(
            text: "Ebooks",
            size: 16.sp,
            weight: FontWeight.w700,
            color: Colors.white,
            align: TextAlign.center,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              itemCount: languageCollectionMap.length,
              itemBuilder: (context, index) {
                final language = languageCollectionMap.keys.elementAt(index);
                final collection = languageCollectionMap[language]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: TextWidget(
                        text: language,
                        size: 14.sp,
                        weight: FontWeight.bold,
                        color: textcol,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(collection)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final books = snapshot.data!.docs;
                          return books.isEmpty
                              ? Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                  child: TextWidget(
                                    text: "No books found",
                                    size: 12.sp,
                                    color: subtextcol,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: books.length,
                                  itemBuilder: (context, index) {
                                    final book = books[index];
                                    final imageUrl = book['image'];
                                    final title = book['title'];
                                    final author = book['author'];

                                    return ListTile(
                                      leading: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Image.network(imageUrl),
                                      ),
                                      title: TextWidget(
                                        text: title,
                                        size: 14.sp,
                                        weight: FontWeight.w700,
                                        color: textcol,
                                      ),
                                      subtitle: TextWidget(
                                        text: author,
                                        size: 11.sp,
                                        weight: FontWeight.w500,
                                        color: subtextcol,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditBookScreen(
                                                    book: book,
                                                    collection: collection,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          InkWell(
                                            onTap: () {
                                              deleteBook(book.id, collection);
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: TextWidget(
                              text: "Error retrieving books",
                              size: 12.sp,
                              color: subtextcol,
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 2.h),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBooksScreen()),
          );
        },
        tooltip: "Add new ebook",
        backgroundColor: primarycol,
        child: const Icon(Icons.add),
      ),
    );
  }
}
