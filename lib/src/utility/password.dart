import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:loro/src/entity/user.dart';
import 'package:argon2/argon2.dart';
import 'package:loro/src/database/database.dart';

Uint8List generateSalt() {
// Generating a random salt
  List<int> saltInts = [];
  for (var i = 0; i < 8; i++) {
    saltInts.add(Random.secure().nextInt(256));
  }
  return Uint8List.fromList(saltInts);
}

String hashStrAndB64Encode(String password, Uint8List salt) {
  // Parameters for argon2 byte generator
  var parameters = Argon2Parameters(
    Argon2Parameters.ARGON2_i,
    salt,
    version: Argon2Parameters.ARGON2_VERSION_10,
    iterations: 2,
    memoryPowerOf2: 16,
  );

  // Generating the bytes
  var argon2 = Argon2BytesGenerator();
  argon2.init(parameters);
  var passwordBytes = parameters.converter.convert(password);
  var result = Uint8List(32);
  argon2.generateBytes(passwordBytes, result, 0, result.length);

  // Converting to base64 for storage in the database
  var resultB64 = base64Encode(result);
  var saltB64 = base64Encode(salt);

  return ("$saltB64\$$resultB64");
}

Future<bool> verifyPasswordHashedSalted(
    String username, String inputPassword, AppDatabase db) async {
  User? user = await db.userDao.findUserByUsername(username);
  if (user == null) {
    // somthing
  }
  var salt = base64Decode(user!.password.split('\$')[0]);

  if (user.password == hashStrAndB64Encode(inputPassword, salt)) {
    return true;
  }
  return false;
}
