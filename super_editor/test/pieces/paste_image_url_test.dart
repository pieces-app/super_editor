import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/super_editor.dart';

void main() {
  group("Paste image/video URL >", () {
    group("into non-paragraph nodes >", () {
      test("paste image URL into list item inserts linked text", () {
        final editor = _createEditor(
          nodes: [
            ListItemNode.unordered(id: "1", text: AttributedText("my bullet")),
          ],
        );

        _pasteAt(editor, nodeId: "1", offset: 9, content: "https://example.com/photo.png");

        expect(editor.document.nodeCount, 1);
        final listItem = editor.document.first as ListItemNode;
        expect(listItem.text.toPlainText(), "my bullethttps://example.com/photo.png");

        final spans = _linkSpans(listItem.text);
        expect(spans.length, 1);
        expect(spans.first.start, 9);
        expect(spans.first.end, 37);
      });

      test("paste video URL into list item inserts linked text", () {
        final editor = _createEditor(
          nodes: [
            ListItemNode.ordered(id: "1", text: AttributedText("step one")),
          ],
        );

        _pasteAt(editor, nodeId: "1", offset: 8, content: "https://example.com/clip.mp4");

        expect(editor.document.nodeCount, 1);
        final listItem = editor.document.first as ListItemNode;
        expect(listItem.text.toPlainText(), "step onehttps://example.com/clip.mp4");

        final spans = _linkSpans(listItem.text);
        expect(spans.length, 1);
        expect(spans.first.start, 8);
        expect(spans.first.end, 35);
      });

      test("paste image URL into task inserts linked text", () {
        final editor = _createEditor(
          nodes: [
            TaskNode(id: "1", text: AttributedText("my task"), isComplete: false),
          ],
        );

        _pasteAt(editor, nodeId: "1", offset: 7, content: "https://example.com/screenshot.jpg");

        expect(editor.document.nodeCount, 1);
        final task = editor.document.first as TaskNode;
        expect(task.text.toPlainText(), "my taskhttps://example.com/screenshot.jpg");

        final spans = _linkSpans(task.text);
        expect(spans.length, 1);
        expect(spans.first.start, 7);
        expect(spans.first.end, 40);
      });

      test("paste image URL into empty list item inserts linked text", () {
        final editor = _createEditor(
          nodes: [
            ListItemNode.unordered(id: "1", text: AttributedText()),
          ],
        );

        _pasteAt(editor, nodeId: "1", offset: 0, content: "https://example.com/photo.png");

        expect(editor.document.nodeCount, 1);
        final listItem = editor.document.first as ListItemNode;
        expect(listItem.text.toPlainText(), "https://example.com/photo.png");

        final spans = _linkSpans(listItem.text);
        expect(spans.length, 1);
      });
    });

    group("into paragraph >", () {
      test("paste image URL into empty paragraph inserts image node", () {
        final editor = _createEditor(
          nodes: [
            ParagraphNode(id: "1", text: AttributedText()),
          ],
        );

        _pasteAt(editor, nodeId: "1", offset: 0, content: "https://example.com/photo.png");

        final hasImageNode = editor.document.toList().any((node) => node is ImageNode);
        expect(hasImageNode, isTrue);
      });

      test("paste image URL at end of non-empty paragraph places caret below image", () {
        final editor = _createEditor(
          nodes: [
            ParagraphNode(id: "p1", text: AttributedText("Hello")),
          ],
        );

        _pasteAt(editor, nodeId: "p1", offset: 5, content: "https://example.com/photo.png");

        // Document should be: ParagraphNode("Hello"), ImageNode, ParagraphNode("")
        expect(editor.document.nodeCount, 3);
        expect(editor.document.getNodeAt(0), isA<ParagraphNode>());
        expect((editor.document.getNodeAt(0)! as ParagraphNode).text.toPlainText(), "Hello");
        expect(editor.document.getNodeAt(1), isA<ImageNode>());
        expect(editor.document.getNodeAt(2), isA<ParagraphNode>());

        // The caret should be in the empty paragraph below the image,
        // not back at the end of "Hello" above it.
        final selection = editor.composer.selection;
        expect(selection, isNotNull);
        expect(selection!.extent.nodeId, editor.document.getNodeAt(2)!.id);
      });
    });
  });
}

Editor _createEditor({required List<DocumentNode> nodes}) {
  return createDefaultDocumentEditor(
    document: MutableDocument(nodes: nodes),
  );
}

void _pasteAt(Editor editor, {required String nodeId, required int offset, required String content}) {
  final position = DocumentPosition(nodeId: nodeId, nodePosition: TextNodePosition(offset: offset));
  editor.execute([
    ChangeSelectionRequest(
      DocumentSelection.collapsed(position: position),
      SelectionChangeType.placeCaret,
      SelectionReason.userInteraction,
    ),
  ]);
  editor.execute([
    PasteEditorRequest(content: content, pastePosition: position),
  ]);
}

List<AttributionSpan> _linkSpans(AttributedText text) {
  return text
      .getAttributionSpansInRange(
        attributionFilter: (a) => a is LinkAttribution,
        range: SpanRange(0, text.length - 1),
      )
      .toList();
}
