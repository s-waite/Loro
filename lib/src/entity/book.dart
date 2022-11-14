import 'package:floor/floor.dart';

@entity
class Book {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String title;
  final String authorName;
  final String bookDirPath;
  final String coverPath;
  final String description;
  final String dateAdded;
  final int sizeInKb;

  Book(
      {this.id,
      required this.title,
      required this.authorName,
      required this.bookDirPath,
      required this.coverPath,
      required this.description,
      required this.dateAdded,
      required this.sizeInKb});
}
