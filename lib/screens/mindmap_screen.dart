import 'package:flutter/material.dart';
import 'package:app/models/collaboration.dart';
import 'dart:ui';
import 'dart:math';

// Helper dialog for editing node/milestone labels
class _NodeEditDialog extends StatelessWidget {
  final String initialLabel;
  const _NodeEditDialog({required this.initialLabel});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialLabel);
    return AlertDialog(
      title: const Text('Rename Idea'), // Renamed title for clarity
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

// --- Node Color Customization Dialog (Same as before) ---
class _NodeColorDialog extends StatefulWidget {
  final int initialColorValue;
  const _NodeColorDialog({required this.initialColorValue});

  @override
  State<_NodeColorDialog> createState() => _NodeColorDialogState();
}

class _NodeColorDialogState extends State<_NodeColorDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = Color(widget.initialColorValue);
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colorOptions = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.brown, Colors.pink
    ];

    return AlertDialog(
      title: const Text('Customize Node Color'),
      content: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: colorOptions.map((color) => GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: _selectedColor == color ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        )).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedColor.value),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
// --- End Node Color Customization Dialog ---

// --- Enhanced Link Detail Dialog (Same as before) ---
class _LinkDetailDialog extends StatefulWidget {
  const _LinkDetailDialog();

  @override
  State<_LinkDetailDialog> createState() => _LinkDetailDialogState();
}

