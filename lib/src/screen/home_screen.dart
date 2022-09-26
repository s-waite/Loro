import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/database/database.dart';
import 'package:loro/src/entity/book.dart';
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
        // home: BookList(bookDAO: widget.bookDAO),
        home: Scaffold(
      body: Toolbar(),
    ));
  }
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
