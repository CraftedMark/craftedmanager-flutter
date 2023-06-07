import 'package:postgres/postgres.dart';

// Establishes a connection to the PostgreSQL database
Future<PostgreSQLConnection> connectToPostgres() async {
  final connection = PostgreSQLConnection(
    'web.craftedsolutions.co', // Database host
    5432, // Port number
    'craftedmanager_db', // Database name
    username: 'craftedmanager_dbuser', // Database username
    password: '!!Laganga1983', // Database password
  );

  await connection.open();
  print('Connected to PostgreSQL');
  return connection;
}

// Fetches the database schema
Future<void> main() async {
  final schema = await getDatabaseSchema();
  await createNewTables(schema);
}

Future<List<Map<String, dynamic>>> getDatabaseSchema() async {
  final connection = await connectToPostgres();
  final result = await connection.query('''
    SELECT table_name, column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    ORDER BY table_name, ordinal_position;
  ''');
  await connection.close();
  print('Closed connection to PostgreSQL');

  if (kDebugMode) {
    print('Fetched database schema: $result');
  }

  return result.map((row) => row.toColumnMap()).toList();
}

Future<void> createNewTables(List<Map<String, dynamic>> schema) async {
  final connection = await connectToPostgres();
  String currentTable = '';
  String createTableQuery = '';

  for (final column in schema) {
    if (currentTable != column['table_name']) {
      if (currentTable.isNotEmpty) {
        createTableQuery += ');';
        await connection.execute(createTableQuery);
      }

      currentTable = column['table_name'];
      createTableQuery = '''
        CREATE TABLE IF NOT EXISTS $currentTable (
          ${column['column_name']} ${column['data_type']}
      ''';
    } else {
      createTableQuery += ''',
        ${column['column_name']} ${column['data_type']}
      ''';
    }
  }

  // Create the last table
  if (currentTable.isNotEmpty) {
    createTableQuery += ');';
    await connection.execute(createTableQuery);
  }

  print('Created new tables based on the schema');
}

Future<void> createRecipeTable() async {
  final connection = await connectToPostgres();
  await connection.execute('''
    CREATE TABLE IF NOT EXISTS recipes (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      ingredients JSONB NOT NULL,
      amounts JSONB NOT NULL,
      costs JSONB NOT NULL,
      pieces INT NOT NULL,
      steps JSONB NOT NULL,
      step_images JSONB
    );
  ''');
  await connection.close();
  print('Created (if not exists) the recipes table');
}
