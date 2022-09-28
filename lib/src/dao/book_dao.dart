import 'package:floor/floor.dart';
import 'package:loro/src/entity/book.dart';

@dao
abstract class BookDAO {
    @Query('SELECT * FROM Book')
  Future<List<Book>> getAllBooks();

  @Query('SELECT * FROM Book WHERE id = :id')
  Future<Book?> findBookById(int id);

  @insert
  Future<void> insertBook(Book book);
}
