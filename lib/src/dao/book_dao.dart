import 'package:floor/floor.dart';
import 'package:loro/src/entity/book.dart';

@dao
abstract class BookDAO {
    @Query('SELECT * FROM Book')
  Future<List<Book>> getAllBooks();

  @Query('SELECT * FROM Book WHERE id = :id')
  Future<Book?> findBookById(int id);

  @Query('SELECT * FROM Book WERE title LIKE :searchText')
  Future<List<Book>> findBooksByTitle(String searchText);

  @insert
  Future<void> insertBook(Book book);
}
