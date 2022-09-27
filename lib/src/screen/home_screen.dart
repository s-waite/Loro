import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:loro/src/widget/toolbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  BookDAO bookDAO;
  HomeScreen({super.key, required this.bookDAO});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Column(children: [
      Toolbar(),
      BookTable(bookDAO: widget.bookDAO, ref: ref),
    ])
            //   home: Scaffold(
            // body: BookList(bookDAO: widget.bookDAO)
            ));
  }
}

class BookTable extends StatefulWidget {
  final BookDAO bookDAO;
  WidgetRef ref;
  BookTable({super.key, required this.bookDAO, required this.ref});

  @override
  State<BookTable> createState() => _BookTableState();
}

class _BookTableState extends State<BookTable> {
  int? sortColumnIndex;
  bool isAscending = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: StreamBuilder(
      stream: widget.bookDAO.getAllBooks(),
      builder: (context, snapshot) {
        // Show loading icon when table is loading
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Get the current books list
        var books = snapshot.requireData;

        // Watch for the search text changing
        String searchText = widget.ref.watch(searchTextStateProvider);
        // Filter the book list for the text
        if (searchText.isNotEmpty) {
          books = books
              .where((element) => element.title.contains(searchText))
              .toList();
          // If no items found print info 
          if (books.isEmpty) {
            return Center(child: Text("No Results Found"));
          }
        }

        // Sorting logic for each column
        switch (sortColumnIndex) {
          // Title column
          case 0:
            if (isAscending) {
              books.sort((a, b) => a.title.compareTo(b.title));
            } else {
              books.sort((a, b) => b.title.compareTo(a.title));
            }
            break;

          // Author column
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
  print("create rows start");
  List<DataRow> rows = [];
  for (Book b in books) {
    rows.add(DataRow(cells: [
      DataCell(Text(b.title)),
      DataCell(Text(b.authorName)),
    ]));
  }
  print("returning rows");
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
