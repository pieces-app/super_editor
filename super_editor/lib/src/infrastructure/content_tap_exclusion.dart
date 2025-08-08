import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:super_editor/src/core/document.dart';
import 'package:super_editor/src/default_editor/text.dart';

/// A marker widget that indicates its subtree should be excluded from
/// SuperReader's internal tap gesture handling so that the subtree can
/// independently handle taps (e.g., clickable inline widgets).
///
/// Wrap widgets that should receive tap gestures directly (and not be
/// intercepted by SuperReader's tap recognizers) with this widget.
class ContentTapExclusion extends SingleChildRenderObjectWidget {
  const ContentTapExclusion({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => RenderContentTapExclusion();
}

/// RenderObject used as a hit-test marker for [ContentTapExclusion].
class RenderContentTapExclusion extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final hit = super.hitTest(result, position: position);
    return hit;
  }
}

/// Returns whether a tap should be handled by SuperReader given a [docPosition].
///
/// This centralizes logic used by multiple interactors to allow inline widgets
/// (e.g., URL placeholders) to handle taps directly instead of the reader.
///
/// - Returns `true` when SuperReader should handle the tap
/// - Returns `false` when the tap should be excluded (e.g., over a placeholder)
bool isTapAllowedAtDocumentPosition({
  required Document document,
  required DocumentPosition? docPosition,
}) {
  if (docPosition == null) {
    return true;
  }

  final position = docPosition.nodePosition;

  // Only text node positions can have inline placeholders that should intercept taps.
  if (position is! TextNodePosition) {
    return true;
  }

  final node = document.getNodeById(docPosition.nodeId);
  if (node is! TextNode) {
    return true;
  }

  final placeholder = node.text.placeholders[position.offset];
  if (placeholder != null) {
    return false;
  }

  return true;
}
