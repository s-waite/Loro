import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'src/screen/home_screen.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:english_words/english_words.dart';

final myProvider = Provider((ref) {
  return $FloorAppDatabase.databaseBuilder('app_database.db').build();
});

Future<void> main() async {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Loro');
    setWindowMinSize(const Size(600, 300));
    setWindowMaxSize(Size.infinite);
  }

  ValueNotifier<List<Book>> allBooks = ValueNotifier<List<Book>>([]);
  List<Book> selectedBooks = [];
  ValueNotifier<Book> activeBook = ValueNotifier<Book>(Book(
      title: "",
      authorName: "",
      bookDirPath: "",
      coverPath: "",
      description: ""));

  $FloorAppDatabase.databaseBuilder('app_database.db').build().then((db) {
    runApp(MaterialApp(
        home: Scaffold(
            body: Loro(
                child: HomeScreen(),
                db: db,
                allBooks: allBooks,
                selectedBooks: selectedBooks,
                activeBook: activeBook))));
  });
  // maybe pass database to constructor of main page?
  // for (var i = 1; i < 10000; i++) {
  //   String title =
  //       nouns[Random().nextInt(1000)] + " " + nouns[Random().nextInt(1000)];
  //   String author =
  //       nouns[Random().nextInt(1000)] + " " + nouns[Random().nextInt(1000)];
  //   await bookDao.insertBook(Book(i, title, author, 1234567890));
  // }
}

class Loro extends InheritedWidget {
  final AppDatabase db;
  final ValueNotifier<List<Book>> allBooks;
  final List<Book> selectedBooks;
  final ValueNotifier<Book> activeBook;

  const Loro(
      {super.key,
      required super.child,
      required this.db,
      required this.allBooks,
      required this.selectedBooks,
      required this.activeBook});

  @override
  bool updateShouldNotify(Loro oldWidget) {
    return (db != oldWidget.db || selectedBooks != oldWidget.selectedBooks);
  }

  static Loro of(BuildContext context) {
    final Loro? result = context.dependOnInheritedWidgetOfExactType<Loro>();
    assert(result != null, 'No Epub found in context');
    return result!;
  }
}
