import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loro/main.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/screen/report.dart';
import 'package:riverpod/riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loro/src/utility/epub.dart';
import 'package:loro/src/entity/book.dart';
import 'package:loro/src/database/database.dart';
import 'dart:io';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
        child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Leading(), Trailing()],
            )));
  }
}

class Leading extends StatefulWidget {
  const Leading({super.key});

  @override
  State<Leading> createState() => _LeadingState();
}

class _LeadingState extends State<Leading> {
  @override
  Widget build(BuildContext context) {
    return Text("Books",
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold));
  }
}

class Trailing extends StatefulWidget {
  const Trailing({super.key});

  @override
  State<Trailing> createState() => _TrailingState();
}

class _TrailingState extends State<Trailing> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      children: [
        ReportButton(),
        DeleteButton(),
        AddBookButton(),
        Search(),
      ],
      crossAxisAlignment: WrapCrossAlignment.center,
    );
  }
}

class ReportButton extends StatefulWidget {
  const ReportButton({super.key});

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/report");
        },
        child: Text("Generate Report of Books"));
  }
}

class AddBookButton extends StatefulWidget {
  const AddBookButton({super.key});

  @override
  State<AddBookButton> createState() => _AddBookButtonState();
}

class _AddBookButtonState extends State<AddBookButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          FilePicker.platform.pickFiles().then((result) {
            if (result != null) {
              File file = File(result.files.single.path.toString());
              print(file.path);
              Epub.loadEpub(
                  file, Loro.of(context).allBooks, Loro.of(context).db);
            } else {}
          });
        },
        padding: EdgeInsets.all(1),
        splashRadius: 26,
        tooltip: "Add Book",
        icon: Icon(Icons.add));
  }
}

class DeleteButton extends StatefulWidget {
  const DeleteButton({super.key});

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        splashRadius: 26,
        tooltip: "Delete Selected Books",
        onPressed: () async {
          List<Book> books = Loro.of(context).allBooks.value;
          List<Book> selectedBooks = Loro.of(context).selectedBooks;
          BookDAO bookDAO = Loro.of(context).db.bookDao;

          for (var element in selectedBooks) {
            int selectedId = element.id!;
            for (Book b in books) {
              if (b.id == selectedId) {
                // Delete book dir
                Directory(b.bookDirPath).deleteSync(recursive: true);

                // Delete author dir if empty
                var parentDir = Directory(b.bookDirPath).parent;
                if (parentDir.listSync(recursive: true).isEmpty) {
                  parentDir.delete();
                }

                bookDAO.deleteBookById(b.id!);
                if (Loro.of(context).activeBook.value.id == b.id) {
                  Loro.of(context).activeBook.value = Book(
                  dateAdded: "",
                  sizeInKb: 0,
                      title: "",
                      authorName: "",
                      bookDirPath: "",
                      coverPath: "",
                      description: "");
                }
              }
            }
          }

// reset selected books notifier
          Loro.of(context).allBooks.value = await bookDAO.getAllBooks();
          Loro.of(context).selectedBooks.clear();
        },
        icon: Icon(Icons.delete));
  }
}

enum SearchFilter { title, author }

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  SearchFilter _searchFilter = SearchFilter.title;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 100,
          child: DropdownButtonHideUnderline(
              child: DropdownButton(
                  value: _searchFilter,
                  items: [
                    DropdownMenuItem(
                      child: Text("Title"),
                      value: SearchFilter.title,
                    ),
                    DropdownMenuItem(
                        child: Text("Author"), value: SearchFilter.author)
                  ],
                  onChanged: (value) {
                    setState(() {
                      _searchFilter = value!;
                    });
                  }))),
      SizedBox(
        width: 20,
      ),
      SizedBox(
          width: 200,
          child: TextField(
              onSubmitted: (searchText) async {
                searchText = searchText.toLowerCase();
                BookDAO bookDAO = Loro.of(context).db.bookDao;
                if (searchText.isNotEmpty) {
                  // Get all books from db and filter for searchText;
                  bookDAO.getAllBooks().then((allBooks) {
                    Loro.of(context).allBooks.value = allBooks.where((book) {
                      if (_searchFilter == SearchFilter.title) {
                        return book.title.toLowerCase().contains(searchText);
                      } else if (_searchFilter == SearchFilter.author) {
                        return book.authorName
                            .toLowerCase()
                            .contains(searchText);
                      }
                      return false;
                    }).toList();
                  });
                } else {
                  Loro.of(context).allBooks.value = await bookDAO.getAllBooks();
                }
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search))))
    ]);
  }
}
