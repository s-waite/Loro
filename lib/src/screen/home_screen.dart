import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:loro/src/widget/toolbar.dart';

class HomeScreen extends StatefulWidget {
  BookDAO bookDAO;
  HomeScreen({super.key, required this.bookDAO});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BookTable(bookDAO: widget.bookDAO),
      //   home: Scaffold(
      // body: BookList(bookDAO: widget.bookDAO)
    );
  }
}

class BookTable extends StatefulWidget {
  final BookDAO bookDAO;
  const BookTable({super.key, required this.bookDAO});

  @override
  State<BookTable> createState() => _BookTableState();
}

class _BookTableState extends State<BookTable> {
  int? sortColumnIndex;
  bool isAscending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder(
      stream: widget.bookDAO.getAllBooks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        var books = snapshot.requireData;
        switch (sortColumnIndex) {
          case 0:
            if (isAscending) {
              books.sort((a, b) => a.title.compareTo(b.title));
            } else {
              books.sort((a, b) => b.title.compareTo(a.title));
            }
            break;

          case 1:
            if (isAscending) {
              books.sort((a, b) => a.authorName.compareTo(b.authorName));
            } else {
              books.sort((a, b) => b.authorName.compareTo(a.authorName));
            }
            break;
          default:
        }

        return DataTable2(
            sortColumnIndex: sortColumnIndex,
            sortAscending: isAscending,
            columns: [
              DataColumn(
                label: Text("Title"),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    sortColumnIndex = columnIndex;
                    isAscending = ascending;
                  });
                },
              ),
              DataColumn(
                label: Text("Author"),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    sortColumnIndex = columnIndex;
                    isAscending = ascending;
                  });
                },
              )
              // TODO: refactor to use generate on list
            ],
            rows: createRows(books));
      },
    ));
  }
}

List<DataRow> createRows(List<Book> books) {
  List<DataRow> rows = [];
  for (Book b in books) {
    rows.add(DataRow(cells: [
      DataCell(Text(b.title)),
      DataCell(Text(b.authorName)),
    ]));
  }
  return rows;
}

class BookList extends StatefulWidget {
  final BookDAO bookDAO;
  const BookList({super.key, required this.bookDAO});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: StreamBuilder(
            stream: widget.bookDAO.getAllBooks(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();

              final books = snapshot.requireData;

              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (_, index) {
                  return BookListCell(
                    book: books[index],
                    bookDAO: widget.bookDAO,
                  );
                },
              );
            }));
  }
}

class BookListCell extends StatelessWidget {
  final BookDAO bookDAO;
  final Book book;
  const BookListCell({super.key, required this.bookDAO, required this.book});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(book.title));
  }
}
