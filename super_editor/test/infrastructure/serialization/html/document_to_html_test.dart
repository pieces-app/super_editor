import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/src/infrastructure/serialization/html/document_to_html.dart';
import 'package:super_editor/src/infrastructure/serialization/html/html_inline_text_styles.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_markdown/super_editor_markdown.dart';

void main() {
  group("Super Editor > HTML serialization >", () {
    test("whole document", () {
      expect(
        _createDiverseDocument().toHtml(),
        _getDiverseDocumentHtmlGolden(),
      );
    });

    test("partial document from middle to end", () {
      expect(
        _createDiverseDocument().toHtml(
          selection: const DocumentSelection(
            base: DocumentPosition(
              nodeId: "8",
              nodePosition: TextNodePosition(offset: 15),
            ),
            extent: DocumentPosition(
              nodeId: "14",
              nodePosition: TextNodePosition(offset: 28),
            ),
          ),
        ),
        [
          '<p>separates an unordered list from an ordered list.</p>',
          '<ol>',
          '<li>This is ordered list item 1</li>',
          '<li>This is ordered list item 2</li>',
          '<li>This is ordered list item 3</li>',
          '</ol>',
          '<blockquote>This is a blockquote</blockquote>',
          '<pre><code>This is a code block</code></pre>',
          '<p>This is the final paragraph.</p>',
        ].join(),
      );
    });

    test("partial document from beginning to middle", () {
      expect(
        _createDiverseDocument().toHtml(
          selection: const DocumentSelection(
            base: DocumentPosition(
              nodeId: "1",
              nodePosition: TextNodePosition(offset: 0),
            ),
            extent: DocumentPosition(
              nodeId: "8",
              nodePosition: TextNodePosition(offset: 15),
            ),
          ),
        ),
        [
          '<h1>This is a header 1</h1>',
          '<p>This is a regular paragraph of text.</p>',
          '<img src="https://doesnotexist.com/image.png">',
          '<p>This is another regular paragraph.</p>',
          '<ul>',
          '<li>This is unordered list item 1</li>',
          '<li>This is unordered list item 2</li>',
          '<li>This is unordered list item 3</li>',
          '</ul>',
          '<p>This paragraph </p>',
        ].join(),
      );
    });

    test("partial document from middle to middle", () {
      expect(
        _createDiverseDocument().toHtml(
          selection: const DocumentSelection(
            base: DocumentPosition(
              nodeId: "6",
              nodePosition: TextNodePosition(offset: 8),
            ),
            extent: DocumentPosition(
              nodeId: "13",
              nodePosition: TextNodePosition(offset: 14),
            ),
          ),
        ),
        [
          '<li>unordered list item 2</li>',
          '<li>This is unordered list item 3</li>',
          '</ul>',
          '<p>This paragraph separates an unordered list from an ordered list.</p>',
          '<ol>',
          '<li>This is ordered list item 1</li>',
          '<li>This is ordered list item 2</li>',
          '<li>This is ordered list item 3</li>',
          '</ol>',
          '<blockquote>This is a blockquote</blockquote>',
          '<pre><code>This is a code</code></pre>',
        ].join(),
      );
    });

    group("start or end of block >", () {
      test("starting at end of paragraph", () {
        final document = MutableDocument(
          nodes: [
            ParagraphNode(id: "1", text: AttributedText("This is paragraph 1")),
            ParagraphNode(id: "2", text: AttributedText("This is paragraph 2")),
          ],
        );

        expect(
          document.toHtml(
            selection: const DocumentSelection(
              base: DocumentPosition(
                nodeId: "1",
                nodePosition: TextNodePosition(offset: 19),
              ),
              extent: DocumentPosition(
                nodeId: "2",
                nodePosition: TextNodePosition(offset: 19),
              ),
            ),
          ),
          "<p>This is paragraph 2</p>",
        );
      });

      test("ending at beginning of paragraph", () {
        final document = MutableDocument(
          nodes: [
            ParagraphNode(id: "1", text: AttributedText("This is paragraph 1")),
            ParagraphNode(id: "2", text: AttributedText("This is paragraph 2")),
          ],
        );

        expect(
          document.toHtml(
            selection: const DocumentSelection(
              base: DocumentPosition(
                nodeId: "1",
                nodePosition: TextNodePosition(offset: 0),
              ),
              extent: DocumentPosition(
                nodeId: "2",
                nodePosition: TextNodePosition(offset: 0),
              ),
            ),
          ),
          "<p>This is paragraph 1</p>",
        );
      });

      test("from caret on downstream edge of image to paragraph", () {
        final document = MutableDocument(
          nodes: [
            ImageNode(id: "1", imageUrl: "https://doesnotexist.com/image.png"),
            ParagraphNode(id: "2", text: AttributedText("This is paragraph 1")),
          ],
        );

        expect(
          document.toHtml(
            selection: const DocumentSelection(
              base: DocumentPosition(
                nodeId: "1",
                nodePosition: UpstreamDownstreamNodePosition.downstream(),
              ),
              extent: DocumentPosition(
                nodeId: "2",
                nodePosition: TextNodePosition(offset: 19),
              ),
            ),
          ),
          "<p>This is paragraph 1</p>",
        );
      });

      test("from paragraph to caret on upstream edge of image", () {
        final document = MutableDocument(
          nodes: [
            ParagraphNode(id: "1", text: AttributedText("This is paragraph 1")),
            ImageNode(id: "2", imageUrl: "https://doesnotexist.com/image.png"),
          ],
        );

        expect(
          document.toHtml(
            selection: const DocumentSelection(
              base: DocumentPosition(
                nodeId: "1",
                nodePosition: TextNodePosition(offset: 0),
              ),
              extent: DocumentPosition(
                nodeId: "2",
                nodePosition: UpstreamDownstreamNodePosition.upstream(),
              ),
            ),
          ),
          "<p>This is paragraph 1</p>",
        );
      });
    });

    group("collapsed selections >", () {
      test("end of paragraph to beginning of paragraph", () {
        final document = MutableDocument(
          nodes: [
            ParagraphNode(id: "1", text: AttributedText("This is a paragraph 1")),
            ParagraphNode(id: "2", text: AttributedText("This is a paragraph 2")),
          ],
        );

        expect(
          document.toHtml(
            selection: const DocumentSelection(
              base: DocumentPosition(
                nodeId: "1",
                nodePosition: TextNodePosition(offset: 21),
              ),
              extent: DocumentPosition(
                nodeId: "2",
                nodePosition: TextNodePosition(offset: 0),
              ),
            ),
          ),
          "",
        );
      });

      test("caret in paragraph", () {
        final document = MutableDocument(
          nodes: [
            ParagraphNode(id: "1", text: AttributedText("This is a paragraph of text")),
          ],
        );

        expect(
          document.toHtml(
            selection: const DocumentSelection.collapsed(
              position: DocumentPosition(
                nodeId: "1",
                nodePosition: TextNodePosition(offset: 3),
              ),
            ),
          ),
          "",
        );
      });

      test("caret in image", () {
        final document = MutableDocument(
          nodes: [
            ImageNode(id: "1", imageUrl: "https://doesnotexist.com/image.png"),
          ],
        );

        expect(
          document.toHtml(
            selection: const DocumentSelection.collapsed(
              position: DocumentPosition(
                nodeId: "1",
                nodePosition: UpstreamDownstreamNodePosition.upstream(),
              ),
            ),
          ),
          "",
        );
      });
    });

    test("inline text styles", () {
      expect(
        deserializeMarkdownToDocument(
          "This paragraph contains many inline styles: **bold**, *italics*, ¬underline¬, ~strikethrough~, [link](https://someplace.com).",
        ).toHtml(),
        '<p>This paragraph contains many inline styles: <strong>bold</strong>, <i>italics</i>, <u>underline</u>, <s>strikethrough</s>, <a href="https://someplace.com">link</a>.</p>',
      );
    });

    group("custom serialization >", () {
      test("custom node type", () {
        expect(
          MutableDocument(
            nodes: [
              ParagraphNode(
                id: "1",
                text: AttributedText("Custom Nodes"),
                metadata: const {
                  NodeMetadata.blockType: header1Attribution,
                },
              ),
              ParagraphNode(
                id: "2",
                text: AttributedText("Below this is a custom table node serialization."),
              ),
              _TableNode(id: "3"),
            ],
          ).toHtml(
            nodeSerializers: [
              _tableHtmlSerializer,
              ...defaultNodeHtmlSerializerChain,
            ],
          ),
          [
            '<h1>Custom Nodes</h1>',
            '<p>Below this is a custom table node serialization.</p>',
            '<table>',
            '<tr>',
            '<th>Column 1</th>',
            '<th>Column 2</th>',
            '</tr>',
            '<tr>',
            '<th>Value 1</th>',
            '<td>Value 2</td>',
            '</tr>',
            '</table>',
          ].join(''),
        );
      });

      test("custom inline text style", () {
        expect(
          MutableDocument(
            nodes: [
              ParagraphNode(
                id: "1",
                text: AttributedText(
                  "This paragraph contains custom styling.",
                  AttributedSpans(
                    attributions: [
                      const SpanMarker(attribution: _customStyle, offset: 24, markerType: SpanMarkerType.start),
                      const SpanMarker(attribution: _customStyle, offset: 37, markerType: SpanMarkerType.end),
                    ],
                  ),
                ),
              ),
            ],
          ).toHtml(
            inlineSerializers: [
              (Attribution attribution, TagType tagType) {
                if (attribution != _customStyle) {
                  return null;
                }

                return switch (tagType) {
                  TagType.opening => '<mytag>',
                  TagType.closing => '</mytag>',
                };
              },
              ...defaultInlineHtmlSerializers,
            ],
          ),
          "<p>This paragraph contains <mytag>custom styling</mytag>.</p>",
        );
      });
    });
  });
}

