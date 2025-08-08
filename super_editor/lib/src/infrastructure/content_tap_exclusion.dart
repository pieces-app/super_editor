import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
