// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math' as math;

import 'package:markdown/markdown.dart';

import 'package:tech_pulse/api/graphql/query/articles/query_article_detail.graphql.dart';
import 'package:tech_pulse/models/article/exports.dart';
import 'package:tech_pulse/ui/widgets/article/swappable_markdown.dart';

class ArticleFull extends GraphQLNode {
  final int articleId;
  final String titleEn;
  final String subtitleEn;
  final String contentEn;
  final String titleCn;
  final String subtitleCn;
  final String contentCn;
  final String summaryCn;
  final String url;
  final DateTime pubTime;
  final String headerImg;
  final String thumbImg;
  final AuthorFull author;
  final PublisherFull publisher;
  final List<String> tagsPlain;
  final List<TagFull> tags;
  final int likes;
  final int views;
  final bool isLiked;

  ArticleFull({
    required super.nodeId,
    required this.articleId,
    required this.titleEn,
    required this.subtitleEn,
    required this.contentEn,
    required this.titleCn,
    required this.subtitleCn,
    required this.contentCn,
    required this.summaryCn,
    required this.url,
    required this.pubTime,
    required this.headerImg,
    required this.thumbImg,
    required this.author,
    required this.publisher,
    required this.tagsPlain,
    required this.tags,
    required this.likes,
    required this.views,
    required this.isLiked,
  });

  factory ArticleFull.fromGraphQL(Query$ArticleDetailNode data) {
    final node = data.node;

    if (node is! Query$ArticleDetailNode$node$$article) {
      throw Exception('Node is not an article');
    }

    return ArticleFull(
      nodeId: node.nodeId,
      articleId: node.article_id,
      titleEn: node.title_en,
      subtitleEn: node.subtitle_en,
      contentEn: node.content_en,
      titleCn: node.title_cn,
      subtitleCn: node.subtitle_cn,
      contentCn: node.content_cn,
      summaryCn: node.summary_cn,
      url: node.url,
      pubTime: DateTime.parse(node.pubtime),
      headerImg: node.header_img,
      thumbImg: node.thumb_img,
      tagsPlain: node.tags_plain.whereType<String>().toList(),
      author: AuthorFull.fromGraphNode(node.author),
      publisher: PublisherFull.fromGraphNode(node.publisher),
      tags:
          node.article_tagCollection?.edges
              .map((e) => TagFull.fromGraphNode(e.node.tag))
              .toList() ??
          [],
      likes: node.article_stats?.likes ?? 0,
      views: node.article_stats?.views ?? 0,
      isLiked: node.like_articleCollection != null && node.like_articleCollection!.pageInfo.startCursor != null
          ? true
          : false,
    );
  }

  static List<String> splitMarkdownBlocks(String rawMarkdown) {
    List<String> originalLines = rawMarkdown.split('\n');
    var document = Document(extensionSet: ExtensionSet.gitHubFlavored);
    List<Node> nodes = document.parseLines(originalLines);

    List<String> result = [];
    int currentLineIndex = 0;

    for (var node in nodes) {
      List<String> chunkLines = [];

      if (node is Element) {
        // 跳过起始的空行
        while (currentLineIndex < originalLines.length &&
            originalLines[currentLineIndex].trim().isEmpty) {
          currentLineIndex++;
        }
        if (currentLineIndex >= originalLines.length) {
          result.add('\n');
          continue;
        }

        int startLine = currentLineIndex;

        if (node.tag == 'ul' || node.tag == 'ol' || node.tag == 'table') {
          while (currentLineIndex < originalLines.length &&
              originalLines[currentLineIndex].trim().isNotEmpty) {
            currentLineIndex++;
          }
        } else {
          if (node.tag.startsWith('h')) {
            currentLineIndex++;
          } else {
            while (currentLineIndex < originalLines.length &&
                originalLines[currentLineIndex].trim().isNotEmpty) {
              currentLineIndex++;
            }
          }
        }

        int endLine = currentLineIndex;
        chunkLines = originalLines.sublist(startLine, endLine);
        result.add(chunkLines.join('\n'));
      }
    }
    return result;
  }

  List<MultiLangMarkdownSegment> get segments {
    final splitCn = splitMarkdownBlocks(contentCn);
    final splitEn = splitMarkdownBlocks(contentEn);
    final segmentCount = math.min(splitEn.length, splitCn.length);
    List<MultiLangMarkdownSegment> segments = [];
    for (var i = 0; i < segmentCount; i++) {
      segments.add(MultiLangMarkdownSegment(en: splitEn[i], zh: splitCn[i]));
    }
    return segments;
  }

  ArticleFull copyWith({
    String? nodeId,
    int? articleId,
    String? titleEn,
    String? subtitleEn,
    String? contentEn,
    String? titleCn,
    String? subtitleCn,
    String? contentCn,
    String? summaryCn,
    String? url,
    DateTime? pubTime,
    String? headerImg,
    String? thumbImg,
    AuthorFull? author,
    PublisherFull? publisher,
    List<String>? tagsPlain,
    List<TagFull>? tags,
    int? likes,
    int? views,
    bool? isLiked,
  }) {
    return ArticleFull(
      nodeId: nodeId ?? this.nodeId,
      articleId: articleId ?? this.articleId,
      titleEn: titleEn ?? this.titleEn,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      contentEn: contentEn ?? this.contentEn,
      titleCn: titleCn ?? this.titleCn,
      subtitleCn: subtitleCn ?? this.subtitleCn,
      contentCn: contentCn ?? this.contentCn,
      summaryCn: summaryCn ?? this.summaryCn,
      url: url ?? this.url,
      pubTime: pubTime ?? this.pubTime,
      headerImg: headerImg ?? this.headerImg,
      thumbImg: thumbImg ?? this.thumbImg,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      tagsPlain: tagsPlain ?? this.tagsPlain,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
