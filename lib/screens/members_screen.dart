import 'package:flutter/material.dart';
import 'package:app/screens/attendance_screen.dart'; // Assuming this holds your data models

// --- FAKE DATA for compiling (Remove this in your app) ---
// You already have this data, this is just for the example to be runnable.
class Member {
  final String name;
  Member(this.name);
}
class AttendanceMember {
  final String name;
  final bool isPresent;
  AttendanceMember(this.name, this.isPresent);
}
class AttendanceRecord {
  final List<AttendanceMember> members;
  AttendanceRecord(this.members);
}
final clubMembers = [Member('Alice'), Member('Bob'), Member('Charlie'), Member('David'), Member('Eve')];
final attendanceRecords = [
  AttendanceRecord([AttendanceMember('Alice', true), AttendanceMember('Bob', true), AttendanceMember('Charlie', false), AttendanceMember('David', true), AttendanceMember('Eve', true)]),
  AttendanceRecord([AttendanceMember('Alice', true), AttendanceMember('Bob', true), AttendanceMember('Charlie', true), AttendanceMember('David', false), AttendanceMember('Eve', true)]),
  AttendanceRecord([AttendanceMember('Alice', true), AttendanceMember('Bob', false), AttendanceMember('Charlie', true), AttendanceMember('David', true), AttendanceMember('Eve', false)]),
];
// --- END OF FAKE DATA ---


class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  // Helper function to get role for a member
  String _getRoleForMember(String name) {
    switch (name) {
      case 'Alice':
        return 'President';
      case 'Bob':
        return 'Vice President';
      case 'Charlie':
        return 'Secretary';
      case 'David':
        return 'Treasurer';
      default:
        return 'Member';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 UI IMPROVEMENT: Added a light background color
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Members',
          style: TextStyle(color: Colors.black87), // Ensure title is visible
        ),
        // 🎨 UI IMPROVEMENT: Flat, modern app bar
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87), // Ensure back button is visible
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: clubMembers.length,
        itemBuilder: (context, index) {
          final member = clubMembers[index];
          final totalRecords = attendanceRecords.length;
          final presentCount = attendanceRecords
              .where((record) =>
                  record.members.any((m) => m.name == member.name && m.isPresent))
              .length;
          final double attendancePercentage =
              totalRecords == 0 ? 0.0 : (presentCount / totalRecords) * 100.0;

          return MemberCard(
            name: member.name,
            role: _getRoleForMember(member.name),
            attendance: attendancePercentage,
          );
        },
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final String name;
  final String role;
  final double attendance;

  const MemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.attendance,
  });

  // 🎨 UI HELPER: Determines color based on attendance %
  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75.0) {
      return Colors.green.shade700;
    } else if (percentage >= 50.0) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Softened the elevation
      shadowColor: Colors.grey.shade200, // Softer shadow
      margin: const EdgeInsets.only(bottom: 12), // Slightly less margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // 🎨 UI IMPROVEMENT: Use CircleAvatar for a cleaner look
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.person_outline,
            size: 28,
            color: Colors.blue.shade800,
          ),
        ),
        // 🎨 UI IMPROVEMENT: Added vertical padding for more breathing room
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          name,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        // 🎨 UI IMPROVEMENT: Muted subtitle color for better hierarchy
        subtitle: Text(
          role,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        // 🎨 UI IMPROVEMENT: Moved attendance to trailing, with dynamic color
        trailing: Text(
          '${attendance.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getAttendanceColor(attendance),
          ),
        ),
      ),
    );
  }
}