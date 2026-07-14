import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/src/test/super_editor_test/supereditor_test_tools.dart';
import 'package:super_editor/super_editor.dart';

void main() {
  group("Paste >", () {
    group("multi-node content >", () {
      test("paste single paragraph into empty paragraph", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [ParagraphNode(id: "1", text: AttributedText())],
          ),
        );

        editor.execute([
          PasteStructuredContentEditorRequest(
            content: MutableDocument(
              nodes: [
                ParagraphNode(id: "2", text: AttributedText("Hello, World!")),
              ],
            ),
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 0)),
          ),
        ]);

        expect(
          editor.document,
          documentEquivalentTo(
            MutableDocument(
              nodes: [
                ParagraphNode(id: "1", text: AttributedText("Hello, World!")),
              ],
            ),
          ),
        );
        expect(
          editor.composer.selection,
          const DocumentSelection.collapsed(
            position: DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 13)),
          ),
        );
      });

      test("paste single paragraph into middle of paragraph", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [ParagraphNode(id: "1", text: AttributedText("abcdefghi"))],
          ),
        );

        editor.execute([
          PasteStructuredContentEditorRequest(
            content: MutableDocument(
              nodes: [
                ParagraphNode(id: "2", text: AttributedText("Hello, World!")),
              ],
            ),
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 4)),
          ),
        ]);

        expect(
          editor.document,
          documentEquivalentTo(
            MutableDocument(
              nodes: [
                ParagraphNode(id: "1", text: AttributedText("abcdHello, World!efghi")),
              ],
            ),
          ),
        );
        expect(
          editor.composer.selection,
          const DocumentSelection.collapsed(
            position: DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 17)),
          ),
        );
      });

      test("paste table in empty paragraph", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [ParagraphNode(id: "1", text: AttributedText())],
          ),
        );

        // Place the caret so we know where to paste.
        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(
                nodeId: "1",
                nodePosition: TextNodePosition(offset: 0),
              ),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        // Paste a table.
        editor.execute([
          PasteStructuredContentEditorRequest(
            content: MutableDocument(nodes: [
              _table,
            ]),
            pastePosition: const DocumentPosition(
              nodeId: "1",
              nodePosition: TextNodePosition(offset: 0),
            ),
          ),
        ]);

        // Ensure the HTML was turned into the expected document, with the
        // expected selection.
        expect(
          editor.document,
          documentEquivalentTo(
            MutableDocument(
              nodes: [
                _table,
                ParagraphNode(id: editor.document.last.id, text: AttributedText()),
              ],
            ),
          ),
        );
        expect(
          editor.composer.selection,
          DocumentSelection.collapsed(
            position: DocumentPosition(
              nodeId: editor.document.last.id,
              nodePosition: const TextNodePosition(offset: 0),
            ),
          ),
        );
      });

      test("paste table in middle of paragraph", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [ParagraphNode(id: "1", text: AttributedText("abcdefgh"))],
          ),
        );

        // Place the caret so we know where to paste.
        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(
                nodeId: "1",
                nodePosition: TextNodePosition(offset: 4),
              ),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        // Paste a table.
        editor.execute([
          PasteStructuredContentEditorRequest(
            content: MutableDocument(nodes: [
              _table,
            ]),
            pastePosition: const DocumentPosition(
              nodeId: "1",
              nodePosition: TextNodePosition(offset: 4),
            ),
          ),
        ]);

        // Ensure the HTML was turned into the expected document, with the
        // expected selection.
        expect(
          editor.document,
          documentEquivalentTo(
            MutableDocument(
              nodes: [
                ParagraphNode(id: "1", text: AttributedText("abcd")),
                _table,
                ParagraphNode(id: editor.document.last.id, text: AttributedText("efgh")),
              ],
            ),
          ),
        );
        expect(
          editor.composer.selection,
          DocumentSelection.collapsed(
            position: DocumentPosition(
              nodeId: editor.document.last.id,
              nodePosition: const TextNodePosition(offset: 0),
            ),
          ),
        );
      });

      test("paste multiple nodes into empty paragraph", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [ParagraphNode(id: "1", text: AttributedText())],
          ),
        );

        editor.execute([
          PasteStructuredContentEditorRequest(
            content: MutableDocument(
              nodes: [
                ParagraphNode(id: "2", text: AttributedText("One")),
                ParagraphNode(id: "3", text: AttributedText("Two")),
                ParagraphNode(id: "4", text: AttributedText("Three")),
              ],
            ),
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 0)),
          ),
        ]);

        expect(
          editor.document,
          documentEquivalentTo(
            MutableDocument(
              nodes: [
                ParagraphNode(id: "1", text: AttributedText("One")),
                ParagraphNode(id: "3", text: AttributedText("Two")),
                ParagraphNode(id: "4", text: AttributedText("Three")),
              ],
            ),
          ),
        );
        expect(
          editor.composer.selection,
          const DocumentSelection.collapsed(
            position: DocumentPosition(nodeId: "4", nodePosition: TextNodePosition(offset: 5)),
          ),
        );
      });

      test("paste multiple nodes into middle of paragraph", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [ParagraphNode(id: "1", text: AttributedText("abcdefghi"))],
          ),
        );

        editor.execute([
          PasteStructuredContentEditorRequest(
            content: MutableDocument(
              nodes: [
                ParagraphNode(id: "2", text: AttributedText("One")),
                ParagraphNode(id: "3", text: AttributedText("Two")),
                ParagraphNode(id: "4", text: AttributedText("Three")),
              ],
            ),
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 4)),
          ),
        ]);

        expect(
          editor.document,
          documentEquivalentTo(
            MutableDocument(
              nodes: [
                ParagraphNode(id: "1", text: AttributedText("abcdOne")),
                ParagraphNode(id: "3", text: AttributedText("Two")),
                ParagraphNode(id: "4", text: AttributedText("Threeefghi")),
              ],
            ),
          ),
        );

        expect(
          editor.composer.selection,
          DocumentSelection.collapsed(
            position:
                DocumentPosition(nodeId: editor.document.last.id, nodePosition: const TextNodePosition(offset: 5)),
          ),
        );
      });
    });

    group("image/video URL into non-paragraph nodes >", () {
      test("paste image URL into list item inserts linked text", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [
              ListItemNode.unordered(id: "1", text: AttributedText("my bullet")),
            ],
          ),
        );

        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 9)),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        editor.execute([
          PasteEditorRequest(
            content: "https://example.com/photo.png",
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 9)),
          ),
        ]);

        // The document should still have exactly one node (the list item).
        expect(editor.document.nodeCount, 1);
        final node = editor.document.first;
        expect(node, isA<ListItemNode>());

        // The URL should be inserted as text.
        final listItem = node as ListItemNode;
        expect(listItem.text.toPlainText(), "my bullethttps://example.com/photo.png");

        // The inserted URL should carry a LinkAttribution.
        final spans = listItem.text.getAttributionSpansInRange(
          attributionFilter: (a) => a is LinkAttribution,
          range: SpanRange(0, listItem.text.length - 1),
        );
        expect(spans.length, 1);
        expect(spans.first.start, 9);
        expect(spans.first.end, 37);
      });

      test("paste video URL into list item inserts linked text", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [
              ListItemNode.ordered(id: "1", text: AttributedText("step one")),
            ],
          ),
        );

        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 8)),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        editor.execute([
          PasteEditorRequest(
            content: "https://example.com/clip.mp4",
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 8)),
          ),
        ]);

        expect(editor.document.nodeCount, 1);
        final node = editor.document.first;
        expect(node, isA<ListItemNode>());

        final listItem = node as ListItemNode;
        expect(listItem.text.toPlainText(), "step onehttps://example.com/clip.mp4");

        final spans = listItem.text.getAttributionSpansInRange(
          attributionFilter: (a) => a is LinkAttribution,
          range: SpanRange(0, listItem.text.length - 1),
        );
        expect(spans.length, 1);
        expect(spans.first.start, 8);
        expect(spans.first.end, 35);
      });

      test("paste image URL into task inserts linked text", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [
              TaskNode(id: "1", text: AttributedText("my task"), isComplete: false),
            ],
          ),
        );

        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 7)),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        editor.execute([
          PasteEditorRequest(
            content: "https://example.com/screenshot.jpg",
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 7)),
          ),
        ]);

        expect(editor.document.nodeCount, 1);
        final node = editor.document.first;
        expect(node, isA<TaskNode>());

        final task = node as TaskNode;
        expect(task.text.toPlainText(), "my taskhttps://example.com/screenshot.jpg");

        final spans = task.text.getAttributionSpansInRange(
          attributionFilter: (a) => a is LinkAttribution,
          range: SpanRange(0, task.text.length - 1),
        );
        expect(spans.length, 1);
        expect(spans.first.start, 7);
        expect(spans.first.end, 40);
      });

      test("paste image URL into empty list item inserts linked text", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [
              ListItemNode.unordered(id: "1", text: AttributedText()),
            ],
          ),
        );

        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 0)),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        editor.execute([
          PasteEditorRequest(
            content: "https://example.com/photo.png",
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 0)),
          ),
        ]);

        expect(editor.document.nodeCount, 1);
        final node = editor.document.first;
        expect(node, isA<ListItemNode>());

        final listItem = node as ListItemNode;
        expect(listItem.text.toPlainText(), "https://example.com/photo.png");

        final spans = listItem.text.getAttributionSpansInRange(
          attributionFilter: (a) => a is LinkAttribution,
          range: SpanRange(0, listItem.text.length - 1),
        );
        expect(spans.length, 1);
      });

      test("paste image URL into paragraph still inserts image node", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [
              ParagraphNode(id: "1", text: AttributedText()),
            ],
          ),
        );

        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 0)),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        editor.execute([
          PasteEditorRequest(
            content: "https://example.com/photo.png",
            pastePosition: const DocumentPosition(nodeId: "1", nodePosition: TextNodePosition(offset: 0)),
          ),
        ]);

        // For paragraphs, the image should be inserted as an ImageNode.
        final hasImageNode = editor.document.toList().any((node) => node is ImageNode);
        expect(hasImageNode, isTrue);
      });

      test("paste image URL at end of non-empty paragraph places caret below image", () {
        final editor = createDefaultDocumentEditor(
          document: MutableDocument(
            nodes: [
              ParagraphNode(id: "p1", text: AttributedText("Hello")),
            ],
          ),
        );

        editor.execute([
          const ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(nodeId: "p1", nodePosition: TextNodePosition(offset: 5)),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          ),
        ]);

        editor.execute([
          PasteEditorRequest(
            content: "https://example.com/photo.png",
            pastePosition: const DocumentPosition(nodeId: "p1", nodePosition: TextNodePosition(offset: 5)),
          ),
        ]);

        // Document should be: ParagraphNode("Hello"), ImageNode, ParagraphNode("")
        expect(editor.document.nodeCount, 3);
        expect(editor.document.getNodeAt(0), isA<ParagraphNode>());
        expect((editor.document.getNodeAt(0)! as ParagraphNode).text.toPlainText(), "Hello");
        expect(editor.document.getNodeAt(1), isA<ImageNode>());
        expect(editor.document.getNodeAt(2), isA<ParagraphNode>());

        // The caret should be in the empty paragraph below the image,
        // not back at the end of "Hello" above the image.
        final selection = editor.composer.selection;
        expect(selection, isNotNull);
        expect(selection!.extent.nodeId, editor.document.getNodeAt(2)!.id);
      });
    });
  });
}

