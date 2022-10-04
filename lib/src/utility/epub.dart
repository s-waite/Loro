import 'dart:io';
import 'dart:developer' as developer;

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:loro/main.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/entity/book.dart';
import 'package:loro/src/database/database.dart';
import 'package:archive/archive_io.dart';

//TODO: create new posix filename and artist folder, copy file to folder with new name,
//ensure book hasnt already been added
// Add book info to database
// database column for relative path
// books folder path saved somewhere
// TODO: could store list of books in global riverpod that everything listens to
String logSource = 'epub.dart';

/// As an inherited widget, any widget that is a child of Epub can acess the bookNotifier;
class Epub {
  static Future<Map<String, String>> getMetadata(File epub) async {
    Map<String, String> metaData = {};
    var bytes = await epub.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);
    metaData['title'] = epubBook.Title.toString();
    metaData['author'] = epubBook.Author.toString();
    String? desc = epubBook.Schema?.Package?.Metadata?.Description?.toString();
    if (desc != null) {
      metaData['description'] = desc;
    } else {
      metaData['description'] = "";
    }
    return metaData;
  }

  static void loadEpub(
      File epub, ValueNotifier<List<Book>> bookNotifier, AppDatabase db) async {
    var metadata = await getMetadata(epub);
    String author = metadata['author']!;
    String title = metadata['title']!;
    String description = metadata['description']!;
    Directory bookDir = await createBookDir(author, title, "Loro Library");
    File bookInLibFile = await copyEpubToDir(epub, bookDir, author, title);
    String picPath = await copyCoverToDir(epub, bookDir);
    db.bookDao.insertBook(Book(
        title: title,
        authorName: author,
        bookDirPath: bookDir.path,
        coverPath: picPath,
        description: description));
    bookNotifier.value = await db.bookDao.getAllBooks();
  }

  static Future<File> copyEpubToDir(
      File epub, Directory bookDir, author, title) {
    String path = "${bookDir.path}/$author - $title.epub";
    return epub.copy(path);
  }

  static Future<String> copyCoverToDir(File epub, Directory dir) async {
    final inputFileStream = InputFileStream(epub.path);
    var bytes = await epub.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    final archive = ZipDecoder().decodeBuffer(inputFileStream);
    final String firstImageName =
        epubBook.Content!.Images!.values.first.FileName!.split("/").last;
    var firstImage = archive.files
        .where((element) => element.toString().contains(firstImageName))
        .first;
    String imageFiletype = firstImageName.split('.').last;
    firstImage
        .writeContent(OutputFileStream("${dir.path}/cover.$imageFiletype"));
    return ("${dir.path}/cover.$imageFiletype");
  }

//
//
//   static void loadEpub(
//
//   // Get metadata
//   // Use metadata to create book dir
//   // Copy book to dir
//       File epub, ValueNotifier<List<Book>> bookNotifier) async {
//     var bytes = await epub.readAsBytes();
//     EpubBook epubBook = await EpubReader.readBook(bytes);
//     String title = epubBook.Title.toString();
//     String author = epubBook.Author.toString();
//
//     // Copy book to correct folder after it has been created
//
//     LocalFileSystem fs = const LocalFileSystem();
//     createBookDir(author, title, fs);
//     // Copy the epub to the loro library
//     // String path = "${dir.path}/$author - $title.epub";
//     //   epub.copy(path);
//     //   final database =
//     //       await $FloorAppDatabase.databaseBuilder('app_database.db').build();
//     //   BookDAO bookDAO = database.bookDao;
//     //
//     //   bookDAO.insertBook(Book(title: title, authorName: author, path: path));
//     //   bookNotifier.value = await bookDAO.getAllBooks();
//     //
//     //   final inputFileStream = InputFileStream(epub.path);
//     //   final archive = ZipDecoder().decodeBuffer(inputFileStream);
//     //   final String firstImageName = epubBook.Content!.Images!.values.first.FileName!;
//     //   var firstImage = archive.findFile(firstImageName);
//     //   firstImage!.writeContent(OutputFileStream("${dir.path}/$firstImageName"));
//     //
//     //
//     // String userHome = Platform.environment['HOME'] ??
//     //     Platform.environment['USERPROFILE'] as String;
//     // String libraryPath = '$userHome/Loro Library';
//     // String bookPath = '$libraryPath/$author/$title';
//     // //
//     // fs.directory(bookPath).create(recursive: true);
//     // });
//   }
//
//   /// Returns a string formatted for filesystems
//   static String stringToFileName(String input) {
//     return input.replaceAll(RegExp(' '), "_");
//   }
//
  // Creates and returns the directory to store the book
  static Future<Directory> createBookDir(
      String author, String title, String libraryName) async {
    String userHome = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] as String;

    String bookPath = '$userHome/$libraryName/$author/$title';
    return Directory(bookPath).create(recursive: true);
  }
}
