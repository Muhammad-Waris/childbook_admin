import 'package:childbook/constants/constants.dart';
import 'package:childbook/views/addAudio.dart';
import 'package:childbook/views/edit/edit_audio_screen.dart';
import 'package:childbook/views/edit/edit_book_screen.dart';
import 'package:childbook/widgets/textWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AudiosScreen extends StatefulWidget {
  const AudiosScreen({Key? key}) : super(key: key);

  @override
  State<AudiosScreen> createState() => _AudiosScreenState();
}

class _AudiosScreenState extends State<AudiosScreen> {
  final Map<String, String> languageCollectionMap = {
    'English': 'audiosEnglish',
    'French': 'audiosFrench',
    'Hausa': 'audiosHausa',
  };

  Future<void> deleteAudio(String audioId, String collection) async {
    try {
      final CollectionReference audiosCollection =
          FirebaseFirestore.instance.collection(collection);
      await audiosCollection.doc(audioId).delete();
      print('Audio deleted successfully');
    } catch (error) {
      print('Error deleting audio: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primarycol,
        title: Center(
          child: TextWidget(
            text: "AudioBooks",
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
                          final audios = snapshot.data!.docs;
                          return audios.isEmpty
                              ? Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                  child: TextWidget(
                                    text: "No audios found",
                                    size: 12.sp,
                                    color: subtextcol,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: audios.length,
                                  itemBuilder: (context, index) {
                                    final audio = audios[index];
                                    final imageUrl = audio['image'];
                                    final title = audio['title'];
                                    final author = audio['author'];
                                    final audioUrl = audio['audioUrl'];

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
                                                      EditAudioScreen( collection: collection, audio: audio,)
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
                                                deleteAudio(
                                                    audio.id, collection);
                                              },
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ));
                                  },
                                );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: TextWidget(
                              text: "Error retrieving audios",
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
            MaterialPageRoute(builder: (context) => const AddAudioScreen()),
          );
        },
        tooltip: "Add new audio",
        backgroundColor: primarycol,
        child: const Icon(Icons.add),
      ),
    );
  }
}
