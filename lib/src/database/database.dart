// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:loro/src/dao/book_dao.dart';
import 'package:loro/src/dao/user_dao.dart';
import 'package:loro/src/entity/book.dart';
import 'package:loro/src/entity/user.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Book, User])
abstract class AppDatabase extends FloorDatabase {
  BookDAO get bookDao;
  UserDAO get userDao;
}