final _table = TableBlockNode(id: "table", cells: [
  [
    TextNode(
      id: "1.1",
      text: AttributedText("BMI Category"),
      metadata: const {
        NodeMetadata.blockType: tableHeaderAttribution,
      },
    ),
    TextNode(
      id: "1.2",
      text: AttributedText("BMI Range (kg/m²)"),
      metadata: const {
        NodeMetadata.blockType: tableHeaderAttribution,
      },
    ),
  ],
  [
    TextNode(
      id: "2.1",
      text: AttributedText("Underweight"),
    ),
    TextNode(
      id: "2.2",
      text: AttributedText("< 18.5"),
    ),
  ],
  [
    TextNode(
      id: "3.1",
      text: AttributedText("Normal weight"),
    ),
    TextNode(
      id: "3.2",
      text: AttributedText("18.5 – 24.9"),
    ),
  ],
  [
    TextNode(
      id: "4.1",
      text: AttributedText("Overweight"),
    ),
    TextNode(
      id: "4.2",
      text: AttributedText("25.0 - 29.9"),
    ),
  ],
  [
    TextNode(
      id: "5.1",
      text: AttributedText("Obesity (Class I)"),
    ),
    TextNode(
      id: "5.2",
      text: AttributedText("30.0 - 34.9"),
    ),
  ],
  [
    TextNode(
      id: "6.1",
      text: AttributedText("Obesity (Class II)"),
    ),
    TextNode(
      id: "6.2",
      text: AttributedText("35.0 - 39.9"),
    ),
  ],
  [
    TextNode(
      id: "7.1",
      text: AttributedText("Obesity (Class III)"),
    ),
    TextNode(
      id: "7.2",
      text: AttributedText("≥ 40.0"),
    ),
  ],
]);
