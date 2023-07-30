import 'package:childbook/constants/constants.dart';
import 'package:childbook/views/audios.dart';
import 'package:childbook/views/books.dart';
import 'package:flutter/material.dart';

class BottomNavigationHolder extends StatefulWidget {
  const BottomNavigationHolder({super.key});

  @override
  State<BottomNavigationHolder> createState() => _BottomNavigationHolderState();
}

class _BottomNavigationHolderState extends State<BottomNavigationHolder> {
  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const List<Widget> pages = <Widget>[BooksScreen(), AudiosScreen()];

    return Scaffold(
      body: Center(
        child: pages.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book_online_rounded,
              size: 25,
            ),
            label: 'eBooks',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.audio_file,
              size: 25,
            ),
            label: 'Audiobooks',
          ),
        ],
        currentIndex: selectedIndex,
        unselectedItemColor: subtextcol,
        selectedItemColor: primarycol,
        onTap: onItemTapped,
      ),
    );
  }
}
