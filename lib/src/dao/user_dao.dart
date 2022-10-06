import 'package:floor/floor.dart';
import 'package:loro/src/entity/user.dart';

@dao
abstract class UserDAO {

  @Query('SELECT * FROM User WHERE username = :username')
  Future<User?> findUserByUsername(String username);

  @Query('DELETE FROM User WHERE username = :username')
  Future<void> deleteUserByUsername(String username);

  @insert
  Future<void> insertUser(User user);
}
