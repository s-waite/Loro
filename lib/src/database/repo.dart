import 'package:loro/src/database/database.dart';

class Repo {
  AppDatabase db;

// Private constructor
  Repo._(this.db) {
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((value) {
      db = value;
    });
  }
}
