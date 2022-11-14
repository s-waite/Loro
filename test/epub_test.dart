import 'package:loro/src/utility/epub.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  File epubFile = File('test/moby-dick.epub');
  test('Metadata is pulled from epub', () async {
    var metadata = await Epub.getMetadata(epubFile);
    expect(metadata['author'] == 'Herman Melville', true);
    expect(metadata['title'] == 'Moby-Dick', true);
  });

  test('Create book folder in library and copy ebook to it', () async {
    String userHome = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] as String;
    String authorName = "First Last";
    String bookTitle = "Book Title";

    var dir =
        await Epub.createBookDir(authorName, bookTitle, "Loro Library Test");
    expect(dir.existsSync(), true);

    File bookInLibrary = await Epub.copyEpubToDir(
        File('test/moby-dick.epub'), dir, authorName, bookTitle);
    expect(bookInLibrary.existsSync(), true);

    String coverFileLocation = await Epub.copyCoverToDir(epubFile, dir);
    expect(File(coverFileLocation).existsSync(), true);
    // Directory('$userHome/Loro Library Test').deleteSync(recursive: true);
  });

//   group('load epub:', () {
// test('Epub is loaded from file', () {
//   });
// print(Directory.current);
// // Epub info is loaded
// // dir is created
// // book is copied
//     final memFs = MemoryFileSystem();
//     String authorName = "First Last";
//     String bookTitle = "Book Title";
//     // Directory bookDir = await Epub.createBookDir(authorName, bookTitle, memFs);
//     String userHome = Platform.environment['HOME'] ??
//         Platform.environment['USERPROFILE'] as String;
//
//   });
}
