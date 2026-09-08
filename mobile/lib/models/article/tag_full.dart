import 'package:tech_pulse/models/article/graph_ql_node.dart';

class TagFull extends GraphQLNode {
  /// 由于GraphQL不支持多对多关系下的按子查询排序，此处需要获取主键tag_id并使用
  /// SQL函数查询标签含有tag的全部文章，并按照文章发布时间降序排序
  final int tagId;
  String valueCn;
  String valueEn;
  TagFull({
    required super.nodeId,
    required this.tagId,
    required this.valueCn,
    required this.valueEn,
  });

  @override
  factory TagFull.fromGraphNode(dynamic node) {
    return TagFull(
      nodeId: node.nodeId,
      tagId: node.tag_id,
      valueCn: node.value_cn,
      valueEn: node.value_en,
    );
  }
}
