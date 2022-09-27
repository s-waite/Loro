import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:loro/src/widget/toolbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  List<Book> books = [];
  BookDAO bookDAO;
  HomeScreen({super.key, required this.bookDAO});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    widget.bookDAO.getAllBooks().then((value) {
      setState(() {
        widget.books = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Column(children: [
      Toolbar(),
      BookTable(
        bookDAO: widget.bookDAO,
        ref: ref,
        allBooks: widget.books,
      ),
    ])
            //   home: Scaffold(
            // body: BookList(bookDAO: widget.bookDAO)
            ));
  }
}

class BookTable extends StatefulWidget {
  final BookDAO bookDAO;
  final WidgetRef ref;
  final List<Book> allBooks;
  BookTable(
      {super.key,
      required this.bookDAO,
      required this.ref,
      required this.allBooks});

  @override
  State<BookTable> createState() => _BookTableState();
}

class _BookTableState extends State<BookTable> {
  int? sortColumnIndex;
  bool isAscending = false;
  List<Book> books = [];

  @override
  Widget build(BuildContext context) {
    // Search filtering logic
    // Widget will be rebuilt when search text changes
    String searchText = widget.ref.watch(searchTextStateProvider);
    if (searchText.isNotEmpty) {
      books = widget.allBooks
          .where((book) => book.title.contains(searchText))
          .toList();
    } else {
      books = widget.allBooks;
    }

    return Expanded(
        child: DataTable2(
            sortColumnIndex: sortColumnIndex,
            sortAscending: isAscending,
            columns: [
              DataColumn(
                label: Text("Title"),
                onSort: sortColumn,
              ),
              DataColumn(
                label: Text("Author"),
                onSort: sortColumn,
              )
            ],
            rows: List<DataRow>.generate(books.length, (index) {
              return DataRow(cells: [
                DataCell(Text(books[index].title)),
                DataCell(Text(books[index].authorName)),
              ]);
            })));
  }

// Logic for sorting each column
  void sortColumn(int columnIndex, bool ascending) {
    switch (columnIndex) {
      // Title
      case 0:
        if (ascending) {
          books.sort((a, b) => a.title.compareTo(b.title));
        } else {
          books.sort((a, b) => b.title.compareTo(a.title));
        }
        break;

      // Author
      case 1:
        if (ascending) {
          books.sort((a, b) => a.authorName.compareTo(b.authorName));
        } else {
          books.sort((a, b) => b.authorName.compareTo(a.authorName));
        }
        break;
    }

    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }
}
