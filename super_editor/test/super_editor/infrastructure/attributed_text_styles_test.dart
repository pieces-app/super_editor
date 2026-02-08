import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/super_editor.dart';

void main() {
  group('Attributed Text', () {
    testWidgets('no styles', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final text = AttributedText('abcdefghij');
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, 'abcdefghij');
      expect(textSpan.children, null);
    });

    testWidgets('full-span style', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final text = attributedTextFromMarkdown("**abcdefghij**");
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, 'abcdefghij');
      expect(textSpan.style!.fontWeight, FontWeight.bold);
      expect(textSpan.children, null);
    });

    testWidgets('single character style', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final text = attributedTextFromMarkdown("a**b**cdefghij");
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 3);
      expect(textSpan.children![0].toPlainText(), 'a');
      expect(textSpan.children![1].toPlainText(), 'b');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].toPlainText(), 'cdefghij');
      expect(textSpan.children![2].style!.fontWeight, null);
    });

    testWidgets('single character style - reverse order', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final text = AttributedText(
        'abcdefghij',
        AttributedSpans(
          attributions: [
            // Notice that the markers are provided in reverse order:
            // end then start. Order shouldn't matter within a single
            // position index. This test ensures that.
            const SpanMarker(attribution: ExpectedSpans.bold, offset: 1, markerType: SpanMarkerType.end),
            const SpanMarker(attribution: ExpectedSpans.bold, offset: 1, markerType: SpanMarkerType.start),
          ],
        ),
      );
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 3);
      expect(textSpan.children![0].toPlainText(), 'a');
      expect(textSpan.children![1].toPlainText(), 'b');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].toPlainText(), 'cdefghij');
      expect(textSpan.children![2].style!.fontWeight, null);
    });

    testWidgets('add single character style', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final text = AttributedText('abcdefghij');
      text.addAttribution(ExpectedSpans.bold, const SpanRange(1, 1));
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 3);
      expect(textSpan.children![0].toPlainText(), 'a');
      expect(textSpan.children![1].toPlainText(), 'b');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].toPlainText(), 'cdefghij');
      expect(textSpan.children![2].style!.fontWeight, null);
    });

    testWidgets('partial style', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final text = attributedTextFromMarkdown("ab**cdefgh**ij");
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 3);
      expect(textSpan.children![0].toPlainText(), 'ab');
      expect(textSpan.children![1].toPlainText(), 'cdefgh');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].toPlainText(), 'ij');
    });

    testWidgets('add styled character to existing styled text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final initialText = attributedTextFromMarkdown("abcdefghi**j**");

      final newText = initialText.copyAndAppend(AttributedText(
        'k',
        AttributedSpans(
          attributions: [
            const SpanMarker(attribution: ExpectedSpans.bold, offset: 0, markerType: SpanMarkerType.start),
            const SpanMarker(attribution: ExpectedSpans.bold, offset: 0, markerType: SpanMarkerType.end),
          ],
        ),
      ));

      final textSpan = newText.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 2);
      expect(textSpan.children![0].toPlainText(), 'abcdefghi');

      // Ensures that typing a styled character at the end of text
      // results in a single expanded span, rather than 2 independent
      // spans with the same style.
      expect(textSpan.children![1].toPlainText(), 'jk');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![1].style!.fontStyle, null);
    });

    testWidgets('non-mingled varying styles', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final text = attributedTextFromMarkdown("**abcde***fghij*");
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 2);
      expect(textSpan.children![0].toPlainText(), 'abcde');
      expect(textSpan.children![0].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![0].style!.fontStyle, null);
      expect(textSpan.children![1].toPlainText(), 'fghij');
      expect(textSpan.children![1].style!.fontWeight, null);
      expect(textSpan.children![1].style!.fontStyle, FontStyle.italic);
    });

    testWidgets('intermingled varying styles', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      // Note: we configure attributed text directly because Markdown doesn't know
      // how to parse overlapping bold and italics like we have in this test.
      final text = AttributedText(
        'abcdefghij',
        AttributedSpans(
          attributions: [
            const SpanMarker(attribution: ExpectedSpans.bold, offset: 2, markerType: SpanMarkerType.start),
            const SpanMarker(attribution: ExpectedSpans.italics, offset: 4, markerType: SpanMarkerType.start),
            const SpanMarker(attribution: ExpectedSpans.bold, offset: 5, markerType: SpanMarkerType.end),
            const SpanMarker(attribution: ExpectedSpans.italics, offset: 7, markerType: SpanMarkerType.end),
          ],
        ),
      );
      final textSpan = text.computeInlineSpan(context, _styleBuilder, const []) as TextSpan;

      expect(textSpan.text, null);
      expect(textSpan.children!.length, 5);
      expect(textSpan.children![0].toPlainText(), 'ab');
      expect(textSpan.children![0].style!.fontWeight, null);
      expect(textSpan.children![0].style!.fontStyle, null);

      expect(textSpan.children![1].toPlainText(), 'cd');
      expect(textSpan.children![1].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![1].style!.fontStyle, null);

      expect(textSpan.children![2].toPlainText(), 'ef');
      expect(textSpan.children![2].style!.fontWeight, FontWeight.bold);
      expect(textSpan.children![2].style!.fontStyle, FontStyle.italic);

      expect(textSpan.children![3].toPlainText(), 'gh');
      expect(textSpan.children![3].style!.fontWeight, null);
      expect(textSpan.children![3].style!.fontStyle, FontStyle.italic);

      expect(textSpan.children![4].toPlainText(), 'ij');
      expect(textSpan.children![4].style!.fontWeight, null);
      expect(textSpan.children![4].style!.fontStyle, null);
    });
  });
}

/// Creates styles based on the given `attributions`.
TextStyle _styleBuilder(Set<Attribution> attributions) {
  TextStyle newStyle = const TextStyle();
  for (final attribution in attributions) {
    if (attribution == ExpectedSpans.bold) {
      newStyle = newStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
    } else if (attribution == ExpectedSpans.italics) {
      newStyle = newStyle.copyWith(
        fontStyle: FontStyle.italic,
      );
    } else if (attribution == ExpectedSpans.strikethrough) {
      newStyle = newStyle.copyWith(
        decoration: TextDecoration.lineThrough,
      );
    }
  }
  return newStyle;
}
