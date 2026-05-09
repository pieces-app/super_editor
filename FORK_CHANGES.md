# Fork Changes Documentation

This document tracks all custom modifications, patches, and deviations from the upstream `Flutter-Bounty-Hunters/super_editor` repository.

> ⚠️ The "Commits Ahead/Behind" numbers below are **not** auto-generated. Re-run the commands in [Verifying Drift](#verifying-drift) before trusting them.

## Fork Information

- **Fork Repository**: `https://github.com/pieces-app/super_editor`
- **Upstream Repository**: `https://github.com/Flutter-Bounty-Hunters/super_editor`
- **Tracking Branch**: `chore/align-runtime-version-pins` (sync target: `upstream/main`)
- **Last Upstream Merge**: **2026-05-09** -- merged `upstream/main` (40 commits) into `chore/align-runtime-version-pins`
- **Drift as of last merge**: 0 commits behind upstream/main, 34 commits ahead (33 fork-only + 1 merge commit)

### Verifying Drift

```bash
cd frontend/super_editor
git fetch origin --tags
git fetch upstream --tags
# left = behind (in upstream not in fork), right = ahead (in fork not in upstream)
git rev-list --left-right --count upstream/main...origin/main
```

## Custom Modifications

### 1. Image Component Enhancements (PR #6)
- **Commits**: `df260d94`, `5577a806`, `8359abed`, `bc7a976a`
- **Changes**:
  - Refactored `ImageComponent` to enable `imageBuilder` and receive mouse pointer events on the widget
  - Passing `altText` to `ImageComponentBuilder`
  - `SelectableBox` / `IgnorePointer` updates for image components
- **Location**: `super_editor/lib/src/default_editor/image.dart`
- **Reason**: Enhanced image handling in the editor for Pieces Copilot module

### 2. LaTeX Attribution Support (PR #5)
- **Commits**: `ed1dfaf0`, `555518fa`
- **Changes**:
  - Added `displayLatexAttribution` (`NamedAttribution('display-latex')`) for rendering LaTeX content in the editor
- **Location**: `super_editor/lib/src/default_editor/attributions.dart`
- **Reason**: Required for rendering mathematical/code content in Pieces Copilot

### 3. Scroll Enablement Flag (PR #4)
- **Commit**: `7a6b2e52`
- **Changes**: Added `scrollingEnabled` flag to document widgets (allows programmatic control over scroll behavior)
- **Reason**: Needed to manage scroll behavior in embedded editor contexts

### 4. Content Tap Exclusion (PR #3)
- **Commits**: `b5619720`, `a004dfa2`, `bb68f4c6`
- **Changes**:
  - `ContentTapExclusion` widget for inline-widget tap bypass in `SuperReader`
  - Updated gesture recognizers in `multi_tap_gesture.dart` to consult a pointer predicate
  - Refactored hit testing in `sliver_hybrid_stack`
- **Location**: `super_editor/lib/src/infrastructure/content_tap_exclusion.dart` (+ touch interactors)
- **Reason**: Prevents interference between inline widget taps and editor selection

### 5. Gesture Detection Fix (PR #1)
- **Commit**: `ae7bc908`
- **Changes**: Removed `IgnorePointer` wrapper in `TextComponent.build()` so gesture detection works on text elements.
- **Location**: `super_editor/lib/src/default_editor/text.dart` (around `class TextComponentState`)
- **Reason**: Fix for gesture detection not working on text elements
- **Re-asserted on each upstream merge** -- upstream periodically reintroduces `IgnorePointer` here. The 2026-05 merge required preserving this divergence again.

## Upstream Sync History

### 2026-05-09 -- Upstream Merge ("2026-05 sync")
- **Merge Commit**: chronologically the merge of `upstream/main` into `chore/align-runtime-version-pins`
- **Range Merged**: 40 commits (`068a20d3..13e7538a`), spanning **2026-02-16 -> 2026-05-07**
- **Version Bumps Adopted**:
  - `super_editor`: `0.3.0-dev.48` -> `0.3.0-dev.51`
  - `super_editor_clipboard`: `0.2.5` -> `0.2.10`
  - `super_text_layout`: `0.1.19` -> `0.1.20`
  - `super_keyboard`: `0.3.1` -> `0.4.0` (minor bump)
  - `attributed_text`: `0.4.5` -> `0.4.7`
- **What We Gained (themes)**:
  - **IME stability**: 5 fixes for SuperEditor IME bugs across Samsung/SwiftKey/GBoard, including the "zombie IME client when one SuperEditor replaces another" bug (#2962, #2965, #2970, #2975, #2979/#2981)
  - **Clipboard**: paste fixes/improvements, native paste corrections, per-format custom pasting from iOS, Markdown paste, ignore `<script>`/`<style>` HTML on paste (#2919, #2926-#2929, #2933, #2935)
  - **Editor UX**: pattern/stable/action tags now support multiple triggers, auto-convert list items when a prefix is added before existing text (#2984), configurable "continue existing list" behavior (#2987), popover toolbars on tablets / non-software-keyboard situations (#2994)
  - **iOS bugfix**: backspacing empty text nodes (#2989)
  - **Flutter SDK adaptation**: `TextInputConnectionDecorator.updateStyle` for an upstream Flutter breaking change (#2950)
  - **`super_text`**: `SuperText` now supports `maxLines` + `overflow` indicator (#2922)
  - **Chat editor**: SuperMessage popover toolbars dismiss after tapping a button; "Preview Mode" plugin (#2937, #2921)
  - **`attributed_text` perf**: rewrote `getAttributionSpansInRange` for performance (#3010)
  - **Package cleanup**: `super_editor_markdown` and `super_editor_quill` deleted (consolidated into `super_editor` core in dev.40/dev.41); we removed the orphaned directories during this merge
- **Conflict Zones Resolved**:
  - `super_editor/lib/src/default_editor/text.dart` -- preserved PR #1's no-`IgnorePointer` while adopting upstream's new `maxLines`/`overflow` `SuperText` props and migrating `hintText` to `computeInlineSpan`
  - `super_editor/lib/src/default_editor/default_document_editor_reactions.dart` -- accepted upstream's two-pattern (empty/non-empty) list-item conversion logic from #2984
  - `super_editor/lib/src/default_editor/document_ime/document_delta_editing.dart` -- removed duplicate `document_serialization.dart` import (already present)
  - `super_editor/pubspec.yaml` + `super_editor/example/pubspec.yaml` -- adopted upstream version bumps; example pubspec keeps fork's monorepo-friendly `path:` deps instead of upstream's `git:` deps
  - `super_editor_markdown/**`, `super_editor_quill/**` -- accepted upstream deletions (35+ files removed)
  - `super_*/example/pubspec.lock` -- kept fork's policy of not tracking example lockfiles
- **Workspace-mode pubspec adds**: re-applied `resolution: workspace` to all 14 sub-package pubspecs as part of this merge
- **Status**: Merge committed; analyzer pass pending

### 2026-02-07 -- Upstream Merge & Dependency Unification
- **Merge Commit**: `de4068f4` -- merged `upstream/main` into `chore/unify-dependencies`
- **Version Jump**: `0.3.0-dev.29` -> `0.3.0-dev.48`
- **What We Gained**:
  - 78+ upstream commits merged, bringing us to upstream HEAD at the time
  - `super_editor_markdown` consolidated into `super_editor` core (v0.3.0-dev.40)
  - `super_editor_quill` consolidated into `super_editor` core (v0.3.0-dev.41)
  - SDK constraint bumps and deprecation fixes (`7cb95bad`)
  - Image builder callback signature updated to named parameters (`e7f0e373`)
  - Test imports and warnings fixed after serialization consolidation (`1a65912d`)
  - Sub-package fixes after upstream merge (`1d9588a1`)
- **Issues Encountered**:
  - `super_editor_markdown` and `super_editor_quill` no longer exist as separate packages (removed from workspace pubspec; directories left in tree until 2026-05 sync removed them)
  - Image builder callback signature changed to use named parameters -- required updating our custom imageBuilder usage
  - Test imports needed fixing after the serialization consolidation

### Previous Merges
- Merged from `superlistapp:main` (commit `244f0f34`)

## Pre-Merge Checklist

When syncing from upstream, do these in order:

1. Run [Verifying Drift](#verifying-drift) and capture before/after counts.
2. Review upstream changelog (`git log --reverse origin/main..upstream/main`) for breaking API changes.
3. Pay special attention to any new touches in:
   - `super_editor/lib/src/default_editor/image.dart` (PR #6)
   - `super_editor/lib/src/default_editor/text.dart` (PR #1 -- `IgnorePointer` likely re-introduced)
   - `super_editor/lib/src/default_editor/attributions.dart` (PR #5 -- `displayLatexAttribution`)
   - Gesture/tap pipeline files (PR #3 -- `ContentTapExclusion`)
   - Document scaffold + super_reader (PR #4 -- `scrollingEnabled`)
4. Run `dart analyze` (or `flutter analyze`) on each sub-package after merge. Any failures usually indicate upstream API drift.
5. Update this document with merge details before merging the PR.

## Why This Fork Exists

1. **Image Component Customization**: Upstream does not support custom image builders with pointer events
2. **LaTeX Attribution**: Not available in upstream; required for Pieces Copilot math rendering
3. **Scroll Control**: Fine-grained scroll enablement not available upstream
4. **Tap Exclusion**: Custom inline widget tap handling not available upstream
5. **Gesture Fixes**: Some gesture detection fixes specific to our usage patterns

## Future Considerations

1. **Upstream Contribution**: `scrollingEnabled` (PR #4) and `ContentTapExclusion` (PR #3) are good candidates to contribute back -- doing so would let us delete two of the five fork-only changes permanently.
2. **LaTeX Support**: Monitor whether upstream adds native LaTeX/math support that supersedes `displayLatexAttribution`.
3. **Regular Sync Cadence**: Aim for an upstream merge each time `super_editor` cuts a new dev release (~4-6 weeks). The 3-month gap before the 2026-05 sync produced 5 conflicting files; a 6-week cadence would likely produce 0-2.
4. **Image Builder API**: Propose image builder enhancements to upstream (PR #6) -- the upstream API has shifted enough times during merges that contributing it back removes recurring rework.

## Contact

For questions about this fork or to request changes, contact the Pieces development team.
