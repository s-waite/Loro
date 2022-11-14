import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:loro/src/entity/book.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:loro/main.dart';
import 'package:window_size/window_size.dart';
import 'package:data_table_2/data_table_2.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

// TODO: load all data
class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    var loro = Loro.of(context);
    loro.db.bookDao.getAllBooks().then((value) {
      loro.allBooks.value = value;
    });
    List<Book> sortedBooks = loro.allBooks.value;
    sortedBooks.sort(
      (a, b) {
        return b.sizeInKb.compareTo(a.sizeInKb);
      },
    );
    return (Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Table(
            border: TableBorder.all(),
            children: List<TableRow>.generate(sortedBooks.length + 1, (index) {
              if (index == 0) {
                return TableRow(children: [
                  TableCell(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Title",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                  TableCell(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Author",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                  TableCell(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Date Added",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                  TableCell(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Size in KB",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                ]);
              }
              index = index - 1;
              final book = sortedBooks[index];
              return TableRow(children: [
                TableCell(
                    child: Container(
                        padding: EdgeInsets.all(10), child: Text(book.title))),
                TableCell(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(book.authorName))),
                TableCell(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(book.dateAdded))),
                TableCell(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(book.sizeInKb.toString()))),
              ]);
            })),
        Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Back")),
                Text("Report Generated ${DateTime.now().toString()}")
              ],
            ))
      ],
    ));
  }
}
