import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loro/main.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:riverpod/riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loro/src/utility/epub.dart';
import 'package:loro/src/entity/book.dart';
import 'package:loro/src/database/database.dart';
import 'dart:io';

final searchTextStateProvider = StateProvider<String>((ref) {
  print("setting hits");
  return "";
});

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    return Container();
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
    return Row(
      children: [DeleteButton(), AddBookButton(), SearchField()],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}

class SearchField extends ConsumerStatefulWidget {
  const SearchField({super.key});

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: TextField(
            onSubmitted: (searchText) async {
              searchText = searchText.toLowerCase();
              BookDAO bookDAO = AppDb.of(context).db.bookDao;
              if (searchText.isNotEmpty) {
                // Get all books from db and filter for searchText;
                bookDAO.getAllBooks().then((allBooks) {
                  Epub.of(context).bookNotifier.value = allBooks.where((book) {
                    return book.title.toLowerCase().contains(searchText);
                  }).toList();
                });
              } else {
                Epub.of(context).bookNotifier.value =
                    await bookDAO.getAllBooks();
              }
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search",
                prefixIcon: Icon(Icons.search))));
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
                  file, Epub.of(context).bookNotifier, AppDb.of(context).db);
            } else {}
          });
        },
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
        onPressed: () {
          List<Book> updatedBooks = [];
          List<Book> books = Epub.of(context).bookNotifier.value;
          List<Book> selectedBooks =
              Epub.of(context).selectedBooksNotifier.value;
          BookDAO bookDAO = AppDb.of(context).db.bookDao;

          for (Book bookInAll in books) {
            for (Book bookInSelected in selectedBooks) {
              if (bookInAll.id == bookInSelected.id) {
                // Delete the book from the db
                bookDAO.deleteBook(bookInAll);

// remove  value from bookNotifier
              } else {
                updatedBooks.add(bookInAll);
              }
            }
          }

// reset selected books notifier
          Epub.of(context).bookNotifier.value = updatedBooks;
          Epub.of(context).selectedBooksNotifier.value = [];
        },
        icon: Icon(Icons.delete));
  }
}
