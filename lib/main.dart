import 'dart:math';
import 'package:loro/src/entity/user.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loro/src/screen/login_screen.dart';
import 'package:loro/src/screen/login_screen.dart';
import 'package:window_size/window_size.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'src/screen/home_screen.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:english_words/english_words.dart';
import 'package:loro/src/resources/colors.dart' as nw;
import 'package:loro/src/utility/password.dart' as pw;

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

  // Run the app after the database is built
  $FloorAppDatabase.databaseBuilder('app_database.db').build().then((db) async {
    // db.userDao.insertUser(User(username: "sam", password: pw.hashStrAndB64Encode("password", pw.generateSalt())));
    print(await pw.verifyPasswordHashedSalted("sam", "password2", db));
    runApp(MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.

        errorColor: nw.danger,
        colorScheme: ColorScheme.light(
            error: nw.danger, primary: nw.primary, secondary: nw.warning),

        fontFamily: 'Rubik',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) {
          return Scaffold(
              body: Loro(
            // child: HomeScreen(),
            child: Center(
              child: Container(
                width: 200,
                alignment: Alignment.center,
                child: LoginForm(),
              ),
            ),
            db: db,
            allBooks: allBooks,
            selectedBooks: selectedBooks,
            activeBook: activeBook,
          ));
        },
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) {
          return Scaffold(
              body: Loro(
            child: HomeScreen(),
            db: db,
            allBooks: allBooks,
            selectedBooks: selectedBooks,
            activeBook: activeBook,
          ));
        },
      },
    ));
  });
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
