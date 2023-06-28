// import 'package:crafted_manager/Models/employee_model.dart';
// import 'package:crafted_manager/Models/order_model.dart';
// import 'package:crafted_manager/Models/task_model.dart';
//import '../Providers/order_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// class ProductionReport extends StatefulWidget {
//   @override
//   _ProductionReportState createState() => _ProductionReportState();
// }
//
// class _ProductionReportState extends State<ProductionReport> {
//   final List<Task> tasks = [];
//   final List<Employee> selectedEmployees = [];
//   final taskController = TextEditingController();
//   final startController = TextEditingController();
//   final stopController = TextEditingController();
//   final notesController = TextEditingController();
//   Order? selectedOrder;
//   List<Order> openOrders = [];
//   final searchTextController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       fetchOpenOrders();
//     });
//   }
//
//   Future<void> fetchOpenOrders() async {
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     await orderProvider.fetchOrders(); // Add this line
//     var allOrders = orderProvider.orders;
//     setState(() {
//       openOrders =
//           allOrders.where((order) => order.orderStatus == 'open').toList();
//     });
//   }
//
//   Future<void> searchOrders(String query) async {
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     List<Order> allOrders = orderProvider.orders;
//     List<Order> results = allOrders
//         .where((order) => order.id.toString().contains(query))
//         .toList();
//
//     setState(() {
//       openOrders = results;
//     });
//   }
//
//   void addTask() {
//     if (selectedOrder != null && selectedEmployees.isNotEmpty) {
//       try {
//         DateTime startTime = DateTime.parse(startController.text);
//         DateTime stopTime = DateTime.parse(stopController.text);
//
//         setState(() {
//           tasks.add(Task(
//             selectedOrder!,
//             List<Employee>.from(selectedEmployees),
//             taskController.text,
//             startTime,
//             stopTime,
//             notesController.text,
//           ));
//           taskController.clear();
//           startController.clear();
//           stopController.clear();
//           notesController.clear();
//           selectedEmployees.clear();
//         });
//       } catch (e) {
//         //show an error message
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Production Report"),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               OrderDataTable(
//                 (order) => setState(() {
//                   selectedOrder = order;
//                 }),
//                 selectedOrder ??
//                     Order(
//                       id: "default_id",
//                       // Changed this line to convert int to BigInt
//                       // or any other "default" value
//                       customerId: "",
//                       orderDate: DateTime.now(),
//                       // or any other "default" value
//                       shippingAddress: "",
//                       billingAddress: "",
//                       totalAmount: 0.0,
//                       orderStatus: "",
//                       productName: "",
//                       notes: "",
//                       archived: false,
//                       orderedItems: [],
//                     ), // Provide a default Order object if selectedOrder is null
//               ),
//               Form(
//                 child: Column(
//                   children: [
//                     ElevatedButton(
//                       child: Text("Search Order"),
//                       onPressed: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             return Dialog(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   TextField(
//                                     controller: searchTextController,
//                                     decoration: InputDecoration(
//                                       labelText: "Search",
//                                       suffixIcon: IconButton(
//                                         icon: Icon(Icons.search),
//                                         onPressed: () {
//                                           searchOrders(
//                                               searchTextController.text);
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 200,
//                                     child: ListView.builder(
//                                       shrinkWrap: true,
//                                       itemCount: openOrders.length,
//                                       itemBuilder: (context, index) {
//                                         return ListTile(
//                                           title: Text(
//                                               openOrders[index].id.toString()),
//                                           onTap: () {
//                                             setState(() {
//                                               selectedOrder = openOrders[index];
//                                             });
//                                             Navigator.of(context).pop();
//                                           },
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                     TextFormField(
//                       controller: taskController,
//                       decoration: InputDecoration(labelText: "Task"),
//                     ),
//                     TextFormField(
//                       controller: startController,
//                       decoration: InputDecoration(labelText: "Start Time"),
//                     ),
//                     TextFormField(
//                       controller: stopController,
//                       decoration: InputDecoration(labelText: "Stop Time"),
//                     ),
//                     TextFormField(
//                       controller: notesController,
//                       decoration: InputDecoration(labelText: "Notes"),
//                     ),
//                     ElevatedButton(
//                       child: Text("Add Task"),
//                       onPressed: addTask,
//                     ),
//                   ],
//                 ),
//               ),
//               DataTable(
//                 columns: [
//                   DataColumn(label: Text("Order ID")),
//                   DataColumn(label: Text("Task")),
//                   DataColumn(label: Text("Start Time")),
//                   DataColumn(label: Text("Stop Time")),
//                   DataColumn(label: Text("Notes")),
//                   DataColumn(label: Text("Employees")),
//                 ],
//                 rows: tasks
//                     .map((task) => DataRow(cells: [
//                           DataCell(Text(task.order.id.toString())),
//                           DataCell(Text(task.name)),
//                           DataCell(Text(
//                               DateFormat('hh:mm:ss').format(task.startTime))),
//                           DataCell(Text(
//                               DateFormat('hh:mm:ss').format(task.stopTime))),
//                           DataCell(Text(task.notes)),
//                           DataCell(Text(task.employees
//                               .map((e) => e.firstName + ' ' + e.lastName)
//                               .join(', '))),
//                         ]))
//                     .toList(),
//               ),
//             ],
//           ),
//         ));
//   }
// }
//
// class OrderDataTable extends StatelessWidget {
//   final Function(Order) onOrderSelected;
//
//   final Order selectedOrder;
//
//   OrderDataTable(this.onOrderSelected, this.selectedOrder);
//
//   // OrderDataTable(this.onOrderSelected, Object selectedOrder);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderProvider>(
//       builder: (_, orderProvider, __) {
//         return FutureBuilder(
//             future: orderProvider.getFullOrders(),
//             builder: (context, AsyncSnapshot<List<FullOrder>> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const CircularProgressIndicator();
//               } else if (snapshot.hasData) {
//                 return SizedBox(
//                   height: 300,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         columnSpacing: 25, //56
//                         horizontalMargin: 10,
//                         columns: const [
//                           DataColumn(label: Text('Order ID')),
//                           DataColumn(label: Text('Customer ID')),
//                           DataColumn(label: Text('Customer Name')),
//                           DataColumn(label: Text('Order Status')),
//                           DataColumn(label: Text('Select Order')),
//                         ],
//                         rows: snapshot.data!
//                             .map((fullOrder) => DataRow(cells: [
//                                   DataCell(Text(fullOrder.order.id.toString())),
//                                   DataCell(Text(
//                                       fullOrder.order.customerId.toString())),
//                                   DataCell(Text(fullOrder.employees
//                                       .map(
//                                           (e) => e.firstName + ' ' + e.lastName)
//                                       .join(', '))),
//                                   DataCell(Text(fullOrder.order.orderStatus)),
//                                   DataCell(Checkbox(
//                                     value: selectedOrder == fullOrder.order,
//                                     onChanged: (value) {
//                                       onOrderSelected(fullOrder.order);
//                                     },
//                                   )),
//                                 ]))
//                             .toList(),
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 return Text("Error loading data ${snapshot.error}");
//               }
//             });
//       },
//     );
//   }
// }
