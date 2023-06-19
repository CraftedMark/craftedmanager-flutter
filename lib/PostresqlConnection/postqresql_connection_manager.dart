import 'package:postgres/postgres.dart';

class PostgreSQLConnectionManager{

  PostgreSQLConnectionManager._();

  static PostgreSQLConnection? _connection;

  static PostgreSQLConnection get connection => _connection!;


  static void init () async {
    _connection = PostgreSQLConnection(
      'web.craftedsolutions.co', // Database host
      5432, // Port number
      'craftedmanager_db', // Database name
      username: 'craftedmanager_dbuser', // Database username
      password: '!!Laganga1983', // Database password
    );
  }

  static Future<void> open() async {
    if(_connection != null){
      await _connection!.open();
    }
    else{
      throw "You must call connect() before use open()";
    }
  }

  static Future<void> close() async {
    if(_connection != null){
      await _connection!.close();
    }
    else{
      throw "You are not connected to DB";
    }
  }

}
