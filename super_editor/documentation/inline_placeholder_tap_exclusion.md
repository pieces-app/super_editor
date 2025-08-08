# SuperEditor – Content Tap Exclusion

This document explains why and how SuperEditor excludes certain taps from its internal gesture handling so that inline widgets (e.g., URL placeholders) can receive taps directly.

## Why this exists

Historically, SuperReader would intercept taps over all document content. That prevented inline widgets (like an inline URL chip rendered inside text) from receiving their own tap gestures. The goal of this work is to:

- Allow inline widgets to handle taps directly (e.g., open a URL)
- Preserve normal SuperReader behavior elsewhere (selection/tap handling)
- Centralize the tap-allowance decision in one place so all interactors behave consistently

This was implemented to fix cases where taps on inline URL placeholders were swallowed by SuperReader and to make link-like inlines behave like real interactive widgets across Android, iOS, and mouse.

## What was added

- ContentTapExclusion (marker widget)
- isTapAllowedAtDocumentPosition (shared utility)
- Interactor updates (Android/iOS/mouse) to call the shared utility

### ContentTapExclusion
A lightweight marker widget intended to wrap inline widgets that should be allowed to receive taps directly (e.g., an inline URL chip). It lives at:

- `src/infrastructure/content_tap_exclusion.dart`

Although the render object currently acts as a marker, the actual decision to allow/deny reader-level tap handling is made in code via `isTapAllowedAtDocumentPosition` (described below). Wrapping inline widgets with `ContentTapExclusion` is recommended for clarity and future-proofing.

### isTapAllowedAtDocumentPosition
A single, shared utility used by all read-only interactors to determine whether SuperReader should handle a tap at a given `DocumentPosition`.

Signature:

```dart
bool isTapAllowedAtDocumentPosition({
  required Document document,
  required DocumentPosition? docPosition,
});
```

Behavior:
- Returns false when the position is a `TextNodePosition` whose character offset maps to a non-null placeholder in the `TextNode` (i.e., an inline widget should receive the tap)
- Returns true otherwise (SuperReader handles the tap as usual)

Location:
- `src/infrastructure/content_tap_exclusion.dart`

### Interactors updated
The following interactors now delegate their tap-allowance decision to `isTapAllowedAtDocumentPosition` inside their `_isPointerAllowedForTap`:

- `src/super_reader/read_only_document_android_touch_interactor.dart`
- `src/super_reader/read_only_document_ios_touch_interactor.dart`
- `src/super_reader/read_only_document_mouse_interactor.dart`

This ensures consistent behavior across Android touch, iOS touch, and mouse.

## How it works end-to-end

1) Your text content uses `InlineWidgetBuilder`s and `AttributedText` placeholders to render inline widgets (e.g., inline URLs).
2) When the user taps, the interactor finds the nearest `DocumentPosition` and calls `isTapAllowedAtDocumentPosition`.
3) If the position is over a text placeholder, SuperReader does NOT handle the tap (tap is allowed to bubble to the inline widget).
4) Otherwise, SuperReader handles the tap normally (e.g., toggling toolbar, changing selection, etc.).

## Usage guidance

- For inline widgets that should receive taps (e.g., URL chips inside text):
  - Emit a `TextNodePosition` placeholder at the appropriate character offset
  - Build the inline with your `InlineWidgetBuilder`
  - Wrap the inline widget with `ContentTapExclusion` for clarity/future-proofing

Example inline builder pattern (simplified):

```dart
Widget buildInlineUrl(BuildContext context, InlineSpanBuilderContext ibc) {
  final child = GestureDetector(
    onTap: () => onLaunchUrl?.call(ibc.metadata['url']),
    child: /* your URL chip UI */,
  );

  return ContentTapExclusion(child: child);
}
```

Notes:
- The allow/deny decision is driven by the presence of a placeholder at a `TextNodePosition` offset. Ensure your `TextNode` populates its `placeholders` map for the inline character.
- Wrapping the widget with `ContentTapExclusion` is recommended, even though the current gating is placeholder-based. It documents intent and gives us a future hook if we extend hit-test-based exclusion.

## Edge cases and considerations

- Non-text content: If the tap is on non-text nodes, SuperReader continues as usual (returns true in the utility).
- Read-only documents: These interactors don’t support collapsed carets; the exclusion only affects whether the tap is consumed by the reader vs the inline.
- Platform parity: The shared utility is used on Android, iOS, and mouse interactors to keep behavior consistent.
- Selection vs tap: Excluded taps go to the inline widget, not the reader. If you also want selection behaviors, wire them into your inline as needed (e.g., long-press to select).

## Rationale summary

- Fixes taps being swallowed by SuperReader over inline widgets
- Single place to update logic (`isTapAllowedAtDocumentPosition`)
- Clear developer ergonomics: mark inline widgets and supply placeholders where they render in text

If you’re integrating custom inline widgets that should be tappable, ensure you:
- Provide a placeholder at the position within the `TextNode`
- Wrap the inline with `ContentTapExclusion`
- Handle taps within the inline widget itself (e.g., open a URL)

This gives inline widgets a native-feeling interaction without breaking SuperReader’s selection and gesture model elsewhere.