Document _createDiverseDocument() => MutableDocument(
      nodes: [
        ParagraphNode(
          id: "1",
          text: AttributedText("This is a header 1"),
          metadata: const {
            NodeMetadata.blockType: header1Attribution,
          },
        ),
        ParagraphNode(
          id: "2",
          text: AttributedText("This is a regular paragraph of text."),
        ),
        ImageNode(id: "3", imageUrl: "https://doesnotexist.com/image.png"),
        ParagraphNode(
          id: "4",
          text: AttributedText("This is another regular paragraph."),
        ),
        ListItemNode.unordered(
          id: "5",
          text: AttributedText("This is unordered list item 1"),
        ),
        ListItemNode.unordered(
          id: "6",
          text: AttributedText("This is unordered list item 2"),
        ),
        ListItemNode.unordered(
          id: "7",
          text: AttributedText("This is unordered list item 3"),
        ),
        ParagraphNode(
          id: "8",
          text: AttributedText("This paragraph separates an unordered list from an ordered list."),
        ),
        ListItemNode.ordered(
          id: "9",
          text: AttributedText("This is ordered list item 1"),
        ),
        ListItemNode.ordered(
          id: "10",
          text: AttributedText("This is ordered list item 2"),
        ),
        ListItemNode.ordered(
          id: "11",
          text: AttributedText("This is ordered list item 3"),
        ),
        ParagraphNode(
          id: "12",
          text: AttributedText("This is a blockquote"),
          metadata: const {
            NodeMetadata.blockType: blockquoteAttribution,
          },
        ),
        ParagraphNode(
          id: "13",
          text: AttributedText("This is a code block"),
          metadata: const {
            NodeMetadata.blockType: codeAttribution,
          },
        ),
        ParagraphNode(
          id: "14",
          text: AttributedText("This is the final paragraph."),
        ),
      ],
    );

