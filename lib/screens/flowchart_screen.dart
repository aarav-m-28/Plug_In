import 'package:flutter/material.dart';
import 'package:app/models/collaboration.dart';

class FlowchartScreen extends StatefulWidget {
  final Collaboration? collaboration;
  final bool canEdit;
  const FlowchartScreen({super.key, this.collaboration, this.canEdit = false});

  @override
  State<FlowchartScreen> createState() => _FlowchartScreenState();
}

class _FlowchartScreenState extends State<FlowchartScreen> {
  List<Map<String, dynamic>> _nodes = [];

  @override
  void initState() {
    super.initState();
    final data = widget.collaboration?.toolData['flowchart_nodes'];
    if (data is List) {
      _nodes = List<Map<String, dynamic>>.from(data);
    }
  }

  void _save() {
    if (!widget.canEdit) return;
    if (widget.collaboration != null) {
      widget.collaboration!.toolData['flowchart_nodes'] = _nodes;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flowchart saved (in-memory)')));
  }

  void _addNode(Offset position) {
    setState(() {
      _nodes.add({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'x': position.dx, 'y': position.dy, 'label': 'Node ${_nodes.length + 1}'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text('Flowchart', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 12),
                Chip(label: Text(widget.canEdit ? 'Editable' : 'Read-only'), backgroundColor: widget.canEdit ? Colors.green[100] : Colors.grey[200]),
                const Spacer(),
                Text('Long-press to add node', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 12),
                ElevatedButton.icon(onPressed: widget.canEdit ? _save : null, icon: const Icon(Icons.save), label: const Text('Save'))
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPressStart: (details) {
                if (widget.canEdit) _addNode(details.localPosition);
              },
              child: Stack(
                children: [
                  Container(color: Colors.transparent),
                  ..._nodes.map((n) {
                    return Positioned(
                      left: n['x'] as double,
                      top: n['y'] as double,
                      child: Draggable<Map<String, dynamic>>(
                        data: n,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _buildNode(n, dragging: true),
                        ),
                        childWhenDragging: const SizedBox.shrink(),
                        onDragEnd: (details) {
                          if (!widget.canEdit) return;
                          setState(() {
                            n['x'] = details.offset.dx;
                            n['y'] = details.offset.dy - kToolbarHeight; // adjust for appbar in some contexts
                          });
                        },
                        child: _buildNode(n),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(Map<String, dynamic> n, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: dragging ? Colors.yellow[300] : Colors.yellow,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.2 * 255).toInt()), blurRadius: 4)],
      ),
      child: Text(n['label'], style: const TextStyle(color: Colors.black)),
    );
  }
}
