import 'package:test/test.dart';
import 'package:tech_pulse/models/article/article_full.dart';

void main() {
  group('ArticleFull.splitMarkdownBlocks', () {
    test('splits paragraphs separated by blank lines', () {
      final input = 'Paragraph one.\n\nParagraph two.';
      final result = ArticleFull.splitMarkdownBlocks(input);
      expect(result, ['Paragraph one.', 'Paragraph two.']);
    });

    test('treats headings as single-line chunks', () {
      final input = '# Heading\n\nFollowing paragraph';
      final result = ArticleFull.splitMarkdownBlocks(input);
      expect(result, ['# Heading', 'Following paragraph']);
    });

    test('groups unordered list into one chunk', () {
      final input = '- item1\n- item2\n\nNext';
      final result = ArticleFull.splitMarkdownBlocks(input);
      expect(result, ['- item1\n- item2', 'Next']);
    });

    test('groups markdown table into one chunk', () {
      final input = '|a|b|\n|---|---|\n|1|2|\n\nEnd';
      final result = ArticleFull.splitMarkdownBlocks(input);
      expect(result, ['|a|b|\n|---|---|\n|1|2|', 'End']);
    });

    test('skips leading blank lines before first node', () {
      final input = '\n\n# Title\n\nPara';
      final result = ArticleFull.splitMarkdownBlocks(input);
      expect(result, ['# Title', 'Para']);
    });

    test('returns nothing when only blank lines present', () {
      final input = '\n\n';
      final result = ArticleFull.splitMarkdownBlocks(input);
      expect(result, []);
    });
  });
}