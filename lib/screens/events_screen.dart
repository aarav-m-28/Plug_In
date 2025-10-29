import 'package:flutter/material.dart';
import 'package:app/models/event.dart';
import 'package:intl/intl.dart';

final List<Event> events = [
  Event(title: 'Flutter Workshop', date: DateTime(2025, 10, 20), description: 'A hands-on workshop on Flutter development.'),
  Event(title: 'Club Meeting', date: DateTime(2025, 10, 25), description: 'Monthly club meeting to discuss upcoming activities.'),
  Event(title: 'Hackathon', date: DateTime(2025, 11, 5), description: 'A 24-hour hackathon on mobile app development.'),
];

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(event: events[index]);
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  DateFormat.yMMMd().format(event.date),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.description, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
