import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'src/screen/home_screen.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

Future<void> main() async {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  // maybe pass database to constructor of main page?
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final bookDao = database.bookDao;
  // for (var i = 1; i < 10000; i++) {
  //     await bookDao.insertBook(Book(i, "title", "author", 1234567890));
  //   }

  runApp(ProviderScope(
      child: MaterialApp(
          home: Scaffold(
    body: HomeScreen(bookDAO: bookDao),
  ))));
}
