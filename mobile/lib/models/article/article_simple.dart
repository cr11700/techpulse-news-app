import 'package:tech_pulse/models/article/article_full.dart';
import 'package:tech_pulse/models/article/graph_ql_node.dart';

class ArticleSimple extends GraphQLNode {
  final String titleCn;
  final String publisherName;
  final String authorNodeId;
  final String authorName;
  final String authorAvatar;
  final DateTime pubTime;
  final String headerImg;
  final String thumbImg;
  final int likes;
  final int views;

  ArticleSimple({
    required super.nodeId,
    required this.titleCn,
    required this.publisherName,
    required this.authorNodeId,
    required this.authorName,
    required this.authorAvatar,
    required this.pubTime,
    required this.headerImg,
    required this.thumbImg,
    required this.likes,
    required this.views,
  });

  factory ArticleSimple.fromGraphNode(dynamic node) {
    return ArticleSimple(
      nodeId: node.node.nodeId,
      titleCn: node.node.title_cn,
      publisherName: node.node.publisher?.name ?? 'Unknown',
      authorNodeId: node.node.author?.nodeId ?? '',
      authorName: node.node.author?.name ?? 'Unknown',
      authorAvatar: node.node.author?.avatar ?? '',
      pubTime: DateTime.parse(node.node.pubtime),
      headerImg: node.node.header_img,
      thumbImg: node.node.thumb_img,
      likes: node.node.article_stats?.likes ?? 0,
      views: node.node.article_stats?.views ?? 0,
    );
  }

  factory ArticleSimple.fromFull(ArticleFull articleFull) {
    return ArticleSimple(
      nodeId: articleFull.nodeId,
      titleCn: articleFull.titleCn,
      publisherName: articleFull.publisher.name,
      authorNodeId: articleFull.author.nodeId,
      authorName: articleFull.author.name,
      authorAvatar: articleFull.author.avatar,
      pubTime: articleFull.pubTime,
      headerImg: articleFull.headerImg,
      thumbImg: articleFull.thumbImg,
      likes: articleFull.likes,
      views: articleFull.views,
    );
  }
}