String _getDiverseDocumentHtmlGolden() => [
      '<h1>This is a header 1</h1>',
      '<p>This is a regular paragraph of text.</p>',
      '<img src="https://doesnotexist.com/image.png">',
      '<p>This is another regular paragraph.</p>',
      '<ul>',
      '<li>This is unordered list item 1</li>',
      '<li>This is unordered list item 2</li>',
      '<li>This is unordered list item 3</li>',
      '</ul>',
      '<p>This paragraph separates an unordered list from an ordered list.</p>',
      '<ol>',
      '<li>This is ordered list item 1</li>',
      '<li>This is ordered list item 2</li>',
      '<li>This is ordered list item 3</li>',
      '</ol>',
      '<blockquote>This is a blockquote</blockquote>',
      '<pre><code>This is a code block</code></pre>',
      '<p>This is the final paragraph.</p>',
    ].join();

const _customStyle = NamedAttribution("custom_style");

String? _tableHtmlSerializer(
  Document document,
  DocumentNode node,
  NodeSelection? selection,
  InlineHtmlSerializerChain inlineSerializers,
) {
  if (node is! _TableNode) {
    return null;
  }
  if (selection != null) {
    if (selection is! UpstreamDownstreamNodeSelection) {
      // We don't know how to handle this selection type.
      return null;
    }
    if (selection.isCollapsed) {
      // This selection doesn't include the image - it's a collapsed selection
      // either on the upstream or downstream edge.
      return null;
    }
  }

  return [
    '<table>',
    '<tr>',
    '<th>Column 1</th>',
    '<th>Column 2</th>',
    '</tr>',
    '<tr>',
    '<th>Value 1</th>',
    '<td>Value 2</td>',
    '</tr>',
    '</table>',
  ].join('');
}

class _TableNode extends BlockNode {
  _TableNode({
    required this.id,
  });

  @override
  final String id;

  @override
  DocumentNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    throw UnimplementedError();
  }

  @override
  DocumentNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    throw UnimplementedError();
  }

  @override
  String? copyContent(NodeSelection selection) {
    throw UnimplementedError();
  }
}
