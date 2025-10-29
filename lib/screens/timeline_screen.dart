import 'package:flutter/material.dart';
import 'package:app/models/collaboration.dart';
// Assuming the _NodeEditDialog is in mindmap_screen.dart or a shared utility file.
// For this separated file context, I'll include a simple placeholder or assume it's imported.
// For simplicity, I'll copy the dialog here as well.

class TimelineScreen extends StatefulWidget {
  final Collaboration? collaboration;
  final bool canEdit;
  const TimelineScreen({super.key, this.collaboration, this.canEdit = false});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Structure: {'id': '...', 'x': 100.0, 'label': 'M1'}
  List<Map<String, dynamic>> _milestones = [];

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  @override
  void didUpdateWidget(covariant TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collaboration != oldWidget.collaboration) {
      _loadMilestones();
    }
  }

  void _loadMilestones() {
    final data = widget.collaboration?.toolData['timeline_milestones'];
    if (data is List) {
      setState(() {
        _milestones = List<Map<String, dynamic>>.from(data);
        _milestones.sort((a, b) => (a['x'] as double).compareTo(b['x'] as double)); // Keep milestones sorted by x-position
      });
    } else {
      setState(() {
        _milestones = [];
      });
    }
  }

  void _addMilestone(Offset pos) {
    if (!widget.canEdit) return;
    setState(() {
      _milestones.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'x': pos.dx,
        'label': 'Milestone ${_milestones.length + 1}'
      });
      _milestones.sort((a, b) => (a['x'] as double).compareTo(b['x'] as double));
      _save();
    });
  }

  void _updateMilestonePosition(Map<String, dynamic> milestone, Offset delta, {required double maxWidth}) {
    if (!widget.canEdit) return;
    setState(() {
      milestone['x'] = (milestone['x'] as double) + delta.dx;
      // Clamp x to stay within the bounds (0 to maxWidth)
      milestone['x'] = milestone['x'].clamp(0.0, maxWidth);
      _milestones.sort((a, b) => (a['x'] as double).compareTo(b['x'] as double));
      _save();
    });
  }

  void _deleteMilestone(Map<String, dynamic> milestone) {
    if (!widget.canEdit) return;
    setState(() {
      _milestones.remove(milestone);
      _save();
    });
  }

  void _editMilestoneLabel(Map<String, dynamic> milestone) async {
    if (!widget.canEdit) return;
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => _NodeEditDialog(initialLabel: milestone['label']),
    );

    if (newLabel != null && newLabel.isNotEmpty) {
      setState(() {
        milestone['label'] = newLabel;
        _save();
      });
    }
  }

  void _save() {
    if (!widget.canEdit) return;
    if (widget.collaboration != null) {
      widget.collaboration!.toolData['timeline_milestones'] = _milestones;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timeline updated (in-memory)'), duration: Duration(milliseconds: 500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Timeline Editor', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              Chip(label: Text(widget.canEdit ? 'Editable' : 'Read-only'), backgroundColor: widget.canEdit ? Colors.green[100] : Colors.grey[200]),
              const Spacer(),
              Text('Long-press to add milestone', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: widget.canEdit ? _save : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Local'),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return Container(
                color: Colors.white,
                child: GestureDetector(
                  onLongPressStart: (details) => _addMilestone(details.localPosition),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Horizontal Timeline Line
                      Positioned(
                        top: 150,
                        left: 0,
                        right: 0,
                        height: 4,
                        child: Container(color: Theme.of(context).colorScheme.primary),
                      ),
                      ..._milestones.map((m) => _buildMilestone(m, maxWidth)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMilestone(Map<String, dynamic> m, double maxWidth) {
    // Determine if the milestone is above (even index) or below (odd index) the line
    final index = _milestones.indexOf(m);
    final isAbove = index % 2 == 0;
    const lineY = 150.0;
    const labelOffsetY = 20.0;
    const dotSize = 16.0;

    return Positioned(
      left: m['x'] as double,
      top: lineY - (isAbove ? dotSize + labelOffsetY : -dotSize),
      child: GestureDetector(
        onPanUpdate: (details) => _updateMilestonePosition(m, details.delta, maxWidth: maxWidth),
        onTap: () => _editMilestoneLabel(m),
        onLongPress: widget.canEdit ? () => _showContextMenu(m) : null,
        child: MouseRegion(
          cursor: widget.canEdit ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Milestone Dot on the line
              if (!isAbove) const SizedBox(height: lineY + dotSize), // Adjust spacing for below milestones
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3)],
                ),
              ),
              // Connector Line from Dot to Label
              Container(
                width: 2,
                height: isAbove ? labelOffsetY : -labelOffsetY,
                color: Theme.of(context).colorScheme.secondary,
              ),
              // Milestone Label
              Container(
                constraints: const BoxConstraints(maxWidth: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)],
                ),
                child: Text(
                  m['label'],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ].reversed.toList(), // Reverse to place the label at the bottom for above milestones
          ),
        ),
      ),
    );
  }

  void _showContextMenu(Map<String, dynamic> milestone) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(milestone['x'] + 50, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: const Text('Edit Label'),
          onTap: () => _editMilestoneLabel(milestone),
        ),
        PopupMenuItem(
          value: 'delete',
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: () => _deleteMilestone(milestone),
        ),
      ],
    );
  }
}

// Helper dialog (copied from MindmapScreen for this separated file)
class _NodeEditDialog extends StatelessWidget {
  final String initialLabel;
  const _NodeEditDialog({required this.initialLabel});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialLabel);
    return AlertDialog(
      title: const Text('Edit Label'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'New Label'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}