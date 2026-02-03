import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/src/core/document.dart';
import 'package:super_editor/src/default_editor/box_component.dart';
import 'package:super_editor/src/default_editor/selection_upstream_downstream.dart';

/// Attribution for mermaid diagram blocks.
const mermaidAttribution = NamedAttribution('mermaid');

/// [DocumentNode] that represents a Mermaid diagram.
///
/// Mermaid diagrams are text-based representations of diagrams
/// that can be rendered into visual charts, flowcharts, sequence
/// diagrams, etc.
@immutable
class MermaidNode extends BlockNode {
  MermaidNode({
    required this.id,
    required this.mermaidCode,
    super.metadata,
  }) {
    initAddToMetadata({NodeMetadata.blockType: mermaidAttribution});
  }

  @override
  final String id;

  /// The raw Mermaid diagram source code.
  final String mermaidCode;

  @override
  String? copyContent(dynamic selection) {
    if (selection is! UpstreamDownstreamNodeSelection) {
      throw Exception('MermaidNode can only copy content from a UpstreamDownstreamNodeSelection.');
    }

    return !selection.isCollapsed ? mermaidCode : null;
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is MermaidNode && mermaidCode == other.mermaidCode;
  }

  @override
  DocumentNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return MermaidNode(
      id: id,
      mermaidCode: mermaidCode,
      metadata: {
        ...metadata,
        ...newProperties,
      },
    );
  }

  @override
  DocumentNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return MermaidNode(
      id: id,
      mermaidCode: mermaidCode,
      metadata: newMetadata,
    );
  }

  /// Creates a copy of this node.
  MermaidNode copy() {
    return MermaidNode(
      id: id,
      mermaidCode: mermaidCode,
      metadata: Map.from(metadata),
    );
  }

  /// Creates a copy of this node with updated properties.
  MermaidNode copyWith({
    String? mermaidCode,
  }) {
    return MermaidNode(
      id: id,
      mermaidCode: mermaidCode ?? this.mermaidCode,
      metadata: Map.from(metadata),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MermaidNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mermaidCode == other.mermaidCode;

  @override
  int get hashCode => id.hashCode ^ mermaidCode.hashCode;
}
