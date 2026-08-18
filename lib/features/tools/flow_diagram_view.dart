import 'package:flutter/material.dart';

class FlowNode {
  final String label;
  final IconData icon;
  final String? note;
  FlowNode(this.label, this.icon, {this.note});
}

class SystemDiagram {
  final String title;
  final String description;
  final List<FlowNode> nodes; // rendered as a loop or chain, in order
  final bool isLoop; // if true, last node arrows back to first
  final Color color;
  SystemDiagram({
    required this.title,
    required this.description,
    required this.nodes,
    required this.color,
    this.isLoop = false,
  });
}

/// Renders a system as a wrapped chain of labeled boxes connected by
/// arrows -- a schematic flow diagram, not a photorealistic drawing.
/// This keeps every diagram both original artwork (no copyright risk)
/// and structurally accurate, without needing precise freehand layout.
class FlowDiagramView extends StatelessWidget {
  final SystemDiagram diagram;
  const FlowDiagramView({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    final nodes = diagram.nodes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(diagram.description, style: const TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.7)),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 0; i < nodes.length; i++) ...[
              _NodeBox(node: nodes[i], color: diagram.color),
              if (i < nodes.length - 1)
                Icon(Icons.arrow_back, color: diagram.color, size: 20)
              else if (diagram.isLoop)
                Icon(Icons.subdirectory_arrow_left, color: diagram.color, size: 20),
            ],
          ],
        ),
        if (diagram.isLoop) ...[
          const SizedBox(height: 4),
          Center(
            child: Text('(چرخه به نقطه‌ی شروع برمی‌گردد)',
                style: TextStyle(fontSize: 11, color: diagram.color)),
          ),
        ],
      ],
    );
  }
}

class _NodeBox extends StatelessWidget {
  final FlowNode node;
  final Color color;
  const _NodeBox({required this.node, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      width: 110,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(node.icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(node.label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
          if (node.note != null) ...[
            const SizedBox(height: 3),
            Text(node.note!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
