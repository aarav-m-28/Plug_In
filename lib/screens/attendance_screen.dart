import 'package:flutter/material.dart';
import 'attendance_records_screen.dart';
import 'attendance_models.dart'; // <-- FIX #1: Import the shared models

// ----------------------------------------------------------------------
// FIX #2: REMOVED the local class definitions for Member and AttendanceRecord.
// They are now imported from 'attendance_models.dart'.
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// IN-MEMORY DATA
// ----------------------------------------------------------------------

// These lists now use the single, imported type.
final List<AttendanceRecord> attendanceRecords = [];

final List<Member> clubMembers = [
  Member(name: 'Alice'),
  Member(name: 'Bob'),
  Member(name: 'Charlie'),
  Member(name: 'David'),
  Member(name: 'Eve'),
  Member(name: 'Frank'),
  Member(name: 'Grace'),
];

// ----------------------------------------------------------------------
// ATTENDANCE CARD WIDGET
// ----------------------------------------------------------------------

class AttendanceToggleCard extends StatelessWidget {
  final Member member;
  final ValueChanged<bool> onChanged;

  const AttendanceToggleCard({
    super.key,
    required this.member,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Your card code is perfect, no changes needed)
    final theme = Theme.of(context);
    final isPresent = member.isPresent;

    final color = isPresent ? Colors.green.shade600 : Colors.grey.shade400;
    final icon = isPresent ? Icons.check_circle : Icons.remove_circle_outline;
    final statusText = isPresent ? 'Present' : 'Absent';
    final textColor = isPresent ? Colors.white : Colors.black87;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: InkWell(
        onTap: () => onChanged(!isPresent),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isPresent ? Colors.white : Colors.white70,
                child: Text(
                  member.name[0],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  member.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// MAIN SCREEN
// ----------------------------------------------------------------------

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  void _submitAttendance() {
    // IMPROVEMENT #1:
    // Changed `m.copyWith(isPresent: m.isPresent)` to just `m.copyWith()`.
    // Your `copyWith` method already does this by default, so it's cleaner.
    final membersCopy = clubMembers.map((m) => m.copyWith()).toList();

    final newRecord = AttendanceRecord(
      date: DateTime.now(),
      members: membersCopy,
    );

    setState(() {
      attendanceRecords.add(newRecord);

      for (var member in clubMembers) {
        member.isPresent = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Attendance submitted! ${membersCopy.where((m) => m.isPresent).length} members present.'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _toggleAll(bool value) {
    setState(() {
      for (var member in clubMembers) {
        member.isPresent = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = clubMembers.where((m) => m.isPresent).length;
    final totalCount = clubMembers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              // This navigation now passes the SHARED definition,
              // which AttendanceRecordsScreen will also understand.
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        AttendanceRecordsScreen(records: attendanceRecords)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // IMPROVEMENT #2:
                // Wrapped the Text in an Expanded widget. This prevents a
                // UI overflow if the buttons and text are too wide for the screen.
                Expanded(
                  child: Text(
                    'Marked Present: $presentCount/$totalCount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.select_all),
                  label: const Text('All'), // Shortened for space
                  onPressed: () => _toggleAll(true),
                ),
                TextButton.icon(
                  // IMPROVEMENT #3:
                  // Changed to a more specific icon.
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'), // Shortened for space
                  onPressed: () => _toggleAll(false),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: clubMembers.length,
              itemBuilder: (context, index) {
                final member = clubMembers[index];
                return AttendanceToggleCard(
                  member: member,
                  onChanged: (bool value) {
                    setState(() {
                      member.isPresent = value;
                    });
                  },
                );
              },
            ),
          ),

          // ... (Your submit button code is perfect, no changes needed)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: presentCount > 0 ? _submitAttendance : null,
                icon: const Icon(Icons.save),
                label: Text(
                  'Submit Attendance (${presentCount} Selected)',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}