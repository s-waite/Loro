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

class HomeScreen extends ConsumerStatefulWidget {
  ValueNotifier<List<Book>> bookNotifier = ValueNotifier<List<Book>>([]);
  ValueNotifier<Book> activeBook = ValueNotifier<Book>(Book(
      title: "",
      authorName: "",
      bookDirPath: "",
      coverPath: "",
      description: ""));
  ValueNotifier<List<Book>> selectedBooksNotifier = ValueNotifier<List<Book>>([]);

  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    AppDb.of(context).db.bookDao.getAllBooks().then((value) {
      widget.bookNotifier.value = value;
      print("getting all books in home screen (should only happen 1nce)");
    });

    print("building main");
    return MaterialApp(
        home: Scaffold(
            body: Epub(
                selectedBooksNotifier: widget.selectedBooksNotifier,
                bookNotifier: widget.bookNotifier,
                activeBook: widget.activeBook,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Toolbar(),
                  Expanded(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BookTable(ref: ref),
                      Container(
                        width: 1,
                        color: Colors.black,
                      ),
                      BookView(),
                    ],
                  ))
                  // BookTable(
                  //   ref: ref,
                  // ),
                ]))
            //   home: Scaffold(
            // body: BookList(bookDAO: widget.bookDAO)
            ));
  }
}

class BookTable extends StatefulWidget {
  final WidgetRef ref;
  BookTable({
    super.key,
    required this.ref,
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
    books = Epub.of(context).bookNotifier.value.toList();
    // Search filtering logic
    // Widget will be rebuilt when search text changes
    // TODO: try filtering with database query instead
    // TODO: add inherited widget so we dont have to pass the bookNotifier all around (or try riverpod)
    String searchText = widget.ref.watch(searchTextStateProvider);
    if (searchText.isNotEmpty) {
      Epub.of(context)
          .bookNotifier
          .value
          .retainWhere((book) => book.title.contains(searchText));
    } else {
      Epub.of(context).bookNotifier.value = books;
    }

    return Expanded(
        child: ValueListenableBuilder<List<Book>>(
      valueListenable: Epub.of(context).bookNotifier,
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
            rows: List<DataRow2>.generate(value.length, (index) {
              final book = value[index];
              return DataRow2(
                  selected: Epub.of(context).selectedBooksNotifier.value.contains(book),
                  onSelectChanged: (isSelected) => setState(() {
                                      final isAdding = isSelected != null && isSelected;
                                      isAdding ? Epub.of(context).selectedBooksNotifier.value.add(book) : Epub.of(context).selectedBooksNotifier.value.remove(book);
                                    }),
                  onTap: () {
                    Epub.of(context).activeBook.value = book;
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

class BookView extends StatelessWidget {
  const BookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 350,
        margin: EdgeInsets.all(30),
        child: ValueListenableBuilder<Book>(
            valueListenable: Epub.of(context).activeBook,
            builder: (context, value, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: 100, maxHeight: 220),
                      child: Image.file(
                        File(value.coverPath),
                      ),
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
