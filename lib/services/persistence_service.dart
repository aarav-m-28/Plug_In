import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/collaboration.dart';
import 'package:app/models/event.dart';

class PersistenceService {
  static const _collabKey = 'collaborations';

  Future<void> saveCollaborations(List<Collaboration> collabs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = collabs.map((c) => _collabToJson(c)).toList();
    await prefs.setString(_collabKey, jsonEncode(jsonList));
  }

  Future<List<Collaboration>> loadCollaborations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_collabKey);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((j) => _collabFromJson(j)).toList();
  }

  Map<String, dynamic> _collabToJson(Collaboration c) => {
    'id': c.id,
    'title': c.title,
    'leads': c.leads,
    'members': c.members,
    'createdAt': c.createdAt.toIso8601String(),
    'linkedEvent': c.linkedEvent == null ? null : {
      'title': c.linkedEvent!.title,
      'date': c.linkedEvent!.date.toIso8601String(),
      'description': c.linkedEvent!.description,
    },
    'toolData': c.toolData,
  };

  Collaboration _collabFromJson(Map<String, dynamic> j) => Collaboration(
    id: j['id'],
    title: j['title'],
    leads: List<String>.from(j['leads'] ?? []),
    members: List<String>.from(j['members'] ?? []),
    createdAt: DateTime.parse(j['createdAt']),
    linkedEvent: j['linkedEvent'] == null ? null :
      Event(
        title: j['linkedEvent']['title'],
        date: DateTime.parse(j['linkedEvent']['date']),
        description: j['linkedEvent']['description'],
      ),
    toolData: Map<String, dynamic>.from(j['toolData'] ?? {}),
  );
}

// No extra event class needed; use Event from models/event.dart
