class TimeEntry {
  final int entryID;
  final int employeeID;
  final DateTime clockIn;
  final DateTime clockOut;

  TimeEntry({
    @required this.entryID,
    @required this.employeeID,
    @required this.clockIn,
    this.clockOut,
  });

  factory TimeEntry.fromMap(Map<String, dynamic> json) => new TimeEntry(
        entryID: json["EntryID"],
        employeeID: json["EmployeeID"],
        clockIn: DateTime.parse(json["ClockIn"]),
        clockOut: DateTime.parse(json["ClockOut"]),
      );

  Map<String, dynamic> toMap() => {
        "EntryID": entryID,
        "EmployeeID": employeeID,
        "ClockIn": clockIn.toIso8601String(),
        "ClockOut": clockOut?.toIso8601String(),
      };
}
