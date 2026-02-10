# Fork Changes Documentation

This document tracks all custom modifications, patches, and deviations from the upstream `Flutter-Bounty-Hunters/super_editor` repository.

## Fork Information

- **Fork Repository**: `https://github.com/pieces-app/super_editor`
- **Upstream Repository**: `https://github.com/Flutter-Bounty-Hunters/super_editor`
- **Current Branch**: `main`
- **Fork Version**: `0.3.0-dev.48`
- **Upstream Latest**: `0.3.0-dev.48` (prerelease), `0.2.7` (stable)
- **Commits Ahead**: 16 (custom modifications)
- **Commits Behind**: ~0 (recently merged)
- **Last Upstream Merge**: February 2026 -- merged `upstream/main` into `chore/unify-dependencies` (commit `de4068f4`)

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
  - Added `displayLatex` attribution for rendering LaTeX content in the editor
  - Fixed typo in displayLatex attribution variable
- **Reason**: Required for rendering mathematical/code content in Pieces Copilot

### 3. Scroll Enablement Flag (PR #4)
- **Commit**: `7a6b2e52`
- **Changes**:
  - Added `scrollingEnabled` flag to document widgets
  - Allows programmatic control over scroll behavior
- **Reason**: Needed to manage scroll behavior in embedded editor contexts

### 4. Content Tap Exclusion (PR #3)
- **Commits**: `b5619720`, `a004dfa2`, `bb68f4c6`
- **Changes**:
  - Enabled tap exclusion for inline widgets in SuperReader
  - Centralized tap exclusion logic for inline placeholders
  - Added documentation for inline tap exclusion
- **Reason**: Prevents interference between inline widget taps and editor selection

### 5. Gesture Detection Fix (PR #1)
- **Commit**: `ae7bc908`
- **Changes**:
  - Removed `IgnorePointer` wrapper so gesture detection works on super text elements
- **Reason**: Fix for gesture detection not working on text elements

## Upstream Sync History

### February 2026 -- Upstream Merge & Dependency Unification
- **Merge Commit**: `de4068f4` -- merged `upstream/main` into `chore/unify-dependencies`
- **Version Jump**: `0.3.0-dev.29` -> `0.3.0-dev.48`
- **What We Gained**:
  - 78+ upstream commits merged, bringing us to current upstream HEAD
  - `super_editor_markdown` consolidated into `super_editor` core (v0.3.0-dev.40)
  - `super_editor_quill` consolidated into `super_editor` core (v0.3.0-dev.41)
  - SDK constraint bumps and deprecation fixes (`7cb95bad`)
  - Image builder callback signature updated to named parameters (`e7f0e373`)
  - Test imports and warnings fixed after serialization consolidation (`1a65912d`)
  - Sub-package fixes after upstream merge (`1d9588a1`)
- **Issues Encountered**:
  - `super_editor_markdown` and `super_editor_quill` no longer exist as separate packages (removed from workspace)
  - Image builder callback signature changed to use named parameters -- required updating our custom imageBuilder usage
  - Test imports needed fixing after the serialization consolidation
- **Status**: Successfully merged and stabilized

### Previous Merges
- Merged from `superlistapp:main` (commit `244f0f34`)

## Upstream Sync Status

- **Current Gap**: ~0 commits behind upstream/main (recently merged February 2026)
- **Status**: Up to date with upstream
- **Next Sync Target**: Monitor upstream for new dev releases past `0.3.0-dev.48`

### Before Merging Upstream Changes
1. Review upstream changelog for breaking API changes
2. Check if any of our custom modifications conflict
3. Pay special attention to changes in `image.dart` and gesture handling
4. Run full test suite after merge
5. Update this document with merge details

## Why This Fork Exists

1. **Image Component Customization**: Upstream does not support custom image builders with pointer events
2. **LaTeX Attribution**: Not available in upstream; required for Pieces Copilot math rendering
3. **Scroll Control**: Fine-grained scroll enablement not available upstream
4. **Tap Exclusion**: Custom inline widget tap handling not available upstream
5. **Gesture Fixes**: Some gesture detection fixes specific to our usage patterns

## Future Considerations

1. **Upstream Contribution**: Consider contributing scroll enablement and tap exclusion features back to upstream
2. **LaTeX Support**: Monitor if upstream adds native LaTeX/math support
3. **Regular Sync**: Establish cadence for merging upstream dev releases
4. **Image Builder API**: Propose image builder enhancements to upstream

## Contact

For questions about this fork or to request changes, contact the Pieces development team.