class _LinkDetailDialogState extends State<_LinkDetailDialog> {
  Color _selectedColor = Colors.black87;
  double _strokeWidth = 3.0;
  bool _isDashed = false;
  bool _hasArrow = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Link Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Link Color:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: [
              for (var color in [Colors.black87, Colors.red, Colors.blue, Colors.green])
                GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: color,
                    child: _selectedColor == color ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Link Thickness: ${_strokeWidth.toStringAsFixed(1)}', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _strokeWidth,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            label: _strokeWidth.toStringAsFixed(1),
            onChanged: (value) => setState(() => _strokeWidth = value),
          ),
          Row(
            children: [
              Text('Dashed Line:', style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              Switch(value: _isDashed, onChanged: (val) => setState(() => _isDashed = val)),
            ],
          ),
          Row(
            children: [
              Text('Directional Arrow:', style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              Switch(value: _hasArrow, onChanged: (val) => setState(() => _hasArrow = val)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop({
            'targetId': null,
            'color': _selectedColor.value,
            'strokeWidth': _strokeWidth,
            'dashed': _isDashed,
            'arrow': _hasArrow,
          }),
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
// --- End Enhanced Link Detail Dialog ---

class MindmapScreen extends StatefulWidget {
  final Collaboration? collaboration;
  final bool canEdit;
  const MindmapScreen({super.key, this.collaboration, this.canEdit = false});

  @override
  State<MindmapScreen> createState() => _MindmapScreenState();
}

class _MindmapScreenState extends State<MindmapScreen> {
  List<Map<String, dynamic>> _nodes = [];
  final GlobalKey _stackKey = GlobalKey();
  String? _linkingNodeId; 

  static const int defaultNodeColor = 0xFF2196F3; 

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  @override
  void didUpdateWidget(covariant MindmapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collaboration != oldWidget.collaboration) {
      _loadNodes();
    }
  }

  void _loadNodes() {
    final data = widget.collaboration?.toolData['mindmap_nodes'];
    if (data is List) {
      setState(() {
        _nodes = List<Map<String, dynamic>>.from(data.map((item) => {
          ...item,
          'connectedTo': List<Map<String, dynamic>>.from(item['connectedTo'] ?? []),
          'x': (item['x'] as num? ?? 0.0).toDouble(),
          'y': (item['y'] as num? ?? 0.0).toDouble(),
          'nodeColor': item['nodeColor'] as int? ?? defaultNodeColor,
        }));
        _linkingNodeId = null;
      });
    } else {
      setState(() {
        _nodes = [];
        _linkingNodeId = null;
      });
    }
  }

  void _addNode(Offset pos) {
    if (!widget.canEdit) return;
    setState(() {
      _nodes.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'x': pos.dx,
        'y': pos.dy,
        'label': 'Idea ${_nodes.length + 1}',
        'connectedTo': <Map<String, dynamic>>[],
        'nodeColor': defaultNodeColor,
      });
      _save(local: true);
    });
  }

  void _customizeNodeColor(Map<String, dynamic> node) async {
    if (!widget.canEdit) return;
    final newColorValue = await showDialog<int>(
      context: context,
      builder: (context) => _NodeColorDialog(initialColorValue: node['nodeColor'] as int? ?? defaultNodeColor),
    );

    if (newColorValue != null) {
      setState(() {
        node['nodeColor'] = newColorValue;
        _save();
      });
    }
  }

  void _updateNodePosition(Map<String, dynamic> node, Offset delta) {
    if (!widget.canEdit) return;
    setState(() {
      node['x'] = (node['x'] as double) + delta.dx;
      node['y'] = (node['y'] as double) + delta.dy;
      _save(local: true);
    });
  }

  void _deleteNode(Map<String, dynamic> node) {
    if (!widget.canEdit) return;
    setState(() {
      final nodeId = node['id'] as String;
      _nodes.remove(node);
      for (var n in _nodes) {
        (n['connectedTo'] as List).removeWhere((link) => link['targetId'] == nodeId);
      }
      _save();
    });
  }

  // Renamed from _editNodeLabel for better context
  void _renameNode(Map<String, dynamic> node) async { 
    if (!widget.canEdit) return;
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => _NodeEditDialog(initialLabel: node['label']),
    );

    if (newLabel != null && newLabel.isNotEmpty) {
      setState(() {
        node['label'] = newLabel;
        _save();
      });
    }
  }

  void _startLinking(String sourceId) {
    if (!widget.canEdit) return;
    setState(() {
      _linkingNodeId = sourceId;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap the target idea to create a link!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _endLinking(String targetId) async {
    if (!widget.canEdit || _linkingNodeId == null || _linkingNodeId == targetId) {
      setState(() => _linkingNodeId = null);
      return;
    }

    final sourceId = _linkingNodeId!;
    
    final linkProperties = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _LinkDetailDialog(),
    );

    setState(() {
      _linkingNodeId = null; 

      if (linkProperties != null) {
        final sourceNode = _nodes.firstWhere((n) => n['id'] == sourceId);
        final connections = sourceNode['connectedTo'] as List<Map<String, dynamic>>;

        if (!connections.any((link) => link['targetId'] == targetId)) {
          linkProperties['targetId'] = targetId; 
          connections.add(linkProperties);
          _save();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link created successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link already exists!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link creation cancelled.')),
        );
      }
    });
  }

  void _save({bool local = false}) {
    if (!widget.canEdit) return;
    if (widget.collaboration != null) {
      widget.collaboration!.toolData['mindmap_nodes'] = _nodes;
    }
    if (!local) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mindmap saved (in-memory)'), duration: Duration(milliseconds: 500)),
      );
    }
  }

  void _confirmClearMap() async {
    if (!widget.canEdit) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Mindmap'),
        content: const Text('Are you sure you want to clear all nodes and connections? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _nodes = [];
        _linkingNodeId = null;
        _save();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mindmap cleared!')));
    }
  }

  void _exportMap() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Mindmap data... (Simulated)')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String linkTooltip = _linkingNodeId == null
        ? 'Tap background to add | Double-tap node to link'
        : 'LINKING: Tap target node or tap instruction bar to cancel.';

    return Column(
      children: [
        Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Mindmap Editor', style: theme.textTheme.titleMedium),
              const SizedBox(width: 12),
              Chip(
                label: Text(widget.canEdit ? 'Editable' : 'Read-only'),
                backgroundColor: widget.canEdit ? Colors.green[100] : Colors.grey[200],
              ),
              const Spacer(),
              
              // Tool Buttons
              IconButton(
                icon: const Icon(Icons.clear_all, color: Colors.red),
                tooltip: 'Clear All Nodes (Reset)',
                onPressed: widget.canEdit ? _confirmClearMap : null,
              ),
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Export Mindmap (Simulated)',
                onPressed: _exportMap,
              ),
              
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: widget.canEdit ? () => _save() : null,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
        // Interactive Instruction Bar
        Container(
          width: double.infinity,
          color: _linkingNodeId != null ? Colors.orange[100] : Colors.blueGrey[50],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Tooltip(
            message: linkTooltip,
            child: GestureDetector(
              onTap: _linkingNodeId != null ? () => setState(() => _linkingNodeId = null) : null,
              child: Text(
                linkTooltip,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey[700],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // Mindmap Canvas
        Expanded(
          child: Container(
            color: Colors.white,
            child: GestureDetector(
              key: _stackKey,
              onTapUp: (details) {
                if (widget.canEdit && _linkingNodeId == null) {
                    // Tap on background adds a node
                    _addNode(details.localPosition);
                } else if (_linkingNodeId != null) {
                   // Tap on background cancels linking
                   setState(() => _linkingNodeId = null);
                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Linking cancelled.')),
                   );
                }
              },
              onLongPressStart: (details) => _addNode(details.localPosition),
              child: Stack(
                children: [
                  // 1. Connection Lines Layer
                  CustomPaint(
                    painter: MindMapPainter(nodes: _nodes),
                    child: Container(),
                  ),
                  // 2. Nodes Layer
                  ..._nodes.map((n) => _buildNode(n)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNode(Map<String, dynamic> n) {
    final isLinkingSource = n['id'] == _linkingNodeId;
    final theme = Theme.of(context);
    final nodeColor = Color(n['nodeColor'] as int? ?? defaultNodeColor);

    return Positioned(
      left: n['x'] as double,
      top: n['y'] as double,
      child: GestureDetector(
        onPanUpdate: widget.canEdit ? (details) => _updateNodePosition(n, details.delta) : null,
        // FIX: Single tap now opens the context menu for all options
        onTap: () {
          if (_linkingNodeId != null) {
            _endLinking(n['id'] as String); // Try to connect, opens dialog
          } else {
            _showContextMenu(n); // Open settings menu on tap
          }
        },
        onDoubleTap: widget.canEdit ? () => _startLinking(n['id'] as String) : null,
        // Long press is now free, keeping the add functionality on background for flexibility
        child: MouseRegion(
          cursor: widget.canEdit ? SystemMouseCursors.move : SystemMouseCursors.basic,
          child: Tooltip(
            message: widget.canEdit ? 'Drag: Move | Double-tap: Link | Tap: Options' : n['label'],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isLinkingSource
                    ? Colors.orange.withOpacity(0.9)
                    : nodeColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isLinkingSource ? Colors.white : Colors.transparent, 
                  width: isLinkingSource ? 3 : 0,
                ),
              ),
              child: Text(
                n['label'],
                style: TextStyle(
                  color: nodeColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(Map<String, dynamic> node) {
    if (!widget.canEdit) {
      // Show a simple info menu if read-only
       showMenu<String>(
        context: context,
        position: RelativeRect.fromRect(
          const Offset(0, 0) & const Size(40, 40),
          Offset.zero & context.size!,
        ),
        items: const [
          PopupMenuItem(child: Text('Read-Only Access')),
          PopupMenuItem(child: Text('Idea: View Details')),
        ],
      );
      return;
    }
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset(node['x'] + 50, node['y'] + 50));

    // Consolidated settings menu
    showMenu<String>( 
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40),
        Offset.zero & renderBox.size,
      ),
      items: <PopupMenuEntry<String>>[ 
        // 1. Rename/Edit Label
        PopupMenuItem<String>(
          value: 'rename',
          child: const Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Rename Idea')]),
          onTap: () => _renameNode(node), 
        ),
        // 2. Link Action
        PopupMenuItem<String>(
          value: 'link_start',
          child: const Row(children: [Icon(Icons.polyline, size: 20), SizedBox(width: 8), Text('Start Link')]),
          onTap: () => _startLinking(node['id'] as String),
        ),
        // 3. Customize Color
        PopupMenuItem<String>(
          value: 'color',
          child: const Row(children: [Icon(Icons.palette, size: 20), SizedBox(width: 8), Text('Customize Color')]),
          onTap: () => _customizeNodeColor(node),
        ),
        const PopupMenuDivider(),
        // 4. Delete
        PopupMenuItem<String>(
          value: 'delete',
          child: const Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
          onTap: () => _deleteNode(node),
        ),
      ],
    );
  }
}

// --- Custom Painter for Drawing Styled Lines and Arrows (Remains the same) ---

class MindMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> nodes;

  MindMapPainter({required this.nodes});

  static const double nodeContainerWidth = 160; 
  static const double nodeContainerHeight = 40; 
  static const double nodeRadius = nodeContainerHeight / 2;
  static const double arrowSize = 10;
  
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashLength = 8;
    const double gapLength = 4;
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double angle = atan2(dy, dx);
    final double length = sqrt(dx * dx + dy * dy);

    double current = 0.0;
    while (current < length) {
      final double startX = p1.dx + cos(angle) * current;
      final double startY = p1.dy + sin(angle) * current;
      final double endX = p1.dx + cos(angle) * (current + dashLength);
      final double endY = p1.dy + sin(angle) * (current + dashLength);

      Offset endPoint = Offset(endX, endY);
      if (current + dashLength > length) {
        endPoint = p2;
      }

      canvas.drawLine(Offset(startX, startY), endPoint, paint);
      current += dashLength + gapLength;
    }
  }

  void _drawArrowhead(Canvas canvas, Offset point, double angle, Paint paint) {
    final path = Path();
    
    final double angle1 = angle + 30 * pi / 180;
    final Offset p1 = Offset(
      point.dx - arrowSize * cos(angle1),
      point.dy - arrowSize * sin(angle1),
    );

    final double angle2 = angle - 30 * pi / 180;
    final Offset p2 = Offset(
      point.dx - arrowSize * cos(angle2),
      point.dy - arrowSize * sin(angle2),
    );

    path.moveTo(point.dx, point.dy);
    path.lineTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodePositions = {
      for (var n in nodes) n['id'] as String: Offset(n['x'] as double, n['y'] as double)
    };
    
    const double halfNodeWidth = nodeContainerWidth / 2;
    const double halfNodeHeight = nodeContainerHeight / 2;

    for (var sourceNode in nodes) {
      final sourceId = sourceNode['id'] as String;
      final connectedTo = sourceNode['connectedTo'] as List<Map<String, dynamic>>? ?? [];

      if (nodePositions.containsKey(sourceId)) {
        final sourceCenter = nodePositions[sourceId]!.translate(halfNodeWidth, halfNodeHeight);

        for (var link in connectedTo) {
          final targetId = link['targetId'] as String;
          final linkColor = Color(link['color'] as int? ?? Colors.black54.value);
          final linkStrokeWidth = link['strokeWidth'] as double? ?? 2.0;
          final isDashed = link['dashed'] as bool? ?? false;
          final hasArrow = link['arrow'] as bool? ?? false;

          if (nodePositions.containsKey(targetId)) {
            final targetCenter = nodePositions[targetId]!.translate(halfNodeWidth, halfNodeHeight);

            final paint = Paint()
              ..color = linkColor
              ..strokeWidth = linkStrokeWidth
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;

            final double dx = targetCenter.dx - sourceCenter.dx;
            final double dy = targetCenter.dy - sourceCenter.dy;
            final double angle = atan2(dy, dx);
            
            // 1. Line Start Point (Source Node Edge)
            final Offset lineStartPoint = Offset(
              sourceCenter.dx + cos(angle) * nodeRadius,
              sourceCenter.dy + sin(angle) * nodeRadius,
            );

            // 2. Line End Point (Target Node Edge)
            final Offset lineEndPointRaw = Offset(
              targetCenter.dx - cos(angle) * nodeRadius,
              targetCenter.dy - sin(angle) * nodeRadius,
            );

            // Adjust end point further if an arrow is present
            final Offset lineEndPoint = hasArrow
                ? Offset(
                    lineEndPointRaw.dx - cos(angle) * arrowSize,
                    lineEndPointRaw.dy - sin(angle) * arrowSize,
                  )
                : lineEndPointRaw;
            
            // 3. Draw the line body
            if (isDashed) {
              _drawDashedLine(canvas, lineStartPoint, lineEndPoint, paint);
            } else {
              canvas.drawLine(lineStartPoint, lineEndPoint, paint);
            }

            // 4. Draw the arrowhead
            if (hasArrow) {
              final arrowPaint = Paint()
                ..color = linkColor
                ..style = PaintingStyle.fill;
              
              _drawArrowhead(canvas, lineEndPointRaw, angle, arrowPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MindMapPainter oldDelegate) {
    return true; 
  }
}