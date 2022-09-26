import 'package:flutter/material.dart';
import 'src/screen/home_screen.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

Future<void> main() async {
  debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  // maybe pass database to constructor of main page?
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final bookDao = database.bookDao;

  runApp(MaterialApp(
      home: Scaffold(
    body: HomeScreen(bookDAO: bookDao),
  )));
}
