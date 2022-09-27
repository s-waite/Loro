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
  final WidgetRef ref;
  const BookTable({super.key, required this.bookDAO, required this.ref});

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
        if (!snapshot.hasData)  {
          return const Center(child: CircularProgressIndicator());
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
            return const Center(child: Text("No Results Found"));
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
            ],
            rows: List<DataRow>.generate(books.length, (index) {
              return DataRow(cells: [
                DataCell(Text(books[index].title)),
                DataCell(Text(books[index].authorName)),
              ]);
            }));
      },
    ));
  }
}
