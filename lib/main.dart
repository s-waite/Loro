import 'dart:math';

import 'package:flutter/material.dart';
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

  $FloorAppDatabase.databaseBuilder('app_database.db').build().then((db) {
    runApp(ProviderScope(
        child: AppDb(
            db: db,
            child: MaterialApp(
                home: Scaffold(
              body: HomeScreen(),
            )))));
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

class AppDb extends InheritedWidget {
  final AppDatabase db;

  const AppDb({super.key, required super.child, required this.db});

  @override
  bool updateShouldNotify(AppDb oldWidget) => db != oldWidget.db;

  static AppDb of(BuildContext context) {
    final AppDb? result = context.dependOnInheritedWidgetOfExactType<AppDb>();
    assert(result != null, 'No Epub found in context');
    return result!;
  }
}
