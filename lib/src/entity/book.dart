import 'package:floor/floor.dart';

@entity
class Book {
    @primaryKey
    final int id;
    final String title;
    final String authorName;
    final int isbn;

    Book(this.id, this.title, this.authorName, this.isbn);
  }
