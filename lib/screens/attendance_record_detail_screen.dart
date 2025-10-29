import 'package:flutter/material.dart';
import 'attendance_models.dart';
import 'package:intl/intl.dart';

class AttendanceRecordDetailScreen extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceRecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().format(record.date)),
      ),
      body: ListView.builder(
        itemCount: record.members.length,
        itemBuilder: (context, index) {
          final member = record.members[index];
          return ListTile(
            title: Text(member.name),
            trailing: Icon(
              member.isPresent ? Icons.check_circle : Icons.cancel,
              color: member.isPresent ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    );
  }
}
