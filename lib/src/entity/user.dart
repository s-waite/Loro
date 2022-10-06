import 'package:floor/floor.dart';

@entity
class User {
  @PrimaryKey()
  final String username;
  final String password;
  User({required this.username, required this.password});
}
