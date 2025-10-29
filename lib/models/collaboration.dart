import 'package:app/models/event.dart';

class Collaboration {
  String id;
  String title;
  List<String> leads;
  List<String> members;
  Event? linkedEvent;
  DateTime createdAt;

  // toolData stores arbitrary per-tool state, e.g. nodes and edges for flowchart/mindmap/timeline
  Map<String, dynamic> toolData;

  Collaboration({
    required this.id,
    required this.title,
    this.leads = const [],
    this.members = const [],
    this.linkedEvent,
    DateTime? createdAt,
    Map<String, dynamic>? toolData,
  })  : createdAt = createdAt ?? DateTime.now(),
        toolData = toolData ?? {};
}
