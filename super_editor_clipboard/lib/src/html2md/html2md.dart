// Vendored from https://github.com/jarontai/html2md (v1.3.2)
// Copyright (c) 2017, jarontai. All rights reserved.
// BSD 2-Clause License. See: https://github.com/jarontai/html2md/blob/master/LICENSE
//
// Vendored because the published html2md v1.3.2 has SDK constraint
// '>=2.12.0 <3.0.0' which is incompatible with Dart 3.6+.
// The code itself is Dart 3 compatible — only the constraint was blocking.

/// Convert HTML to Markdown.
library html2md;

export 'converter.dart' show convert;
export 'rules.dart' show Rule, FilterFn, ReplacementFn, AppendFn;
export 'node.dart' show Node;
