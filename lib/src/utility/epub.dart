import 'dart:io';
import 'dart:developer' as developer;

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:loro/main.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/entity/book.dart';
import 'package:loro/src/database/database.dart';
import 'package:archive/archive_io.dart';

//ensure book hasnt already been added
// Add book info to database
// database column for relative path
// books folder path saved somewhere
String logSource = 'epub.dart';
String ps = Platform.pathSeparator;

class Epub {
  Epub._();

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
    String dateAdded = DateTime.now().toString();
    int sizeInKb = bookInLibFile.lengthSync();
    db.bookDao.insertBook(Book(
        title: title,
        authorName: author,
        bookDirPath: bookDir.path,
        coverPath: picPath,
        description: description,
        dateAdded: dateAdded,
        sizeInKb: sizeInKb));
    bookNotifier.value = await db.bookDao.getAllBooks();
  }

  static Future<File> copyEpubToDir(
      File epub, Directory bookDir, author, title) {
    String path = "${bookDir.path}$ps$author - $title.epub";
    return epub.copy(path);
  }

  static Future<String> copyCoverToDir(File epub, Directory dir) async {
    final inputFileStream = InputFileStream(epub.path);
    var bytes = await epub.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    final archive = ZipDecoder().decodeBuffer(inputFileStream);
    final String firstImageName =
        epubBook.Content!.Images!.values.first.FileName!.split(ps).last;
    var firstImage = archive.files
        .where((element) => element.toString().contains(firstImageName))
        .first;
    String imageFiletype = firstImageName.split('.').last;
    firstImage
        .writeContent(OutputFileStream("${dir.path}${ps}cover.$imageFiletype"));
    return ("${dir.path}${ps}cover.$imageFiletype");
  }

  static Future<Directory> createBookDir(
      String author, String title, String libraryName) async {
    String userHome = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] as String;

    String bookPath = '$userHome$ps$libraryName$ps$author$ps$title';
    return Directory(bookPath).create(recursive: true);
  }
}
