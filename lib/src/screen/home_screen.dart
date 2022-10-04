import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loro/main.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:loro/src/utility/epub.dart';
import 'package:loro/src/widget/toolbar.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var loro = Loro.of(context);
    loro.db.bookDao.getAllBooks().then((value) {
      loro.allBooks.value = value;
      print("getting all books in home screen (should only happen 1nce)");
    });

    print("building main");
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Toolbar(),
      Expanded(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
        BookTable(),
        Container(
          width: 1,
          color: Colors.black,
        ),
        BookView(),
      ]))
    ]);
  }
}

class BookTable extends StatefulWidget {
  BookTable({
    super.key,
  });

  @override
  State<BookTable> createState() => _BookTableState();
}

class _BookTableState extends State<BookTable> {
  int? sortColumnIndex;
  bool isAscending = false;
  List<Book> books = [];
  var col = MaterialStateProperty.all(Colors.red);

  @override
  Widget build(BuildContext context) {
    
    return Expanded(
        child: ValueListenableBuilder<List<Book>>(
      valueListenable: Loro.of(context).allBooks,
      builder: (context, value, child) {
        if (value.isEmpty) {
            return Center(child: Text("Please Add Some Books"));
          }
        return DataTable2(
            sortColumnIndex: sortColumnIndex,
            sortAscending: isAscending,
            columns: [
              DataColumn2(
                label: Text("Title"),
                onSort: sortColumn,
              ),
              DataColumn(
                label: Text("Author"),
                onSort: sortColumn,
              )
            ],
            rows: List<DataRow2>.generate(value.length, (index) {
              final book = value[index];
              return DataRow2(
                  selected: Loro.of(context).selectedBooks.contains(book),
                  onSelectChanged: (isSelected) => setState(() {
                        final isAdding = isSelected != null && isSelected;
                        isAdding
                            ? Loro.of(context).selectedBooks.add(book)
                            : Loro.of(context).selectedBooks.remove(book);
                      }),
                  onTap: () {
                    Loro.of(context).activeBook.value = book;
                  },
                  cells: [
                    DataCell(Text(book.title)),
                    DataCell(Text(book.authorName)),
                  ]);
            }));
      },
    ));
  }

// Logic for sorting each column
  void sortColumn(int columnIndex, bool ascending) {
    var books = Loro.of(context).allBooks.value.toList();
    switch (columnIndex) {
      // Title
      case 0:
        if (ascending) {
          books.sort((a, b) => a.title.compareTo(b.title));
          Loro.of(context).allBooks.value = books;
        } else {
          books.sort((a, b) => b.title.compareTo(a.title));
          Loro.of(context).allBooks.value = books;
        }
        break;

      // Author
      case 1:
        if (ascending) {
          books.sort((a, b) => a.authorName.compareTo(b.authorName));
          Loro.of(context).allBooks.value = books;
        } else {
          books.sort((a, b) => b.authorName.compareTo(a.authorName));
          Loro.of(context).allBooks.value = books;
        }
        break;
    }
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }
}

class BookView extends StatelessWidget {
  const BookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 350,
        margin: EdgeInsets.all(30),
        child: ValueListenableBuilder<Book>(
            valueListenable: Loro.of(context).activeBook,
            builder: (context, value, child) {
              // If there is no book selected, return a placeholder
              if (value.id == null) {
                  return Container();
                }
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: 100, maxHeight: 220),
                      child: Image.file(File(value.coverPath)),
                    ),
                    SizedBox(height: 20),
                    Text(value.title),
                    SizedBox(height: 10),
                    Text(value.authorName),
                    Html(data: value.description)
                  ],
                ),
              );
            }));
  }
}
