import 'dart:io';
import 'dart:developer' as developer;

import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:loro/main.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/entity/book.dart';
import 'package:mime/mime.dart';
import 'package:archive/archive_io.dart';
import 'package:loro/src/database/database.dart';

//TODO: create new posix filename and artist folder, copy file to folder with new name,
//ensure book hasnt already been added
// Add book info to database
// database column for relative path
// books folder path saved somewhere
String logSource = 'epub.dart';

class Epub {
  static void loadEpub(File epub) async {
    var bytes = await epub.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);
    String title = epubBook.Title.toString();
    String author = epubBook.Author.toString();

    // Copy book to correct folder after it has been created
    await createBookDir(author, title).then((dir) async {
      // Copy the epub to the loro library
      String path = "${dir.path}/$author - $title.epub";
      epub.copy(path);
      final database =
          await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      BookDAO bookDAO = database.bookDao;

bookDAO.insertBook(Book(title: title, authorName: author, path: path));
    });
  }

  /// Returns a string formatted for filesystems
  static String stringToFileName(String input) {
    return input.replaceAll(RegExp(' '), "_");
  }

  // Creates and returns the directory to store the book
  static Future<Directory> createBookDir(String author, String title) async {
    String userHome = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] as String;

    String libraryPath = '$userHome/Loro Library';
    var libraryDir = Directory(libraryPath);
    String authorPath = '$libraryPath/$author';
    var authorDir = Directory(authorPath);

    // Create loro library folder
    if (!await libraryDir.exists()) {
      await libraryDir.create().whenComplete(() async {
        if (!await authorDir.exists()) {
          await authorDir.create();
          developer.log('Creating authorDirdir ${authorDir.path}',
              name: logSource);
        }
      });
      developer.log('Creating library dir ${libraryDir.path}', name: logSource);
    }
    return authorDir;
  }
}
