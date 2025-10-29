import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'attendance_models.dart';
import 'attendance_record_detail_screen.dart';

class AttendanceRecordsScreen extends StatelessWidget {
  final List<AttendanceRecord> records;

  const AttendanceRecordsScreen({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final sortedRecords = records.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: records.isEmpty
          ? _buildEmptyState(context)
          : _buildRecordsList(context, sortedRecords),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('No attendance records found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context, List<AttendanceRecord> sortedRecords) {
    return ListView.builder(
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text((index + 1).toString()),
            ),
            title: Text('Record for ${DateFormat.yMMMd().format(record.date)}'),
            subtitle: Text('${record.presentMembers.length} Present, ${record.absentMembers.length} Absent'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AttendanceRecordDetailScreen(record: record),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
