import 'package:floor/floor.dart';

@entity
class Book {
  @PrimaryKey(autoGenerate: true)
  int id = 0;
  final String title;
  final String authorName;
  final String path;

  Book({required this.title,required this.authorName, required this.path});
}
