import 'package:flutter/material.dart';
import 'package:app/models/announcement.dart';
import 'package:intl/intl.dart';

final List<Announcement> announcements = [
  Announcement(title: 'Welcome!', content: 'Welcome to the Slug N Plug club app!', date: DateTime(2025, 10, 15)),
  Announcement(title: 'First Meeting', content: 'Our first meeting will be on October 25th.', date: DateTime(2025, 10, 18)),
];

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return AnnouncementCard(announcement: announcements[index]);
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({super.key, required this.announcement});

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
              announcement.title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().format(announcement.date),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(announcement.content, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
