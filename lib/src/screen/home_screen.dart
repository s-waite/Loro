import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:loro/src/widget/toolbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  ValueNotifier<List<Book>> bookNotifier = ValueNotifier<List<Book>>([]);
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
        widget.bookNotifier.value = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("building main");
    return MaterialApp(
        home: Scaffold(
            body: Column(children: [
      Toolbar(bookNotifier: widget.bookNotifier),
      BookTable(
          bookDAO: widget.bookDAO, ref: ref, bookNotifier: widget.bookNotifier),
    ])
            //   home: Scaffold(
            // body: BookList(bookDAO: widget.bookDAO)
            ));
  }
}

class BookTable extends StatefulWidget {
  final BookDAO bookDAO;
  final WidgetRef ref;
  final bookNotifier;
  BookTable(
      {super.key,
      required this.bookDAO,
      required this.ref,
      required this.bookNotifier});

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
    // TODO: try filtering with database query instead
    String searchText = widget.ref.watch(searchTextStateProvider);
    if (searchText.isNotEmpty) {
      books = widget.bookNotifier.value
          .where((book) => book.title.contains(searchText))
          .toList();
    } else {
      books = widget.bookNotifier.value;
    }

    print(widget.bookNotifier.hashCode);

    return Expanded(
        child: ValueListenableBuilder<List<Book>>(
      valueListenable: widget.bookNotifier,
      builder: (context, value, child) {
        return DataTable2(
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
            rows: List<DataRow>.generate(value.length, (index) {
              return DataRow(cells: [
                DataCell(Text(value[index].title)),
                DataCell(Text(value[index].authorName)),
              ]);
            }));
      },
    ));
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
