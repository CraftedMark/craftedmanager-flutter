import 'package:crafted_manager/Models/employee_model.dart';
import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/task_model.dart';
import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';

class ProductionListDbManager {
  static Future<void> addTask(Task task) async {
    var connection = PostgreSQLConnectionManager.connection;
    final transaction = await connection.open();

    try {
      var taskResult = await transaction.query(
        'INSERT INTO tasks (order_id, name, start_time, stop_time, notes) VALUES (@orderId, @name, @startTime, @stopTime, @notes) RETURNING id',
        substitutionValues: {
          'orderId': task.order.id,
          'name': task.name,
          'startTime': task.startTime,
          'stopTime': task.stopTime,
          'notes': task.notes,
        },
      );

      for (var employee in task.employees) {
        await transaction.execute(
          'INSERT INTO task_employee (task_id, employee_id) VALUES (@taskId, @employeeId)',
          substitutionValues: {
            'taskId': taskResult.first[0],
            'employeeId': employee.employeeID,
          },
        );
      }

      await transaction.commit();
    } catch (e) {
      await transaction.cancel();
    }
  }

  static Future<List<Task>> getAllTasks() async {
    var connection = PostgreSQLConnectionManager.connection;
    // Join tasks and task_employee to get associated employees for each task
    final tasksResult = await connection.query(
        'SELECT * FROM tasks JOIN task_employee ON tasks.id = task_employee.task_id JOIN employees ON task_employee.employee_id = employees.employeeID');

    List<Task> tasks = [];
    for (var data in tasksResult) {
      var row = data.toColumnMap();
      var order = await getOrderById(row[
          'order_id']); // Assuming you have a method to get an Order by its id
      var employee =
          Employee.fromMap(row); // Create Employee from part of row data
      var task = tasks.firstWhere((t) => t.order.id == order?.id, orElse: () {
        var newTask = Task(
            order!,
            [],
            row['name'],
            DateTime.parse(row['start_time']),
            DateTime.parse(row['stop_time']),
            row['notes']);
        tasks.add(newTask);
        return newTask;
      });

      task.employees.add(employee);
    }
    return tasks;
  }

  static Future<Order?> getOrderById(int id) async {
    var connection = PostgreSQLConnectionManager.connection;
    final ordersResult = await connection.query(
      'SELECT * FROM orders WHERE order_id = @id',
      substitutionValues: {'id': id},
    );

    if (ordersResult.isEmpty) {
      return null;
    }

    return Order.fromMap(ordersResult.first.toColumnMap());
  }

  static Future<List<Order>> getOpenOrdersWithAllOrderedItems() async {
    List<Order> orders = [];
    final connection = PostgreSQLConnectionManager.connection;

    List<Map<String, Map<String, dynamic>>> results =
        await connection.mappedResultsQuery('SELECT * FROM orders ');
//WHERE order_status = \'Open\'
    for (Map<String, Map<String, dynamic>> row in results) {
      Order order = Order.fromMap(row['orders']!);
      orders.add(order);
    }
    return orders;
  }
}
